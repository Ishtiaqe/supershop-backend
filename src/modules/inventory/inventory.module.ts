import {Module} from '@nestjs/common';
import {InventoryController} from './inventory.controller';
import {InventoryService} from './inventory.service';
import {ShortListModule} from '../shortlist/shortlist.module';
import {CashBoxModule} from '../cash-box/cash-box.module';

@Module({
  imports: [ShortListModule, CashBoxModule],
  controllers: [InventoryController],
  providers: [InventoryService],
  exports: [InventoryService],
})
export class InventoryModule {}
