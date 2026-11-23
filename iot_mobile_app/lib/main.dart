import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/sensor_provider.dart';
import 'shared/theme.dart';
import 'widgets/control_card.dart';
import 'widgets/status_card.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SensorProvider.connected(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SensorNodes Controller',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SensorProvider>().fetchAndSyncData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sensorProvider = context.watch<SensorProvider>();
    final usesApi = sensorProvider.isConnectedMode;
    final lightCard = ControlCard(
      isOn: sensorProvider.isLightOn,
      hasStatus: !usesApi || sensorProvider.hasLightStatus,
      onToggle: usesApi ? null : sensorProvider.toggleLight,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('SensorNodes Controller'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'DASHBOARD',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: Color(0xFF15803D),
                  ),
                ),
                const SizedBox(height: 12),
                Semantics(
                  header: true,
                  child: Text(
                    usesApi
                        ? 'Dashboard Monitoring Sensor'
                        : 'Dashboard Monitoring Suhu',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.7,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  usesApi
                      ? 'Pantau pembacaan sensor dan status lampu dari server.'
                      : 'Pantau kondisi sensor dan kendalikan lampu dalam satu tampilan.',
                  style: const TextStyle(color: Color(0xFF64748B), height: 1.6),
                ),
                const SizedBox(height: 24),
                if (usesApi) ...[
                  FilledButton.icon(
                    onPressed: sensorProvider.isLoading
                        ? null
                        : sensorProvider.fetchAndSyncData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('REFRESH DARI API'),
                  ),
                  const SizedBox(height: 16),
                  if (sensorProvider.isLoading) ...[
                    const LinearProgressIndicator(
                      semanticsLabel: 'Memuat data dari server',
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (sensorProvider.errorMessage case final message?) ...[
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Color(0xFFB91C1C),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  lightCard,
                  const SizedBox(height: 24),
                ],
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    const Text(
                      'Ringkasan sensor',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${sensorProvider.sensors.length} sensor · ${usesApi ? 'Data BFF' : 'Mode simulasi'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (sensorProvider.hasSensorData &&
                    sensorProvider.sensors.isEmpty)
                  const Text('Belum ada pembacaan sensor.'),
                ...sensorProvider.sensors.map(
                  (sensor) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: StatusCard(
                      key: ValueKey(sensor.id),
                      label: sensor.name,
                      value: sensor.value,
                      unit: sensor.unit,
                      status: sensor.state,
                    ),
                  ),
                ),
                if (!usesApi) ...[
                  lightCard,
                  const SizedBox(height: 24),
                  Semantics(
                    header: true,
                    child: const Text(
                      'Simulasi sensor',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Normal: ≤ 30°C · Peringatan: > 30–40°C · Kritis: > 40°C',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    key: const ValueKey('overheat-button'),
                    onPressed: () => sensorProvider.updateTemperature('S1', 45),
                    icon: const Icon(Icons.thermostat_rounded),
                    label: const Text('SIMULASI OVERHEAT (S1)'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    key: const ValueKey('warning-button'),
                    onPressed: () => sensorProvider.updateTemperature('S1', 35),
                    child: const Text('Simulasi peringatan (35°C)'),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    key: const ValueKey('reset-button'),
                    onPressed: sensorProvider.resetSimulation,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text('Reset simulasi'),
                  ),
                ],
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'SensorNodes · Flutter · Modul ${usesApi ? '6' : '5'}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    height: 1.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
