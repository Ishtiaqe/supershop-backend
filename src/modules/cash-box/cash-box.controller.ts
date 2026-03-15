import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Query,
  Request,
  UseGuards,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CashBoxService } from './cash-box.service';
import { CreateCashBoxEntryDto } from './dto/create-cash-box-entry.dto';
import { GetCashBoxEntriesDto } from './dto/get-cash-box-entries.dto';

@UseGuards(JwtAuthGuard)
@Controller('cash-box')
export class CashBoxController {
  constructor(private readonly cashBoxService: CashBoxService) {}

  @Get('summary')
  getSummary(
    @Request() req,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    return this.cashBoxService.getSummary(req.user.tenantId, startDate, endDate);
  }

  @Get('entries')
  getEntries(@Request() req, @Query() dto: GetCashBoxEntriesDto) {
    return this.cashBoxService.getEntries(req.user.tenantId, dto);
  }

  @Post('entries')
  createEntry(@Request() req, @Body() dto: CreateCashBoxEntryDto) {
    return this.cashBoxService.createManualEntry(
      req.user.tenantId,
      req.user.id,
      dto,
    );
  }

  @Delete('entries/:id')
  deleteEntry(@Request() req, @Param('id') id: string) {
    return this.cashBoxService.deleteEntry(req.user.tenantId, id);
  }
}
