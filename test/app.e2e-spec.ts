import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { SensorData } from './../src/sensor/domain/sensor.entity';

const sensorIds = ['S1', 'S2', 'S3', 'S4', 'S5'];

interface WebSensor {
  id: string;
  deviceName: string;
  reading: { current: number; unit: string; isOptimal: boolean };
  status: { battery: string; lastSeen: string };
}

describe('AppController (e2e)', () => {
  let app: INestApplication<App>;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  it('/ (GET)', () => {
    return request(app.getHttpServer())
      .get('/')
      .expect(200)
      .expect('Hello World!');
  });

  it('/sensor/mobile/dashboard hanya mengirim ringkasan', () => {
    return request(app.getHttpServer())
      .get('/sensor/mobile/dashboard')
      .expect(200)
      .expect([
        { id: 'S1', v: 28.5, u: '°C', st: 'OK', batt: 'GOOD' },
        { id: 'S2', v: 24.5, u: '°C', st: 'OK', batt: 'GOOD' },
        { id: 'S3', v: 1012, u: 'hPa', st: 'WARN', batt: 'GOOD' },
        { id: 'S4', v: 88.2, u: '°C', st: 'WARN', batt: 'GOOD' },
        { id: 'S5', v: 12, u: '%', st: 'OK', batt: 'GOOD' },
      ]);
  });

  it('/sensor/web/analytics mengirim detail dengan timestamp ISO', async () => {
    const response = await request(app.getHttpServer())
      .get('/sensor/web/analytics')
      .expect(200);

    const sensors = response.body as WebSensor[];
    expect(sensors.map((sensor) => sensor.id)).toEqual(sensorIds);
    expect(sensors[0]).toEqual({
      id: 'S1',
      deviceName: 'DHT22-V2',
      reading: { current: 28.5, unit: '°C', isOptimal: true },
      status: { battery: '85%', lastSeen: expect.any(String) },
    });
    const mobile = await request(app.getHttpServer())
      .get('/sensor/mobile/dashboard')
      .expect(200);
    expect(
      sensors.map(({ id, reading, status }) => ({
        id,
        v: reading.current,
        u: reading.unit,
        st: reading.isOptimal ? 'OK' : 'WARN',
        batt: Number.parseInt(status.battery, 10) < 20 ? 'LOW' : 'GOOD',
      })),
    ).toEqual(mobile.body);
    for (const { status } of sensors) {
      expect(new Date(status.lastSeen).toISOString()).toBe(status.lastSeen);
    }
  });

  it('perubahan aturan domain tercermin di kedua endpoint sensor', async () => {
    jest.spyOn(SensorData.prototype, 'isNormal').mockImplementation(function (
      this: SensorData,
    ) {
      return this.value >= 10 && this.value <= 25;
    });
    jest.spyOn(SensorData.prototype, 'isBatteryCritical').mockReturnValue(true);

    await request(app.getHttpServer())
      .get('/sensor/mobile/dashboard')
      .expect(200)
      .expect(({ body }) => {
        expect(body).toContainEqual({
          id: 'S1',
          v: 28.5,
          u: '°C',
          st: 'WARN',
          batt: 'LOW',
        });
      });
    await request(app.getHttpServer())
      .get('/sensor/web/analytics')
      .expect(200)
      .expect(({ body }) => {
        const sensors = body as WebSensor[];
        expect(sensors[0].reading.isOptimal).toBe(false);
        expect(sensors[1].reading.isOptimal).toBe(true);
      });
  });

  it('/light-control/mobile hanya mengirim status lampu', () => {
    return request(app.getHttpServer())
      .get('/light-control/mobile')
      .expect(200)
      .expect({ isOn: true });
  });

  it('/light-control/web menyertakan kecerahan lampu', () => {
    return request(app.getHttpServer())
      .get('/light-control/web')
      .expect(200)
      .expect({ isOn: true, brightness: 75 });
  });

  afterEach(async () => {
    jest.restoreAllMocks();
    await app.close();
  });
});
