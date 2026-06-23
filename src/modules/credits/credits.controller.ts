import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { UserRole } from '../auth/dto/auth.dto';
import { CreditsService } from './credits.service';
import { CreateCreditPaymentDto } from './dto/credits.dto';

@ApiTags('Credits')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('credits')
export class CreditsController {
  constructor(private creditsService: CreditsService) {}

  @Get()
  @Roles(UserRole.OWNER, UserRole.EMPLOYEE)
  getCreditCustomers(@CurrentUser() user: any) {
    return this.creditsService.getCreditCustomers(user.tenantId);
  }

  @Get('summary')
  @Roles(UserRole.OWNER, UserRole.EMPLOYEE)
  getSummary(@CurrentUser() user: any) {
    return this.creditsService.getCreditSummary(user.tenantId);
  }

  @Get(':phone')
  @Roles(UserRole.OWNER, UserRole.EMPLOYEE)
  getCreditsByPhone(@CurrentUser() user: any, @Param('phone') phone: string) {
    return this.creditsService.getCreditsByPhone(user.tenantId, phone);
  }

  @Post(':saleId/payments')
  @Roles(UserRole.OWNER, UserRole.EMPLOYEE)
  recordPayment(
    @CurrentUser() user: any,
    @Param('saleId') saleId: string,
    @Body() dto: CreateCreditPaymentDto,
  ) {
    return this.creditsService.recordPayment(user.tenantId, user.id, saleId, dto);
  }
}
