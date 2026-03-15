import {
  Injectable,
  ConflictException,
  UnauthorizedException,
  BadRequestException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import * as admin from 'firebase-admin';
import { SecretManagerServiceClient } from '@google-cloud/secret-manager';
import { PrismaService } from '../../common/prisma/prisma.service';
import { RegisterDto, LoginDto } from './dto/auth.dto';

@Injectable()
export class AuthService {
  private secretClient: SecretManagerServiceClient;
  private readonly jwtSecret: string;
  private readonly jwtRefreshSecret: string;

  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private configService: ConfigService
  ) {
    this.secretClient = new SecretManagerServiceClient();
    this.jwtSecret = this.configService.get<string>('JWT_SECRET') || '';
    this.jwtRefreshSecret =
      this.configService.get<string>('JWT_REFRESH_SECRET') || this.jwtSecret;
    this.initializeFirebase();
  }

  private async initializeFirebase() {
    try {
      const projectId =
        this.configService.get<string>('FIREBASE_PROJECT_ID') ||
        this.configService.get<string>('GOOGLE_CLOUD_PROJECT') ||
        'shomaj-817b0';

      let privateKey = this.configService.get<string>('FIREBASE_PRIVATE_KEY');
      let clientEmail = this.configService.get<string>('FIREBASE_CLIENT_EMAIL');

      if (!privateKey || !clientEmail) {
        const [privateKeyResponse] = await this.secretClient.accessSecretVersion({
          name: `projects/${projectId}/secrets/FIREBASE_PRIVATE_KEY/versions/latest`,
        });
        const [clientEmailResponse] = await this.secretClient.accessSecretVersion(
          {
            name: `projects/${projectId}/secrets/FIREBASE_CLIENT_EMAIL/versions/latest`,
          }
        );

        privateKey = privateKeyResponse.payload?.data?.toString();
        clientEmail = clientEmailResponse.payload?.data?.toString();
      }

      if (!privateKey || !clientEmail) {
        throw new Error('Firebase credentials are not configured');
      }

      // Initialize Firebase Admin
      if (!admin.apps.length) {
        admin.initializeApp({
          credential: admin.credential.cert({
            projectId,
            privateKey: privateKey.replace(/\\n/g, '\n'),
            clientEmail,
          }),
        });
      }
    } catch (error) {
      console.error('Failed to initialize Firebase:', error);
      // In development, fall back to config if available
      if (process.env.NODE_ENV !== 'production') {
        console.log('Falling back to config for Firebase initialization');
        if (!admin.apps.length) {
          admin.initializeApp({
            credential: admin.credential.cert({
              projectId: this.configService.get('FIREBASE_PROJECT_ID'),
              privateKey: this.configService
                .get('FIREBASE_PRIVATE_KEY')
                ?.replace(/\\n/g, '\n'),
              clientEmail: this.configService.get('FIREBASE_CLIENT_EMAIL'),
            }),
          });
        }
      }
    }
  }

  async register(registerDto: RegisterDto) {
    const { email, password, fullName, phone, role, tenantId } = registerDto;

    // Check if user exists
    const existingUser = await this.prisma.user.findUnique({
      where: { email },
    });

    if (existingUser) {
      throw new ConflictException('User already exists');
    }

    // Validate tenant if provided
    if (tenantId) {
      const tenant = await this.prisma.tenant.findUnique({
        where: { id: tenantId },
      });
      if (!tenant) {
        throw new BadRequestException('Invalid tenant ID');
      }
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Create user
    const user = await this.prisma.user.create({
      data: {
        email,
        password: hashedPassword,
        fullName,
        phone,
        role,
        tenantId,
      },
      select: {
        id: true,
        email: true,
        fullName: true,
        role: true,
        tenantId: true,
      },
    });

    return user;
  }

  async login(loginDto: LoginDto) {
    const { email, password } = loginDto;

    const user = await this.prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const tokens = await this.generateTokens(user.id);

    return {
      user: {
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        role: user.role,
        tenantId: user.tenantId,
      },
      ...tokens,
    };
  }

  async refreshToken(refreshToken: string) {
    try {
      const payload = this.jwtService.verify(refreshToken, {
        secret: this.getJWTRefreshSecret(),
      });

      const storedToken = await this.prisma.refreshToken.findUnique({
        where: { token: refreshToken },
      });

      if (!storedToken || storedToken.userId !== payload.sub) {
        throw new UnauthorizedException('Invalid refresh token');
      }

      // Delete old refresh token
      await this.prisma.refreshToken.delete({
        where: { token: refreshToken },
      });

      // Generate new tokens
      const tokens = await this.generateTokens(payload.sub);

      return tokens;
    } catch (error) {
      throw new UnauthorizedException('Invalid refresh token');
    }
  }

  private getJWTSecret(): string {
    if (!this.jwtSecret || this.jwtSecret.length === 0) {
      console.error('[Backend] JWT_SECRET not configured in environment variables either!');
    }
    return this.jwtSecret;
  }

  private getJWTRefreshSecret(): string {
    if (!this.jwtRefreshSecret || this.jwtRefreshSecret.length === 0) {
      console.error('[Backend] JWT_REFRESH_SECRET not configured in environment variables either!');
    }
    return this.jwtRefreshSecret;
  }

  private async generateTokens(userId: string) {
    console.log('[Backend] generateTokens called for userId:', userId);

    const payload = { sub: userId };

    const accessSecret = this.getJWTSecret();
    const accessExpires =
      this.configService.get<string>('JWT_EXPIRES_IN') || '15m';
    const refreshSecret = this.getJWTRefreshSecret();
    const refreshExpires =
      this.configService.get<string>('JWT_REFRESH_EXPIRES_IN') || '7d';

    console.log('[Backend] JWT secrets retrieved, accessSecret length:', accessSecret?.length, 'refreshSecret length:', refreshSecret?.length);

    // Check if secrets are available
    if (!accessSecret || accessSecret.length === 0) {
      console.error('[Backend] JWT_ACCESS_SECRET is not configured!');
      throw new Error('JWT access secret not configured');
    }
    if (!refreshSecret || refreshSecret.length === 0) {
      console.error('[Backend] JWT_REFRESH_SECRET is not configured!');
      throw new Error('JWT refresh secret not configured');
    }

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(payload, {
        secret: accessSecret,
        expiresIn: accessExpires,
      }),
      this.jwtService.signAsync(payload, {
        secret: refreshSecret,
        expiresIn: refreshExpires,
      }),
    ]);

    console.log('[Backend] JWT tokens signed, accessToken exists:', !!accessToken, 'refreshToken exists:', !!refreshToken);

    // Store refresh token
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7); // 7 days

    await this.prisma.refreshToken.create({
      data: {
        token: refreshToken,
        userId,
        expiresAt,
      },
    });

    console.log('[Backend] Refresh token stored in database');

    const result = {
      accessToken,
      refreshToken,
    };

    console.log('[Backend] generateTokens returning:', { hasAccess: !!result.accessToken, hasRefresh: !!result.refreshToken });

    return result;
  }

  async logout(refreshToken: string) {
    try {
      await this.prisma.refreshToken.delete({
        where: { token: refreshToken },
      });
      return { message: 'Logged out successfully' };
    } catch (error) {
      throw new BadRequestException('Invalid refresh token');
    }
  }

  async firebaseAuth(idToken: string) {
    try {
      if (!idToken) {
        throw new BadRequestException('ID token is required');
      }
      console.log('[Backend] Starting Firebase auth for token:', idToken.length > 20 ? idToken.substring(0, 20) + '...' : idToken);
      const decodedToken = await admin.auth().verifyIdToken(idToken);
      const { uid, email, name, picture } = decodedToken;
      console.log('[Backend] Firebase token verified for user:', email);

      // Check if user exists
      let user = await this.prisma.user.findUnique({
        where: { email },
      });
      console.log('[Backend] User lookup result:', user ? 'existing' : 'new');

      // If user doesn't exist, create new user
      if (!user) {
        user = await this.prisma.user.create({
          data: {
            email,
            fullName: name || email,
            password: await bcrypt.hash(Math.random().toString(36), 10), // Random password
            role: 'EMPLOYEE', // Default role
          },
        });
        console.log('[Backend] New user created:', user.id);
      }

      // Generate tokens
      console.log('[Backend] Generating tokens for user:', user.id);
      const tokens = await this.generateTokens(user.id);
      console.log('[Backend] Tokens generated successfully');

      const response = {
        ...tokens,
        user: {
          id: user.id,
          email: user.email,
          fullName: user.fullName,
          role: user.role,
          tenantId: user.tenantId,
        },
      };

      console.log('[Backend] Firebase auth response:', {
        hasAccessToken: !!response.accessToken,
        hasRefreshToken: !!response.refreshToken,
        hasUser: !!response.user,
        userId: response.user?.id
      });

      return response;
    } catch (error) {
      console.error('[Backend] Firebase auth error:', error);
      throw new UnauthorizedException('Invalid Firebase token');
    }
  }

  async changePasswordForUser(
    currentUserId: string,
    userId: string,
    newPassword: string
  ) {
    // Check if current user is SUPER_ADMIN
    const currentUser = await this.prisma.user.findUnique({
      where: { id: currentUserId },
    });

    if (!currentUser || currentUser.role !== 'SUPER_ADMIN') {
      throw new UnauthorizedException(
        'Only super admin can change passwords for other users'
      );
    }

    // Check if target user exists
    const targetUser = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!targetUser) {
      throw new BadRequestException('User not found');
    }

    // Hash new password
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Update password
    await this.prisma.user.update({
      where: { id: userId },
      data: { password: hashedPassword },
    });

    return { message: 'Password changed successfully' };
  }
}
