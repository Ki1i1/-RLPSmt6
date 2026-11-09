import { Module } from '@nestjs/common';
import { SensorController } from './infrastructure/sensor.controller';
import { SensorService } from './sensor.service';

@Module({
  controllers: [SensorController],
  providers: [SensorService],
})
export class SensorModule {}
