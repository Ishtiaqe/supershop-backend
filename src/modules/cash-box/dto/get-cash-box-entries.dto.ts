import {IsDateString, IsEnum, IsNumber, IsOptional, Min} from 'class-validator';
import {Type} from 'class-transformer';
import {CashBoxEntryType} from '@prisma/client';

export class GetCashBoxEntriesDto {
  @IsDateString()
  @IsOptional()
  startDate?: string;

  @IsDateString()
  @IsOptional()
  endDate?: string;

  @IsEnum(CashBoxEntryType)
  @IsOptional()
  entryType?: CashBoxEntryType;

  @IsNumber()
  @IsOptional()
  @Min(1)
  @Type(() => Number)
  page?: number = 1;

  @IsNumber()
  @IsOptional()
  @Min(1)
  @Type(() => Number)
  limit?: number = 50;
}
