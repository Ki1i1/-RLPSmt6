export class SensorData {
  constructor(
    public readonly id: string,
    public value: number,
    public unit: string,
    public deviceName: string,
    public batteryLevel: number,
    public timestamp: Date,
  ) {}

  isNormal(): boolean {
    return this.value >= 10 && this.value <= 30;
  }

  isBatteryCritical(): boolean {
    return this.batteryLevel < 20;
  }
}
