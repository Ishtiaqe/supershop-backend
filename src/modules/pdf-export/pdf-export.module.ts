import {Module} from '@nestjs/common';
import {PdfExportService} from './pdf-export.service';
import {PdfExportController} from './pdf-export.controller';
import {PrismaService} from '../../common/prisma/prisma.service';

@Module({
  controllers: [PdfExportController],
  providers: [PdfExportService],
  exports: [PdfExportService],
})
export class PdfExportModule {}
