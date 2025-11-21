import {
  Injectable,
  ConflictException,
  UnauthorizedException,
  BadRequestException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../../common/prisma/prisma.service';
import { RegisterDto, LoginDto } from './dto/auth.dto';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) { }

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
        secret: this.configService.get('JWT_REFRESH_SECRET'),
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

  private async generateTokens(userId: string) {
    const payload = { sub: userId };

    const accessSecret = this.configService.get<string>('JWT_SECRET');
    const accessExpires = this.configService.get<string>('JWT_EXPIRES_IN') || '15m';
    const refreshSecret =
      this.configService.get<string>('JWT_REFRESH_SECRET') || accessSecret;
    const refreshExpires =
      this.configService.get<string>('JWT_REFRESH_EXPIRES_IN') || '7d';

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

    return {
      accessToken,
      refreshToken,
    };
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

  async googleLogin(googleUser: any) {
    const { email, firstName, lastName } = googleUser;

    // Check if user exists
    let user = await this.prisma.user.findUnique({
      where: { email },
    });

    // If user doesn't exist, create new user
    if (!user) {
      // For super admin (ishtiaqe22@gmail.com)
      if (email === 'ishtiaqe22@gmail.com') {
        user = await this.prisma.user.create({
          data: {
            email,
            fullName: `${firstName} ${lastName}`.trim() || email,
            password: await bcrypt.hash(Math.random().toString(36), 10), // Random password
            role: 'SUPER_ADMIN',
          },
        });
      } else {
        // For regular users, check if they should be allowed
        throw new UnauthorizedException(
          'User not found. Please contact administrator to set up your account.',
        );
      }
    }

    // Generate tokens
    const tokens = await this.generateTokens(user.id);

    return {
      ...tokens,
      user: {
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        role: user.role,
        tenantId: user.tenantId,
      },
    };
  }

  async changePasswordForUser(currentUserId: string, userId: string, newPassword: string) {
    // Check if current user is SUPER_ADMIN
    const currentUser = await this.prisma.user.findUnique({
      where: { id: currentUserId },
    });

    if (!currentUser || currentUser.role !== 'SUPER_ADMIN') {
      throw new UnauthorizedException('Only super admin can change passwords for other users');
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
