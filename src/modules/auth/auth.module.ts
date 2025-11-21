import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtStrategy } from './strategies/jwt.strategy';
import { GoogleStrategy } from './strategies/google.strategy';
import { RolesGuard } from './guards/roles.guard';

@Module({
  imports: [
    PassportModule,
    JwtModule.registerAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => ({
        // Provide sensible defaults so missing envs don't crash runtime
        secret: configService.get('JWT_SECRET'),
        signOptions: (() => {
          const exp = configService.get<string>('JWT_EXPIRES_IN');
          // Only include expiresIn if defined and valid-looking; otherwise let jwt default
          if (exp && typeof exp === 'string' && exp.trim().length > 0) {
            return { expiresIn: exp };
          }
          // Default short-lived access token
          return { expiresIn: '15m' };
        })(),
      }),
      inject: [ConfigService],
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy, GoogleStrategy, RolesGuard],
  exports: [AuthService, RolesGuard],
})
export class AuthModule { }
