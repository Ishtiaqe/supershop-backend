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
  async login(@Body() loginDto: LoginDto, @Res({ passthrough: true }) res: Response) {
    const result = await this.authService.login(loginDto);
    // Set HttpOnly cookies for access and refresh tokens
    const cookieDomain = this.configService.get('COOKIE_DOMAIN');
    const isProd = process.env.NODE_ENV === 'production';
    // In development, avoid setting cross-domain cookies (e.g., .shomaj.one) so they work on localhost
    const accessCookieOptions: Record<string, any> = {
      httpOnly: true,
      secure: isProd,
      sameSite: (isProd ? 'none' : 'lax') as 'none' | 'lax' | 'strict',
      path: '/',
    };
    if (isProd && cookieDomain) {
      accessCookieOptions.domain = cookieDomain;
    }
    const refreshCookieOptions: Record<string, any> = {
      httpOnly: true,
      secure: isProd,
      sameSite: (isProd ? 'none' : 'lax') as 'none' | 'lax' | 'strict',
      path: '/',
      maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
    };
    if (isProd && cookieDomain) {
      refreshCookieOptions.domain = cookieDomain;
    }

    res.cookie('accessToken', result.accessToken, accessCookieOptions);
    res.cookie('refreshToken', result.refreshToken, refreshCookieOptions);

    return {
      user: result.user,
    };
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @Throttle({ default: { limit: 10, ttl: 60000 } })
  @ApiOperation({ summary: 'Refresh access token' })
  @ApiResponse({ status: 200, description: 'Token refreshed successfully' })
  @ApiResponse({ status: 401, description: 'Invalid refresh token' })
  async refresh(@Body() refreshTokenDto: RefreshTokenDto, @Req() req: Request, @Res({ passthrough: true }) res: Response) {
    const refreshToken = refreshTokenDto?.refreshToken || req.cookies?.refreshToken;
    const result = await this.authService.refreshToken(refreshToken);
    // Update cookies as with login
    const cookieDomain = this.configService.get('COOKIE_DOMAIN');
    const isProd = process.env.NODE_ENV === 'production';
    const accessCookieOptions: Record<string, any> = {
      httpOnly: true,
      secure: isProd,
      sameSite: (isProd ? 'none' : 'lax') as 'none' | 'lax' | 'strict',
      path: '/',
    };
    if (isProd && cookieDomain) {
      accessCookieOptions.domain = cookieDomain;
    }
    const refreshCookieOptions: Record<string, any> = {
      httpOnly: true,
      secure: isProd,
      sameSite: (isProd ? 'none' : 'lax') as 'none' | 'lax' | 'strict',
      path: '/',
      maxAge: 7 * 24 * 60 * 60 * 1000,
    };
    if (isProd && cookieDomain) {
      refreshCookieOptions.domain = cookieDomain;
    }
    if (result?.accessToken) {
      res.cookie('accessToken', result.accessToken, accessCookieOptions);
    }
    if (result?.refreshToken) {
      res.cookie('refreshToken', result.refreshToken, refreshCookieOptions);
    }
    // return tokens for backward compatibility (optional)
    return result;
  }

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Logout user' })
  @ApiResponse({ status: 200, description: 'Logged out successfully' })
  async logout(@Req() req: Request, @Res({ passthrough: true }) res: Response) {
    const refreshToken = req.body?.refreshToken || req.cookies?.refreshToken;

    if (refreshToken) {
      try {
        await this.authService.logout(refreshToken);
      } catch (e) {
        // Ignore errors if token is already invalid
      }
    }

    // Clear cookies
    const cookieDomain = this.configService.get('COOKIE_DOMAIN');
    const isProd = process.env.NODE_ENV === 'production';
    const clearCookieOpts: Record<string, any> = {
      path: '/',
      sameSite: (isProd ? 'none' : 'lax') as 'none' | 'lax' | 'strict',
      secure: isProd,
      httpOnly: true,
    };
    if (isProd && cookieDomain) {
      clearCookieOpts.domain = cookieDomain;
    }
    res.clearCookie('accessToken', clearCookieOpts);
    res.clearCookie('refreshToken', clearCookieOpts);
    return { success: true };
  }

  @Post('firebase')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Authenticate with Firebase token' })
  @ApiResponse({ status: 200, description: 'Authentication successful' })
  @ApiResponse({ status: 401, description: 'Invalid Firebase token' })
  async firebaseAuth(@Body() body: { idToken: string }, @Res({ passthrough: true }) res: Response) {
    const result = await this.authService.firebaseAuth(body.idToken);
    // Set HttpOnly cookies for access and refresh tokens
    const cookieDomain = this.configService.get('COOKIE_DOMAIN');
    const isProd = process.env.NODE_ENV === 'production';
    const accessCookieOptions: Record<string, any> = {
      httpOnly: true,
      secure: isProd,
      sameSite: (isProd ? 'none' : 'lax') as 'none' | 'lax' | 'strict',
      path: '/',
    };
    if (isProd && cookieDomain) {
      accessCookieOptions.domain = cookieDomain;
    }
    const refreshCookieOptions: Record<string, any> = {
      httpOnly: true,
      secure: isProd,
      sameSite: (isProd ? 'none' : 'lax') as 'none' | 'lax' | 'strict',
      path: '/',
      maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
    };
    if (isProd && cookieDomain) {
      refreshCookieOptions.domain = cookieDomain;
    }

    res.cookie('accessToken', result.accessToken, accessCookieOptions);
    res.cookie('refreshToken', result.refreshToken, refreshCookieOptions);

    return {
      user: result.user,
    };
  }
}
