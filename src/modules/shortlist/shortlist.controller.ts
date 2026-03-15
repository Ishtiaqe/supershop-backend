import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  UseGuards,
  Req,
  Query,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { JwtAuthGuard } from '../../modules/auth/guards/jwt-auth.guard';
import { ShortListService } from './shortlist.service';

@Controller('shortlist')
@UseGuards(JwtAuthGuard)
export class ShortListController {
  constructor(private shortListService: ShortListService) {}

  /**
   * Get all short list items for current tenant
   */
  @Get()
  async findAll(
    @Req() req,
    @Query('skip') skip?: string,
    @Query('take') take?: string,
    @Query('sortBy') sortBy?: 'quantity' | 'addedAt' | 'name',
    @Query('sortOrder') sortOrder?: 'asc' | 'desc',
    @Query('filterSlow') filterSlow?: string
  ) {
    return this.shortListService.findAll(req.user.tenantId, {
      skip: skip ? parseInt(skip) : 0,
      take: take ? parseInt(take) : 100,
      sortBy: sortBy || 'quantity',
      sortOrder: sortOrder || 'asc',
      filterSlow: filterSlow === 'true',
    });
  }

  /**
   * Get short list statistics
   */
  @Get('stats')
  async getStats(@Req() req) {
    return this.shortListService.getStats(req.user.tenantId);
  }

  /**
   * Get single short list item
   */
  @Get(':id')
  async findOne(@Req() req, @Param('id') id: string) {
    return this.shortListService.findOne(id, req.user.tenantId);
  }

  /**
   * Toggle item on/off short list
   */
  @Post(':inventoryId/toggle')
  async toggle(@Req() req, @Param('inventoryId') inventoryId: string) {
    return this.shortListService.toggle(
      inventoryId,
      req.user.tenantId,
      req.user.id
    );
  }

  /**
   * Remove item from short list
   */
  @Delete(':inventoryId')
  @HttpCode(HttpStatus.NO_CONTENT)
  async remove(@Req() req, @Param('inventoryId') inventoryId: string) {
    await this.shortListService.remove(inventoryId, req.user.tenantId);
  }

  /**
   * Batch add items (for quick operations)
   */
  @Post('batch-add')
  @HttpCode(HttpStatus.CREATED)
  async batchAdd(@Req() req, @Body('inventoryIds') inventoryIds: string[]) {
    const results = await Promise.all(
      inventoryIds.map((id) =>
        this.shortListService.toggle(id, req.user.tenantId, req.user.id)
      )
    );
    return {
      added: results.length,
      items: results,
    };
  }
}
