import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { SensorData } from './../src/sensor/domain/sensor.entity';

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
      .expect({ v: 28.5, u: '°C', st: 'OK', batt: 'GOOD' });
  });

  it('/sensor/web/analytics mengirim detail dengan timestamp ISO', async () => {
    const response = await request(app.getHttpServer())
      .get('/sensor/web/analytics')
      .expect(200);

    expect(response.body).toEqual({
      id: 'S001',
      deviceName: 'DHT22-V2',
      reading: { current: 28.5, unit: '°C', isOptimal: true },
      status: { battery: '85%', lastSeen: expect.any(String) },
    });
    const lastSeen = (response.body as { status: { lastSeen: string } }).status
      .lastSeen;
    expect(new Date(lastSeen).toISOString()).toBe(lastSeen);
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
      .expect({ v: 28.5, u: '°C', st: 'WARN', batt: 'LOW' });
    await request(app.getHttpServer())
      .get('/sensor/web/analytics')
      .expect(200)
      .expect(({ body }) => {
        expect(body.reading.isOptimal).toBe(false);
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
