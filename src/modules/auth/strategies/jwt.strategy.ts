import {Injectable, UnauthorizedException} from '@nestjs/common';
import {ConfigService} from '@nestjs/config';
import {PassportStrategy} from '@nestjs/passport';
import {ExtractJwt, Strategy} from 'passport-jwt';
import {PrismaService} from '../../../common/prisma/prisma.service';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private prisma: PrismaService, private configService: ConfigService) {
    const secretFromConfig = configService.get<string>('JWT_SECRET') || process.env.JWT_SECRET;
    let secret = secretFromConfig;
    if (!secret) {
      if (process.env.NODE_ENV === 'production') {
        console.error('[Backend] JWT_SECRET not configured in environment variables!');
        throw new Error('JWT_SECRET is not configured. Set JWT_SECRET in the environment or secret manager.');
      }
      // Development fallback to avoid blocking local dev when env isn't provided
      console.warn('[Backend] JWT_SECRET missing, using insecure fallback for development');
      secret = 'supershop-local-dev-secret';
    }

    super({
      jwtFromRequest: ExtractJwt.fromExtractors([
        ExtractJwt.fromAuthHeaderAsBearerToken(),
        (req) => req?.cookies?.accessToken,
      ]),
      ignoreExpiration: false,
      secretOrKey: secret,
    });
  }

  async validate(payload: any) {
    const user = await this.prisma.user.findUnique({
      where: {id: payload.sub},
      select: {
        id: true,
        email: true,
        fullName: true,
        role: true,
        tenantId: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException();
    }

    return user;
  }
}
