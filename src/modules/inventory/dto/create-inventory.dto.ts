import {
  IsString,
  IsOptional,
  IsNumber,
  IsPositive,
  IsDateString,
  Min,
  ValidateIf,
  registerDecorator,
  ValidationOptions,
  ValidationArguments,
} from 'class-validator';
import {Type} from 'class-transformer';

// Custom validator to ensure retailPrice >= purchasePrice
function IsRetailPriceValid(validationOptions?: ValidationOptions) {
  return function (object: object, propertyName: string) {
    registerDecorator({
      name: 'isRetailPriceValid',
      target: object.constructor,
      propertyName: propertyName,
      options: validationOptions,
      validator: {
        validate(value: any, args: ValidationArguments) {
          const obj = args.object as any;
          const purchasePrice = obj.purchasePrice;
          const retailPrice = value;

          if (
            typeof purchasePrice !== 'number' ||
            typeof retailPrice !== 'number'
          ) {
            return true; // Let other validators handle type checking
          }

          return retailPrice >= purchasePrice;
        },
        defaultMessage(args: ValidationArguments) {
          return 'Retail price must be greater than or equal to purchase price';
        },
      },
    });
  };
}

export class CreateInventoryDto {
  @IsOptional()
  @IsString()
  variantId?: string;

  @IsOptional()
  @IsString()
  itemName?: string;

  @Type(() => Number)
  @IsNumber()
  @IsPositive({message: 'Quantity must be a positive number'})
  quantity: number;

  @Type(() => Number)
  @IsNumber()
  @Min(0, {message: 'Purchase price must be non-negative'})
  purchasePrice: number;

  @Type(() => Number)
  @IsNumber()
  @Min(0, {message: 'Retail price must be non-negative'})
  @IsRetailPriceValid({
    message: 'Retail price cannot be lower than purchase price',
  })
  retailPrice: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0, {message: 'Max discount must be non-negative'})
  maxDiscount?: number;

  @IsOptional()
  @IsDateString()
  expiryDate?: string;

  @IsOptional()
  @IsDateString()
  mfgDate?: string;

  @IsOptional()
  @IsString()
  batchNo?: string;

  @IsOptional()
  @IsString()
  productType?: string;

  @IsOptional()
  @IsString()
  genericName?: string;

  @IsOptional()
  @IsString()
  manufacturerName?: string;
}
