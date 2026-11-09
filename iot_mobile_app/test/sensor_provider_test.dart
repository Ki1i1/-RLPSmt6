import 'package:flutter_test/flutter_test.dart';
import 'package:iot_mobile_app/providers/sensor_provider.dart';

void main() {
  late SensorProvider provider;
  late int notifications;

  setUp(() {
    provider = SensorProvider();
    notifications = 0;
    provider.addListener(() => notifications++);
  });

  tearDown(() => provider.dispose());

  test('data awal memiliki status yang sesuai dengan suhu dan lampu mati', () {
    expect(provider.sensors.map((sensor) => sensor.id), ['S1', 'S2']);
    expect(provider.sensors.map((sensor) => sensor.value), [24.5, 30.2]);
    expect(provider.sensors.map((sensor) => sensor.state), ['OK', 'WARNING']);
    expect(provider.isLightOn, isFalse);
  });

  test('batas 30 dan 40 serta suhu negatif dinilai dengan benar', () {
    final readings = <double, String>{
      -5: 'OK',
      30: 'OK',
      30.01: 'WARNING',
      40: 'WARNING',
      40.01: 'DANGER',
      45: 'DANGER',
    };

    for (final reading in readings.entries) {
      provider.updateTemperature('S1', reading.key);
      expect(provider.sensors.first.value, reading.key);
      expect(provider.sensors.first.state, reading.value);
    }
    expect(notifications, readings.length);
  });

  test(
    'perubahan hanya memengaruhi sensor yang dipilih dan snapshot lama tetap',
    () {
      final before = provider.sensors;

      provider.updateTemperature('S1', 45);

      expect(provider.sensors.first.state, 'DANGER');
      expect(provider.sensors.last, same(before.last));
      expect(before.first.value, 24.5);
      expect(before.first.state, 'OK');
      expect(notifications, 1);
    },
  );

  test('ID tak dikenal dan nilai yang sama tidak memicu pembaruan UI', () {
    provider.updateTemperature('missing', 45);
    provider.updateTemperature('S1', 24.5);

    expect(provider.sensors.first.value, 24.5);
    expect(provider.sensors.last.value, 30.2);
    expect(notifications, 0);
  });

  test(
    'NaN dan infinity ditolak tanpa merusak state atau mengirim notifikasi',
    () {
      for (final value in [
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        expect(
          () => provider.updateTemperature('S1', value),
          throwsArgumentError,
        );
      }

      expect(provider.sensors.first.value, 24.5);
      expect(provider.sensors.first.state, 'OK');
      expect(notifications, 0);
    },
  );

  test('daftar sensor tidak dapat diubah dari luar provider', () {
    final sensors = provider.sensors;

    expect(() => sensors.clear(), throwsUnsupportedError);
    expect(() => sensors[0] = sensors[1], throwsUnsupportedError);
    expect(provider.sensors, hasLength(2));
    expect(notifications, 0);
  });

  test('lampu dapat dinyalakan dan dimatikan secara reaktif', () {
    provider.toggleLight();
    expect(provider.isLightOn, isTrue);
    expect(notifications, 1);

    provider.toggleLight();
    expect(provider.isLightOn, isFalse);
    expect(notifications, 2);
    expect(provider.sensors.first.value, 24.5);
  });

  test('reset memulihkan semua sensor dan lampu dengan satu notifikasi', () {
    provider.updateTemperature('S1', 45);
    provider.updateTemperature('S2', 20);
    provider.toggleLight();
    notifications = 0;

    provider.resetSimulation();

    expect(provider.sensors.map((sensor) => sensor.value), [24.5, 30.2]);
    expect(provider.sensors.map((sensor) => sensor.state), ['OK', 'WARNING']);
    expect(provider.isLightOn, isFalse);
    expect(notifications, 1);

    provider.resetSimulation();
    expect(notifications, 1);
  });

  test('reset pada state awal tidak memicu pembaruan UI', () {
    provider.resetSimulation();
    expect(notifications, 0);
  });
}
