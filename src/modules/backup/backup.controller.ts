import {
  Controller,
  Get,
  Post,
  Delete,
  UseGuards,
  UseInterceptors,
  UploadedFile,
  BadRequestException,
  Response,
  Logger,
  Param,
  Body,
} from '@nestjs/common';
import {FileInterceptor} from '@nestjs/platform-express';
import {Response as ExpressResponse} from 'express';
import {BackupService} from './backup.service';
import {JwtAuthGuard} from '@/modules/auth/guards/jwt-auth.guard';
import {RolesGuard} from '@/modules/auth/guards/roles.guard';
import {Roles} from '@/modules/auth/decorators/roles.decorator';
import {UserRole} from '@/modules/auth/dto/auth.dto';
import {CurrentUser} from '@/modules/auth/decorators/current-user.decorator';

@Controller('backup')
@UseGuards(JwtAuthGuard, RolesGuard)
export class BackupController {
  private readonly logger = new Logger(BackupController.name);

  constructor(private readonly backupService: BackupService) {}

  @Get('export')
  @Roles(UserRole.OWNER)
  async exportBackup(
    @CurrentUser() user: any,
    @Response() res: ExpressResponse
  ) {
    try {
      this.logger.log(
        `User ${user.id} (tenantId: ${user.tenantId}) requesting backup export`
      );

      const buffer = await this.backupService.exportTenantBackup(user.tenantId);

      const timestamp = new Date().toISOString().split('T')[0];
      const filename = `supershop-backup-${timestamp}.json`;

      res.setHeader('Content-Type', 'application/json');
      res.setHeader(
        'Content-Disposition',
        `attachment; filename="${filename}"`
      );
      res.setHeader('Content-Length', buffer.length);

      this.logger.log(
        `Backup exported successfully for tenantId: ${user.tenantId}`
      );
      res.send(buffer);
    } catch (error) {
      this.logger.error(
        `Backup export failed for user ${user.id}:`,
        error.message
      );
      res.status(400).json({
        message: 'Failed to export backup',
        error: error.message,
      });
    }
  }

  @Post('import')
  @Roles(UserRole.OWNER)
  @UseInterceptors(FileInterceptor('file'))
  async importBackup(
    @UploadedFile() file: any,
    @CurrentUser() user: any,
    @Response() res: ExpressResponse
  ) {
    try {
      if (!file) {
        throw new BadRequestException('No file uploaded');
      }

      this.logger.log(
        `User ${user.id} requesting backup import. File size: ${file.size} bytes`
      );

      // Validate file size (max 100MB)
      const MAX_SIZE = 100 * 1024 * 1024;
      if (file.size > MAX_SIZE) {
        throw new BadRequestException(
          `File size exceeds ${MAX_SIZE / 1024 / 1024}MB limit`
        );
      }

      // Validate file extension - backups are exported as JSON
      const validExtensions = ['.json'];
      const fileExtension = file.originalname.substring(
        file.originalname.lastIndexOf('.')
      );
      if (!validExtensions.includes(fileExtension)) {
        throw new BadRequestException(
          'Invalid file type. Only .json backup files are allowed'
        );
      }

      const result = await this.backupService.importTenantBackup(
        user.tenantId,
        user.id,
        file.buffer
      );

      this.logger.log(`Backup imported successfully for user ${user.id}`);
      res.status(200).json(result);
    } catch (error) {
      this.logger.error(
        `Backup import failed for user ${user.id}:`,
        error.message
      );
      res.status(400).json({
        message: 'Failed to import backup',
        error: error.message,
      });
    }
  }

  @Delete('data')
  @Roles(UserRole.OWNER)
  async deleteTenantData(@CurrentUser() user: any, @Body() body: any) {
    // MINOR 12: Require explicit confirmation to prevent accidental/CSRF deletion
    if (body?.confirm !== 'DELETE_ALL_DATA') {
      throw new BadRequestException(
        'Confirmation token invalid. Send { confirm: "DELETE_ALL_DATA" } to confirm deletion.'
      );
    }
    this.logger.warn(
      `User ${user.id} (tenantId: ${user.tenantId}) requesting deletion of all shop data`
    );
    return await this.backupService.deleteTenantData(user.tenantId);
  }

  @Get('status')
  @Roles(UserRole.OWNER)
  async getBackupStatus(@CurrentUser() user: any) {
    try {
      const status = await this.backupService.getBackupStatus(user.tenantId);
      return status;
    } catch (error) {
      this.logger.error(
        `Failed to get backup status for user ${user.id}:`,
        error.message
      );
      return {
        productCount: 0,
        variantCount: 0,
        inventoryCount: 0,
        saleCount: 0,
      };
    }
  }

  @Get('export-user/:userId')
  async exportUserData(
    @CurrentUser() user: any,
    @Param('userId') userId: string,
    @Response() res: ExpressResponse
  ) {
    try {
      // Only tenant owners (SUPER_ADMIN role) can export user data
      if (user.role !== 'SUPER_ADMIN') {
        throw new BadRequestException(
          'Only tenant owners can export user data'
        );
      }

      this.logger.log(
        `User ${user.id} (SUPER_ADMIN) requesting data export for userId: ${userId}`
      );

      const buffer = await this.backupService.exportUserData(userId);

      const timestamp = new Date().toISOString().split('T')[0];
      const filename = `user-data-${userId}-${timestamp}.json`;

      res.setHeader('Content-Type', 'application/json');
      res.setHeader(
        'Content-Disposition',
        `attachment; filename="${filename}"`
      );
      res.setHeader('Content-Length', buffer.length);

      this.logger.log(`User data exported successfully for userId: ${userId}`);
      res.send(buffer);
    } catch (error) {
      this.logger.error(
        `User data export failed for user ${user.id}:`,
        error.message
      );
      res.status(400).json({
        message: 'Failed to export user data',
        error: error.message,
      });
    }
  }
}
