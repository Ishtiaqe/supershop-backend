import {
  Controller,
  Post,
  Body,
  HttpCode,
  HttpStatus,
  Get,
  UseGuards,
  Req,
  Res,
  UnauthorizedException,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { Throttle } from '@nestjs/throttler';
import { Response, Request } from 'express';
import { ConfigService } from '@nestjs/config';
import { AuthService } from './auth.service';
import {
  RegisterDto,
  LoginDto,
  RefreshTokenDto,
  ChangePasswordDto,
} from './dto/auth.dto';
import { CurrentUser } from './decorators/current-user.decorator';

@ApiTags('Authentication')
@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService, private configService: ConfigService) { }

  private getCookieOptions() {
    const isProduction = this.configService.get('NODE_ENV') === 'production';
    return {
      httpOnly: true,
      secure: isProduction,
      sameSite: 'lax' as const,
      maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
      path: '/',
    };
  }

  private getAccessTokenCookieOptions() {
    const isProduction = this.configService.get('NODE_ENV') === 'production';
    const expiresIn = this.configService.get<string>('JWT_EXPIRES_IN') || '15m';
    const maxAge = this.parseExpiresInToMs(expiresIn);
    return {
      httpOnly: true,
      secure: isProduction,
      sameSite: 'lax' as const,
      maxAge,
      path: '/',
    };
  }

  private parseExpiresInToMs(value: string): number {
    const trimmed = value.trim();
    const match = /^([0-9]+)\s*([smhd])$/i.exec(trimmed);
    if (!match) {
      return 15 * 60 * 1000;
    }
    const amount = Number(match[1]);
    const unit = match[2].toLowerCase();
    switch (unit) {
      case 's':
        return amount * 1000;
      case 'm':
        return amount * 60 * 1000;
      case 'h':
        return amount * 60 * 60 * 1000;
      case 'd':
        return amount * 24 * 60 * 60 * 1000;
      default:
        return 15 * 60 * 1000;
    }
  }

  @Post('register')
  @Throttle({ default: { limit: 5, ttl: 60000 } })
  @ApiOperation({ summary: 'Register a new user' })
  @ApiResponse({ status: 201, description: 'User successfully registered' })
  @ApiResponse({ status: 409, description: 'User already exists' })
  async register(@Body() registerDto: RegisterDto) {
    return this.authService.register(registerDto);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { limit: 5, ttl: 60000 } })
  @ApiOperation({ summary: 'Login user' })
  @ApiResponse({ status: 200, description: 'Login successful' })
  @ApiResponse({ status: 401, description: 'Invalid credentials' })
  async login(
    @Body() loginDto: LoginDto,
    @Res({ passthrough: true }) response: Response,
  ) {
    const result = await this.authService.login(loginDto);

    // Set refresh token as httpOnly cookie
    response.cookie('refreshToken', result.refreshToken, this.getCookieOptions());

    // Set access token as httpOnly cookie for downloads and direct navigation
    response.cookie('accessToken', result.accessToken, this.getAccessTokenCookieOptions());

    // Return user and access token only (not refresh token)
    const { refreshToken, ...responseData } = result;
    return responseData;
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { limit: 10, ttl: 60000 } })
  @ApiOperation({ summary: 'Refresh access token' })
  @ApiResponse({ status: 200, description: 'Token refreshed successfully' })
  @ApiResponse({ status: 401, description: 'Invalid refresh token' })
  async refresh(
    @Req() request: Request,
    @Res({ passthrough: true }) response: Response,
  ) {
    const refreshToken = request.cookies?.refreshToken;
    if (!refreshToken) {
      throw new UnauthorizedException('Refresh token is required');
    }

    const result = await this.authService.refreshToken(refreshToken);

    // Set new refresh token as httpOnly cookie
    response.cookie('refreshToken', result.refreshToken, this.getCookieOptions());

    // Set new access token as httpOnly cookie
    response.cookie('accessToken', result.accessToken, this.getAccessTokenCookieOptions());

    // Return only access token (not refresh token)
    const { refreshToken: newRefreshToken, ...responseData } = result;
    return responseData;
  }

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Logout user' })
  @ApiResponse({ status: 200, description: 'Logged out successfully' })
  async logout(
    @Req() request: Request,
    @Res({ passthrough: true }) response: Response,
  ) {
    const refreshToken = request.cookies?.refreshToken;

    if (refreshToken) {
      try {
        await this.authService.logout(refreshToken);
      } catch (e) {
        // Ignore errors if token is already invalid
      }
    }

    // Clear the refresh token cookie
    response.clearCookie('refreshToken', { path: '/' });
    response.clearCookie('accessToken', { path: '/' });

    return { success: true };
  }

  @Post('firebase')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Authenticate with Firebase token' })
  @ApiResponse({ status: 200, description: 'Authentication successful' })
  @ApiResponse({ status: 401, description: 'Invalid Firebase token' })
  async firebaseAuth(
    @Body() body: { idToken: string },
    @Res({ passthrough: true }) response: Response,
  ) {
    console.log('[Backend] Firebase auth request body:', JSON.stringify(body));
    const result = await this.authService.firebaseAuth(body.idToken);

    // Set refresh token as httpOnly cookie
    response.cookie('refreshToken', result.refreshToken, this.getCookieOptions());

    // Set access token as httpOnly cookie for downloads and direct navigation
    response.cookie('accessToken', result.accessToken, this.getAccessTokenCookieOptions());

    // Return user and access token only (not refresh token)
    const { refreshToken, ...responseData } = result;
    return responseData;
  }
}
