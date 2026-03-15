import { IsString, IsNotEmpty, IsOptional, IsNumber, IsDateString, IsUUID } from 'class-validator';
import { Type } from 'class-transformer';

export class CreateExpenseCategoryDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsOptional()
  description?: string;
}

export class UpdateExpenseCategoryDto {
  @IsString()
  @IsOptional()
  @IsNotEmpty()
  name?: string;

  @IsString()
  @IsOptional()
  description?: string;
}

export class CreateExpenseDto {
  @IsUUID()
  @IsNotEmpty()
  categoryId: string;

  @IsNumber()
  @Type(() => Number)
  @IsNotEmpty()
  amount: number;

  @IsString()
  @IsOptional()
  description?: string;

  @IsDateString()
  @IsOptional()
  expenseDate?: string;
}

export class UpdateExpenseDto {
  @IsUUID()
  @IsOptional()
  categoryId?: string;

  @IsNumber()
  @Type(() => Number)
  @IsOptional()
  amount?: number;

  @IsString()
  @IsOptional()
  description?: string;

  @IsDateString()
  @IsOptional()
  expenseDate?: string;
}

export class GetExpensesFilterDto {
  @IsDateString()
  @IsOptional()
  startDate?: string;

  @IsDateString()
  @IsOptional()
  endDate?: string;

  @IsUUID()
  @IsOptional()
  categoryId?: string;

  @IsString()
  @IsOptional()
  page?: string;

  @IsString()
  @IsOptional()
  limit?: string;
}
