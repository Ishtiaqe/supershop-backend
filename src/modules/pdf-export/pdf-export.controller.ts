import {
  Controller,
  Get,
  UseGuards,
  Req,
  Res,
} from '@nestjs/common';
import { Response } from 'express';
import { JwtAuthGuard } from '../../modules/auth/guards/jwt-auth.guard';
import { PdfExportService } from './pdf-export.service';

@Controller('export')
@UseGuards(JwtAuthGuard)
export class PdfExportController {
  constructor(private pdfExportService: PdfExportService) {}

  /**
   * Export short list as PDF
   */
  @Get('pdf/shortlist')
  async exportShortListPdf(@Req() req, @Res() res: Response) {
    try {
      const buffer = await this.pdfExportService.generateShortListPdf(
        req.user.tenantId,
      );

      res.set({
        'Content-Type': 'application/pdf',
        'Content-Disposition':
          'attachment; filename="short-list-' +
          new Date().toISOString().split('T')[0] +
          '.pdf"',
        'Content-Length': buffer.length,
      });

      res.send(buffer);
    } catch (error) {
      res.status(500).json({
        message: 'Failed to generate PDF',
        error: error.message,
      });
    }
  }

  /**
   * Export inventory as PDF with short list indicators
   */
  @Get('pdf/inventory')
  async exportInventoryPdf(@Req() req, @Res() res: Response) {
    try {
      const buffer = await this.pdfExportService.generateInventoryPdf(
        req.user.tenantId,
      );

      res.set({
        'Content-Type': 'application/pdf',
        'Content-Disposition':
          'attachment; filename="inventory-' +
          new Date().toISOString().split('T')[0] +
          '.pdf"',
        'Content-Length': buffer.length,
      });

      res.send(buffer);
    } catch (error) {
      res.status(500).json({
        message: 'Failed to generate PDF',
        error: error.message,
      });
    }
  }

  /**
   * Export analytics as PDF
   */
  @Get('pdf/analytics')
  async exportAnalyticsPdf(@Req() req, @Res() res: Response) {
    try {
      const buffer = await this.pdfExportService.generateAnalyticsPdf(
        req.user.tenantId,
      );

      res.set({
        'Content-Type': 'application/pdf',
        'Content-Disposition':
          'attachment; filename="analytics-' +
          new Date().toISOString().split('T')[0] +
          '.pdf"',
        'Content-Length': buffer.length,
      });

      res.send(buffer);
    } catch (error) {
      res.status(500).json({
        message: 'Failed to generate PDF',
        error: error.message,
      });
    }
  }
}
