import { IsEnum, IsNumber, IsOptional, IsString, Min } from 'class-validator';

export class CreateCashBoxEntryDto {
  @IsEnum(['MANUAL_IN', 'MANUAL_OUT'])
  entryType: 'MANUAL_IN' | 'MANUAL_OUT';

  @IsNumber()
  @Min(0.01)
  amount: number;

  @IsString()
  @IsOptional()
  note?: string;

  @IsString()
  @IsOptional()
  entryDate?: string;
}
