import { Controller, Get, Post, Put, Delete, Param, Body, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { CatalogService } from './catalog.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { UserRole } from '../auth/dto/auth.dto';

@ApiTags('Catalog')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('catalog')
export class CatalogController {
  constructor(private catalogService: CatalogService) { }

  @Get('search')
  @Roles(UserRole.OWNER, UserRole.EMPLOYEE)
  @ApiOperation({ summary: 'Search catalog items for autocomplete' })
  async search(@CurrentUser() user: any, @Query('q') query: string) {
    return this.catalogService.searchCatalog(user.tenantId, query);
  }

  @Get()
  @Roles(UserRole.OWNER, UserRole.EMPLOYEE)
  @ApiOperation({ summary: 'Get all catalog items' })
  async getAllItems(@CurrentUser() user: any) {
    return this.catalogService.getCatalogItems(user.tenantId);
  }

  @Post()
  @Roles(UserRole.OWNER)
  @ApiOperation({ summary: 'Create new catalog item' })
  async create(@Body() data: any) {
    return this.catalogService.createCatalogItem(data);
  }

  @Put(':id')
  @Roles(UserRole.OWNER)
  @ApiOperation({ summary: 'Update catalog item' })
  async update(@Param('id') id: string, @Body() data: any) {
    return this.catalogService.updateCatalogItem(id, data);
  }

  @Delete(':id')
  @Roles(UserRole.OWNER)
  @ApiOperation({ summary: 'Delete catalog item' })
  async delete(@Param('id') id: string) {
    return this.catalogService.deleteCatalogItem(id);
  }

  // ===== Categories =====

  @Get('categories')
  @Roles(UserRole.OWNER, UserRole.EMPLOYEE)
  @ApiOperation({ summary: 'Get all categories' })
  async getCategories() {
    return this.catalogService.getAllCategories();
  }

  @Post('categories')
  @Roles(UserRole.OWNER)
  @ApiOperation({ summary: 'Create category' })
  async createCategory(@Body() data: { name: string }) {
    return this.catalogService.createCategory(data.name);
  }

  @Put('categories/:id')
  @Roles(UserRole.OWNER)
  @ApiOperation({ summary: 'Update category' })
  async updateCategory(@Param('id') id: string, @Body() data: { name: string }) {
    return this.catalogService.updateCategory(id, data.name);
  }

  @Delete('categories/:id')
  @Roles(UserRole.OWNER)
  @ApiOperation({ summary: 'Delete category' })
  async deleteCategory(@Param('id') id: string) {
    return this.catalogService.deleteCategory(id);
  }

  // ===== Brands =====

  @Get('brands')
  @Roles(UserRole.OWNER, UserRole.EMPLOYEE)
  @ApiOperation({ summary: 'Get all brands' })
  async getBrands() {
    return this.catalogService.getAllBrands();
  }

  @Post('brands')
  @Roles(UserRole.OWNER)
  @ApiOperation({ summary: 'Create brand' })
  async createBrand(@Body() data: { name: string }) {
    return this.catalogService.createBrand(data.name);
  }

  @Put('brands/:id')
  @Roles(UserRole.OWNER)
  @ApiOperation({ summary: 'Update brand' })
  async updateBrand(@Param('id') id: string, @Body() data: { name: string }) {
    return this.catalogService.updateBrand(id, data.name);
  }

  @Delete('brands/:id')
  @Roles(UserRole.OWNER)
  @ApiOperation({ summary: 'Delete brand' })
  async deleteBrand(@Param('id') id: string) {
    return this.catalogService.deleteBrand(id);
  }
}
