import {
  Controller,
  Get,
  Post,
  Param,
  Body,
  UseGuards,
  Query,
} from '@nestjs/common';
import {ApiTags, ApiOperation, ApiBearerAuth} from '@nestjs/swagger';
import {SalesService} from './sales.service';
import {JwtAuthGuard} from '../auth/guards/jwt-auth.guard';
import {RolesGuard} from '../auth/guards/roles.guard';
import {Roles} from '../auth/decorators/roles.decorator';
import {CurrentUser} from '../auth/decorators/current-user.decorator';
import {UserRole} from '../auth/dto/auth.dto';

@ApiTags('Sales')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('sales')
export class SalesController {
  constructor(private salesService: SalesService) {}
  // simple in-memory cache per tenant { tenantId: { cachedAt: number, data: any } }
  private static summaryCache: Record<string, { cachedAt: number; data: any }> = {};

  @Post()
  @Roles(UserRole.OWNER, UserRole.EMPLOYEE)
  @ApiOperation({summary: 'Create new sale'})
  async create(@CurrentUser() user: any, @Body() data: any) {
    return this.salesService.create(user.tenantId, user.id, data);
  }

  @Get()
  @Roles(UserRole.OWNER, UserRole.EMPLOYEE)
  @ApiOperation({summary: 'Get all sales'})
  async findAll(@CurrentUser() user: any) {
    return this.salesService.findAll(user.tenantId);
  }

  @Get('summary/today')
  @Roles(UserRole.OWNER, UserRole.EMPLOYEE)
  @ApiOperation({summary: "Get today's sales summary"})
  async getTodaySummary(@CurrentUser() user: any) {
    return this.salesService.getTodaySummary(user.tenantId);
  }

  @Get('statistics/overall')
  @Roles(UserRole.OWNER, UserRole.EMPLOYEE)
  @ApiOperation({summary: 'Get overall sales statistics'})
  async getOverallStatistics(@CurrentUser() user: any) {
    return this.salesService.getOverallStatistics(user.tenantId);
  }

  @Get('analytics/asset-value')
  @Roles(UserRole.OWNER, UserRole.EMPLOYEE)
  @ApiOperation({summary: 'Get total asset value'})
  async getAssetValue(@CurrentUser() user: any) {
    return this.salesService.getAssetValue(user.tenantId);
  }

  @Get('analytics/graphs')
  @Roles(UserRole.OWNER, UserRole.EMPLOYEE)
  @ApiOperation({summary: 'Get graph data'})
  async getGraphData(
    @CurrentUser() user: any,
    @Query('period') period?: string
  ) {
    return this.salesService.getGraphData(user.tenantId, period);
  }

  @Get('analytics/summary')
  @Roles(UserRole.OWNER, UserRole.EMPLOYEE)
  @ApiOperation({summary: 'Get analytics summary (orders, revenue, profit, asset value)'})
  async getAnalyticsSummary(@CurrentUser() user: any) {
    const tenant = user.tenantId;
    const now = Date.now();
    const TTL = 30 * 1000; // 30 seconds

    const cacheEntry = SalesController.summaryCache[tenant];
    if (cacheEntry && now - cacheEntry.cachedAt < TTL) {
      return cacheEntry.data;
    }

    const stats = await this.salesService.getOverallStatistics(tenant);
    const asset = await this.salesService.getAssetValue(tenant);

    const response = { ...stats, ...asset };
    SalesController.summaryCache[tenant] = { cachedAt: now, data: response };
    return response;
  }

  @Get(':id')
  @Roles(UserRole.OWNER, UserRole.EMPLOYEE)
  @ApiOperation({summary: 'Get sale by ID'})
  async findOne(@Param('id') id: string, @CurrentUser() user: any) {
    return this.salesService.findOne(id, user.tenantId);
  }
}
