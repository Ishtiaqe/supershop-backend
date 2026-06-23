import {IsNumber, IsOptional, IsString, Min} from 'class-validator';

export class CreateCreditPaymentDto {
  @IsNumber()
  @Min(0.01)
  amount: number;

  @IsString()
  @IsOptional()
  note?: string;
}
