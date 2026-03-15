import {Module} from '@nestjs/common';
import {SalesController} from './sales.controller';
import {SalesService} from './sales.service';
import {ShortListModule} from '../shortlist/shortlist.module';
import {CashBoxModule} from '../cash-box/cash-box.module';

@Module({
  imports: [ShortListModule, CashBoxModule],
  controllers: [SalesController],
  providers: [SalesService],
  exports: [SalesService],
})
export class SalesModule {}
