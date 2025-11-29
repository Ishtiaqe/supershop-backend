import { IsString, IsNumber, IsOptional, IsEnum, IsNotEmpty, IsPositive, IsIn } from 'class-validator';
import { Type } from 'class-transformer';
import { ValidateIf } from 'class-validator';

export enum ProductTypeEnum {
  GENERAL = 'GENERAL',
  MEDICINE = 'MEDICINE',
}

export class CreateCatalogDto {
  @IsString()
  @IsNotEmpty()
  productName: string;

  @IsString()
  @IsNotEmpty()
  variantName: string;

  @IsString()
  @IsNotEmpty()
  sku: string;

  @Type(() => Number)
  @IsNumber()
  @IsPositive()
  retailPrice: number;

  @IsOptional()
  @ValidateIf((o) => o.description !== null)
  @IsOptional()
  @IsString()
  description?: string | null;

  @IsOptional()
  @IsEnum(ProductTypeEnum)
  productType?: ProductTypeEnum;

  @IsOptional()
  @ValidateIf((o) => o.genericName !== null)
  @IsString()
  genericName?: string | null;

  @IsOptional()
  @ValidateIf((o) => o.manufacturerName !== null)
  @IsString()
  manufacturerName?: string | null;
}

export class UpdateCatalogDto {
  @IsOptional()
  @IsString()
  variantName?: string;

  @IsOptional()
  @IsString()
  sku?: string;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  retailPrice?: number;

  @IsOptional()
  @IsString()
  productName?: string;

  @IsOptional()
  @ValidateIf((o) => o.description !== null)
  @IsOptional()
  @IsString()
  description?: string | null;

  @IsOptional()
  @IsEnum(ProductTypeEnum)
  productType?: ProductTypeEnum;

  @IsOptional()
  @ValidateIf((o) => o.genericName !== null)
  @IsString()
  genericName?: string | null;

  @IsOptional()
  @ValidateIf((o) => o.manufacturerName !== null)
  @IsString()
  manufacturerName?: string | null;
}

export default CreateCatalogDto;
