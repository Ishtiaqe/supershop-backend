import {Controller, Get, Param, Query} from '@nestjs/common';
import {ApiTags, ApiOperation} from '@nestjs/swagger';
import {MedicineService} from './medicine.service';

@ApiTags('Medicine')
@Controller('medicine')
export class MedicineController {
  constructor(private medicineService: MedicineService) {}

  @Get()
  @ApiOperation({summary: 'Get all medicines'})
  async findAll(@Query('search') search?: string) {
    return this.medicineService.findAll(search);
  }

  @Get(':id')
  @ApiOperation({summary: 'Get medicine by id'})
  async findOne(@Param('id') id: string) {
    return this.medicineService.findOne(id);
  }
}
