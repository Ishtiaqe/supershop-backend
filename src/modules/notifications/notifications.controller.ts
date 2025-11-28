import {Controller, Post, Body, UseGuards} from '@nestjs/common';
import {ApiTags, ApiOperation, ApiBearerAuth} from '@nestjs/swagger';
import {NotificationsService} from './notifications.service';
import {JwtAuthGuard} from '../auth/guards/jwt-auth.guard';
import {CurrentUser} from '../auth/decorators/current-user.decorator';

@ApiTags('Notifications')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('notifications')
export class NotificationsController {
  constructor(private notificationsService: NotificationsService) {}

  @Post('subscribe')
  @ApiOperation({summary: 'Subscribe to push notifications'})
  async subscribe(@CurrentUser() user: any, @Body() subscription: any) {
    return this.notificationsService.subscribe(user.id, subscription);
  }
}
