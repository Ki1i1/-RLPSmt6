import 'package:flutter/foundation.dart';

import '../services/api_service.dart';

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

  factory Sensor.fromApi(Map<String, dynamic> data) {
    if (data
        case {
          'id': final String id,
          'v': final num value,
          'u': final String unit,
          'st': final String state,
        }
        when value.isFinite) {
      return Sensor(
        id: id,
        name: id,
        value: value.toDouble(),
        unit: unit,
        state: state == 'WARN' ? 'WARNING' : state,
      );
    }
    throw const ApiException(
      'Format pembacaan sensor dari server tidak sesuai.',
    );
  }

  final String id;
  final String name;
  final double value;
  final String unit;
  final String state;
}

class SensorProvider extends ChangeNotifier {
  SensorProvider() : _apiService = null, _sensors = List.of(_initialSensors);

  SensorProvider.connected({ApiService? apiService})
    : _apiService = apiService ?? ApiService(),
      _sensors = [];

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

  final ApiService? _apiService;
  List<Sensor> _sensors;
  bool _isLightOn = false;
  bool _hasSensorData = false;
  bool _hasLightStatus = false;
  bool _isLoading = false;
  bool _disposed = false;
  String? _sensorError;
  String? _lightError;

  List<Sensor> get sensors => List.unmodifiable(_sensors);
  bool get isLightOn => _isLightOn;
  bool get isConnectedMode => _apiService != null;
  bool get hasSensorData => _hasSensorData;
  bool get hasLightStatus => _hasLightStatus;
  bool get isLoading => _isLoading;

  String? get errorMessage {
    final messages = [?_sensorError, ?_lightError];
    return messages.isEmpty ? null : messages.join('\n');
  }

  Future<void> fetchAndSyncData() async {
    final api = _apiService;
    if (api == null || _isLoading || _disposed) return;

    _isLoading = true;
    _sensorError = null;
    _lightError = null;
    notifyListeners();

    try {
      await Future.wait([_syncSensors(api), _syncLight(api)]);
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> _syncSensors(ApiService api) async {
    try {
      final data = await api.fetchMobileDashboard();
      _sensors = data.map(Sensor.fromApi).toList();
      _hasSensorData = true;
    } on ApiException catch (error) {
      _sensorError = 'Sensor: ${error.message}';
    }
  }

  Future<void> _syncLight(ApiService api) async {
    try {
      _isLightOn = await api.fetchLightStatus();
      _hasLightStatus = true;
    } on ApiException catch (error) {
      _lightError = 'Lampu: ${error.message}';
    }
  }

  void updateTemperature(String id, double newValue) {
    if (isConnectedMode) return;
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
    if (isConnectedMode) return;
    _isLightOn = !_isLightOn;
    notifyListeners();
  }

  void resetSimulation() {
    if (isConnectedMode) return;
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

  @override
  void dispose() {
    _disposed = true;
    _apiService?.close();
    super.dispose();
  }
}
