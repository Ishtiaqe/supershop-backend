/**
 * Cookie Service
 * Implements: Single Responsibility Principle (SRP)
 * Handles all cookie-related operations, removing this concern from controllers
 */

import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Response } from 'express';

export interface TokenPair {
  accessToken: string;
  refreshToken: string;
}

export interface CookieOptions {
  httpOnly: boolean;
  secure: boolean;
  sameSite: 'lax' | 'strict' | 'none';
  path: string;
  maxAge?: number;
}

/**
 * Parse time string to milliseconds
 * Examples: "15m" -> 900000, "1h" -> 3600000, "7d" -> 604800000
 */
function parseTimeToMs(timeStr: string): number {
  const match = /^(\d+)\s*([smhd])$/.exec(timeStr.trim().toLowerCase());
  if (!match) {
    throw new Error(`Invalid time format: ${timeStr}`);
  }

  const [, value, unit] = match;
  const num = parseInt(value, 10);

  const multipliers: Record<string, number> = {
    s: 1000,
    m: 60 * 1000,
    h: 60 * 60 * 1000,
    d: 24 * 60 * 60 * 1000,
  };

  return num * (multipliers[unit] || 1);
}

@Injectable()
export class CookieService {
  private isProduction: boolean;
  private accessTokenExpiresIn: number;
  private refreshTokenExpiresIn: number;

  constructor(private configService: ConfigService) {
    this.isProduction =
      this.configService.get('NODE_ENV') === 'production';
    this.accessTokenExpiresIn = parseTimeToMs(
      this.configService.get('JWT_EXPIRES_IN') || '15m'
    );
    this.refreshTokenExpiresIn = parseTimeToMs(
      this.configService.get('JWT_REFRESH_EXPIRES_IN') || '7d'
    );
  }

  /**
   * Get access token cookie options
   */
  private getAccessTokenCookieOptions(): CookieOptions {
    return {
      httpOnly: true,
      secure: this.isProduction,
      sameSite: this.isProduction ? 'strict' : 'lax',
      path: '/',
      maxAge: this.accessTokenExpiresIn,
    };
  }

  /**
   * Get refresh token cookie options
   */
  private getRefreshTokenCookieOptions(): CookieOptions {
    return {
      httpOnly: true,
      secure: this.isProduction,
      sameSite: this.isProduction ? 'strict' : 'lax',
      path: '/',
      maxAge: this.refreshTokenExpiresIn,
    };
  }

  /**
   * Set both access and refresh tokens as cookies
   */
  setTokenCookies(response: Response, tokens: TokenPair): void {
    const accessOptions = this.getAccessTokenCookieOptions();
    const refreshOptions = this.getRefreshTokenCookieOptions();

    response.cookie('accessToken', tokens.accessToken, accessOptions);
    response.cookie('refreshToken', tokens.refreshToken, refreshOptions);
  }

  /**
   * Set access token only (for refresh operations)
   */
  setAccessTokenCookie(response: Response, token: string): void {
    const options = this.getAccessTokenCookieOptions();
    response.cookie('accessToken', token, options);
  }

  /**
   * Clear auth cookies (for logout)
   */
  clearTokenCookies(response: Response): void {
    response.clearCookie('accessToken', { path: '/' });
    response.clearCookie('refreshToken', { path: '/' });
  }

  /**
   * Extract token from cookies
   */
  extractToken(cookies: any, tokenName = 'accessToken'): string | null {
    return cookies?.[tokenName] || null;
  }
}
