import { Controller, Get } from '@nestjs/common';
import { SensorService } from '../sensor.service';

@Controller('sensor')
export class SensorController {
  constructor(private readonly sensorService: SensorService) {}

  @Get('mobile/dashboard')
  getMobileView() {
    return this.sensorService.getSummaryForMobile();
  }

  @Get('web/analytics')
  getWebView() {
    return this.sensorService.getFullDetailsForWeb();
  }
}
