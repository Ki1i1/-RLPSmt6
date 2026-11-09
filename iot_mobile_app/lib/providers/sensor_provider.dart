import 'package:flutter/foundation.dart';

/// Snapshot sensor. Perubahan hanya dilakukan melalui [SensorProvider].
@immutable
class Sensor {
  const Sensor({
    required this.id,
    required this.name,
    required this.value,
    required this.unit,
    required this.state,
  });

  final String id;
  final String name;
  final double value;
  final String unit;
  final String state;
}

class SensorProvider extends ChangeNotifier {
  static const _initialSensors = [
    Sensor(
      id: 'S1',
      name: 'Ambient Temp',
      value: 24.5,
      unit: '°C',
      state: 'OK',
    ),
    Sensor(
      id: 'S2',
      name: 'Core Heat',
      value: 30.2,
      unit: '°C',
      state: 'WARNING',
    ),
  ];

  List<Sensor> _sensors = List.of(_initialSensors);
  bool _isLightOn = false;

  List<Sensor> get sensors => List.unmodifiable(_sensors);
  bool get isLightOn => _isLightOn;

  void updateTemperature(String id, double newValue) {
    final index = _sensors.indexWhere((sensor) => sensor.id == id);
    if (index == -1) return;

    if (!newValue.isFinite) {
      throw ArgumentError.value(newValue, 'newValue', 'Suhu harus terhingga.');
    }

    final sensor = _sensors[index];
    if (sensor.value == newValue) return;

    final status = newValue > 40
        ? 'DANGER'
        : newValue > 30
        ? 'WARNING'
        : 'OK';

    _sensors[index] = Sensor(
      id: sensor.id,
      name: sensor.name,
      value: newValue,
      unit: sensor.unit,
      state: status,
    );
    notifyListeners();
  }

  void toggleLight() {
    _isLightOn = !_isLightOn;
    notifyListeners();
  }

  void resetSimulation() {
    var sensorsChanged = false;
    for (var index = 0; index < _sensors.length; index++) {
      if (_sensors[index].value != _initialSensors[index].value) {
        sensorsChanged = true;
        break;
      }
    }
    if (!sensorsChanged && !_isLightOn) return;

    _sensors = List.of(_initialSensors);
    _isLightOn = false;
    notifyListeners();
  }
}
