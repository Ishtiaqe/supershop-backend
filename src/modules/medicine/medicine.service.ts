import {Injectable} from '@nestjs/common';
import {PrismaService} from '../../common/prisma/prisma.service';

@Injectable()
export class MedicineService {
  constructor(private prisma: PrismaService) {}

  async findAll(search?: string) {
    const where: any = {};
    if (search && search.length > 0) {
      where.OR = [
        {brandName: {contains: search, mode: 'insensitive'}},
        {generic: {genericName: {contains: search, mode: 'insensitive'}}},
        {
          manufacturer: {
            manufacturerName: {contains: search, mode: 'insensitive'},
          },
        },
        {strength: {contains: search, mode: 'insensitive'}},
        {dosageForm: {contains: search, mode: 'insensitive'}},
      ];
    }

    return this.prisma.medicine.findMany({
      where,
      include: {
        generic: true,
        manufacturer: true,
      },
      take: 100, // limit for performance
    });
  }

  async findOne(id: string) {
    return this.prisma.medicine.findUnique({
      where: {id},
      include: {
        generic: true,
        manufacturer: true,
      },
    });
  }
}
