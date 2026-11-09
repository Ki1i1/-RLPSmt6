import { Injectable } from '@nestjs/common';
import { SensorData } from './domain/sensor.entity';

@Injectable()
export class SensorService {
  // Simulasi data dari database atau perangkat IoT.
  private readonly mockData = new SensorData(
    'S001',
    28.5,
    '°C',
    'DHT22-V2',
    85,
    new Date(),
  );

  getSummaryForMobile() {
    return {
      v: this.mockData.value,
      u: this.mockData.unit,
      st: this.mockData.isNormal() ? 'OK' : 'WARN',
      batt: this.mockData.isBatteryCritical() ? 'LOW' : 'GOOD',
    };
  }

  getFullDetailsForWeb() {
    return {
      id: this.mockData.id,
      deviceName: this.mockData.deviceName,
      reading: {
        current: this.mockData.value,
        unit: this.mockData.unit,
        isOptimal: this.mockData.isNormal(),
      },
      status: {
        battery: `${this.mockData.batteryLevel}%`,
        lastSeen: this.mockData.timestamp.toISOString(),
      },
    };
  }
}
