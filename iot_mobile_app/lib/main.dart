import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/sensor_provider.dart';
import 'shared/theme.dart';
import 'widgets/control_card.dart';
import 'widgets/status_card.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SensorProvider(),
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

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // watch berlangganan perubahan; read digunakan hanya saat tombol ditekan.
    final sensorProvider = context.watch<SensorProvider>();

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
                  child: const Text(
                    'Dashboard Monitoring Suhu',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.7,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pantau kondisi sensor dan kendalikan lampu dalam satu tampilan.',
                  style: TextStyle(color: Color(0xFF64748B), height: 1.6),
                ),
                const SizedBox(height: 24),
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
                      '${sensorProvider.sensors.length} sensor · Mode simulasi',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                ControlCard(
                  isOn: sensorProvider.isLightOn,
                  onToggle: () => context.read<SensorProvider>().toggleLight(),
                ),
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
                  onPressed: () => context
                      .read<SensorProvider>()
                      .updateTemperature('S1', 45),
                  icon: const Icon(Icons.thermostat_rounded),
                  label: const Text('SIMULASI OVERHEAT (S1)'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  key: const ValueKey('warning-button'),
                  onPressed: () => context
                      .read<SensorProvider>()
                      .updateTemperature('S1', 35),
                  child: const Text('Simulasi peringatan (35°C)'),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  key: const ValueKey('reset-button'),
                  onPressed: () =>
                      context.read<SensorProvider>().resetSimulation(),
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Reset simulasi'),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                const Text(
                  'SensorNodes · Flutter · Modul 5\n'
                  'Data simulasi · Belum terhubung ke perangkat IoT',
                  style: TextStyle(
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
