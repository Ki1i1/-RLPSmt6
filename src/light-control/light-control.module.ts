import { Module } from '@nestjs/common';
import { LightControlService } from './application/light-control.service';
import { LightControlController } from './infrastructure/light-control.controller';

@Module({
  controllers: [LightControlController],
  providers: [LightControlService],
})
export class LightControlModule {}
