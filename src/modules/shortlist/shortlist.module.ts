import {Module} from '@nestjs/common';
import {ShortListService} from './shortlist.service';
import {ShortListController} from './shortlist.controller';
import {PrismaService} from '../../common/prisma/prisma.service';

@Module({
  controllers: [ShortListController],
  providers: [ShortListService],
  exports: [ShortListService],
})
export class ShortListModule {}
