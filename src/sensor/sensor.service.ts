import { Injectable } from '@nestjs/common';
import { SensorData } from './domain/sensor.entity';

@Injectable()
export class SensorService {
  // Simulasi data dari database atau perangkat IoT.
  private readonly mockData = [
    new SensorData('S1', 28.5, '°C', 'DHT22-V2', 85, new Date()),
    new SensorData('S2', 24.5, '°C', 'Ambient Temp', 85, new Date()),
    new SensorData('S3', 1012, 'hPa', 'Pressure', 85, new Date()),
    new SensorData('S4', 88.2, '°C', 'Core Heat', 85, new Date()),
    new SensorData('S5', 12, '%', 'Battery Level', 85, new Date()),
  ];

  getSummaryForMobile() {
    return this.mockData.map((sensor) => ({
      id: sensor.id,
      v: sensor.value,
      u: sensor.unit,
      st: sensor.isNormal() ? 'OK' : 'WARN',
      batt: sensor.isBatteryCritical() ? 'LOW' : 'GOOD',
    }));
  }

  getFullDetailsForWeb() {
    return this.mockData.map((sensor) => ({
      id: sensor.id,
      deviceName: sensor.deviceName,
      reading: {
        current: sensor.value,
        unit: sensor.unit,
        isOptimal: sensor.isNormal(),
      },
      status: {
        battery: `${sensor.batteryLevel}%`,
        lastSeen: sensor.timestamp.toISOString(),
      },
    }));
  }
}
