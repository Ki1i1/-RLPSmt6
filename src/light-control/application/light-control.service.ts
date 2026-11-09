import { Injectable } from '@nestjs/common';
import { LightStatus } from '../domain/light-status.entity';

@Injectable()
export class LightControlService {
  private readonly mockStatus = new LightStatus(true, 75);

  getMobileStatus() {
    return { isOn: this.mockStatus.isOn };
  }

  getWebStatus() {
    return {
      isOn: this.mockStatus.isOn,
      brightness: this.mockStatus.brightness,
    };
  }
}
