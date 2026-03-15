import {Module} from '@nestjs/common';
import {SalesController} from './sales.controller';
import {SalesService} from './sales.service';
import {ShortListModule} from '../shortlist/shortlist.module';

@Module({
  imports: [ShortListModule],
  controllers: [SalesController],
  providers: [SalesService],
  exports: [SalesService],
})
export class SalesModule {}
