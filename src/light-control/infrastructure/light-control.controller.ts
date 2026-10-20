import { Controller, Get } from '@nestjs/common';
import { LightControlService } from '../application/light-control.service';

@Controller('light-control')
export class LightControlController {
  constructor(private readonly lightControlService: LightControlService) {}

  @Get('mobile')
  getMobileView() {
    return this.lightControlService.getMobileStatus();
  }

  @Get('web')
  getWebView() {
    return this.lightControlService.getWebStatus();
  }
}
