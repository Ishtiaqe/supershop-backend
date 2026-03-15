import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Query,
  Req,
} from '@nestjs/common';
import { ExpensesService } from './expenses.service';
import {
  CreateExpenseCategoryDto,
  UpdateExpenseCategoryDto,
  CreateExpenseDto,
  UpdateExpenseDto,
  GetExpensesFilterDto,
} from './dto/expenses.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';

@ApiTags('Expenses')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('expenses')
export class ExpensesController {
  constructor(private readonly expensesService: ExpensesService) {}

  // --- Categories ---

  @Post('categories')
  @ApiOperation({ summary: 'Create a new expense category' })
  createCategory(@Req() req, @Body() dto: CreateExpenseCategoryDto) {
    return this.expensesService.createCategory(req.user.tenantId, dto);
  }

  @Get('categories')
  @ApiOperation({ summary: 'Get all expense categories for the tenant' })
  getCategories(@Req() req) {
    return this.expensesService.getCategories(req.user.tenantId);
  }

  @Patch('categories/:id')
  @ApiOperation({ summary: 'Update an expense category' })
  updateCategory(
    @Req() req,
    @Param('id') id: string,
    @Body() dto: UpdateExpenseCategoryDto,
  ) {
    return this.expensesService.updateCategory(req.user.tenantId, id, dto);
  }

  @Delete('categories/:id')
  @ApiOperation({ summary: 'Delete an expense category' })
  deleteCategory(@Req() req, @Param('id') id: string) {
    return this.expensesService.deleteCategory(req.user.tenantId, id);
  }

  // --- Expenses ---

  @Post()
  @ApiOperation({ summary: 'Create a new expense' })
  createExpense(@Req() req, @Body() dto: CreateExpenseDto) {
    return this.expensesService.createExpense(req.user.tenantId, req.user.id, dto);
  }

  @Get('summary')
  @ApiOperation({ summary: 'Get expenses summary (totals grouped by category)' })
  getExpenseSummary(@Req() req, @Query() filterDto: GetExpensesFilterDto) {
    return this.expensesService.getExpenseSummary(req.user.tenantId, filterDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get list of expenses with pagination and filtering' })
  getExpenses(@Req() req, @Query() filterDto: GetExpensesFilterDto) {
    return this.expensesService.getExpenses(req.user.tenantId, filterDto);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a single expense by ID' })
  getExpenseById(@Req() req, @Param('id') id: string) {
    return this.expensesService.getExpenseById(req.user.tenantId, id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update an expense' })
  updateExpense(@Req() req, @Param('id') id: string, @Body() dto: UpdateExpenseDto) {
    return this.expensesService.updateExpense(req.user.tenantId, id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete an expense' })
  deleteExpense(@Req() req, @Param('id') id: string) {
    return this.expensesService.deleteExpense(req.user.tenantId, id);
  }
}
