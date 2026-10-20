import { SensorData } from './sensor.entity';

describe('SensorData', () => {
  it.each([
    [9.9, false],
    [10, true],
    [28.5, true],
    [40, true],
    [40.1, false],
  ])('suhu %s menghasilkan status normal %s', (value, expected) => {
    const sensor = new SensorData(
      'S001',
      value,
      '°C',
      'DHT22-V2',
      85,
      new Date(),
    );

    expect(sensor.isNormal()).toBe(expected);
  });

  it.each([
    [19, true],
    [20, false],
    [85, false],
  ])('baterai %s menghasilkan status kritis %s', (batteryLevel, expected) => {
    const sensor = new SensorData(
      'S001',
      28.5,
      '°C',
      'DHT22-V2',
      batteryLevel,
      new Date(),
    );

    expect(sensor.isBatteryCritical()).toBe(expected);
  });
});
