import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { LightControlModule } from './light-control/light-control.module';
import { SensorModule } from './sensor/sensor.module';

@Module({
  imports: [SensorModule, LightControlModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
