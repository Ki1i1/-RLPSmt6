import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iot_mobile_app/main.dart';
import 'package:iot_mobile_app/providers/sensor_provider.dart';
import 'package:iot_mobile_app/shared/theme.dart';
import 'package:iot_mobile_app/widgets/control_card.dart';
import 'package:iot_mobile_app/widgets/status_card.dart';
import 'package:provider/provider.dart';

Future<SensorProvider> pumpDashboard(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  final provider = SensorProvider();
  await tester.pumpWidget(
    ChangeNotifierProvider(create: (_) => provider, child: const MyApp()),
  );
  await tester.pumpAndSettle();
  return provider;
}

Future<void> showWidget(
  WidgetTester tester,
  Finder finder, {
  double scrollDelta = 200,
}) async {
  await tester.scrollUntilVisible(
    finder,
    scrollDelta,
    scrollable: find.byType(Scrollable).first,
    maxScrolls: 30,
  );
  await tester.pumpAndSettle();
}

Color statusBorderColor(WidgetTester tester, Finder card) {
  final box = tester.widget<DecoratedBox>(
    find.descendant(of: card, matching: find.byType(DecoratedBox)).first,
  );
  final decoration = box.decoration as BoxDecoration;
  return (decoration.border! as Border).left.color;
}

Icon lampIcon(WidgetTester tester) {
  return tester.widget<Icon>(
    find.descendant(
      of: find.byType(ControlCard),
      matching: find.byIcon(Icons.lightbulb_rounded),
    ),
  );
}

void main() {
  testWidgets('dashboard menampilkan data awal dan lampu mati', (tester) async {
    await pumpDashboard(tester);

    expect(find.text('Dashboard Monitoring Suhu'), findsOneWidget);
    final firstCard = find.byKey(const ValueKey('S1'));
    final secondCard = find.byKey(const ValueKey('S2'));
    final firstSensor = tester.widget<StatusCard>(firstCard);
    final secondSensor = tester.widget<StatusCard>(secondCard);
    expect(firstSensor.label, 'Ambient Temp');
    expect(firstSensor.value, 24.5);
    expect(firstSensor.status, 'OK');
    expect(secondSensor.label, 'Core Heat');
    expect(secondSensor.value, 30.2);
    expect(secondSensor.status, 'WARNING');
    expect(statusBorderColor(tester, firstCard), AppColors.primary);
    expect(statusBorderColor(tester, secondCard), AppColors.warning);

    await showWidget(tester, find.byType(ControlCard));
    expect(find.text('Lampu OFF'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    expect(lampIcon(tester).color, isNot(AppColors.warning));
    expect(tester.takeException(), isNull);
  });

  testWidgets('tombol simulasi memperbarui pembacaan dan warna kartu', (
    tester,
  ) async {
    await pumpDashboard(tester);
    final firstCard = find.byKey(const ValueKey('S1'));
    final overheat = find.byKey(const ValueKey('overheat-button'));
    final warning = find.byKey(const ValueKey('warning-button'));

    await showWidget(tester, overheat);
    await tester.tap(overheat);
    await tester.pumpAndSettle();
    await showWidget(tester, firstCard, scrollDelta: -200);
    expect(tester.widget<StatusCard>(firstCard).value, 45);
    expect(tester.widget<StatusCard>(firstCard).status, 'DANGER');
    expect(statusBorderColor(tester, firstCard), AppColors.danger);
    expect(
      find.descendant(of: firstCard, matching: find.text('45.0')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: firstCard, matching: find.text('Kritis')),
      findsOneWidget,
    );

    await showWidget(tester, warning);
    await tester.tap(warning);
    await tester.pumpAndSettle();
    await showWidget(tester, firstCard, scrollDelta: -200);
    expect(tester.widget<StatusCard>(firstCard).value, 35);
    expect(tester.widget<StatusCard>(firstCard).status, 'WARNING');
    expect(statusBorderColor(tester, firstCard), AppColors.warning);
    expect(
      find.descendant(of: firstCard, matching: find.text('Peringatan')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('switch reaktif dan reset mengembalikan sensor serta lampu', (
    tester,
  ) async {
    final provider = await pumpDashboard(tester);
    final lightSwitch = find.byKey(const ValueKey('light-switch'));
    await showWidget(tester, lightSwitch);

    await tester.tap(lightSwitch);
    await tester.pumpAndSettle();
    expect(find.text('Lampu ON'), findsOneWidget);
    expect(tester.widget<Switch>(lightSwitch).value, isTrue);
    expect(lampIcon(tester).color, AppColors.warning);

    await tester.tap(lightSwitch);
    await tester.pumpAndSettle();
    expect(find.text('Lampu OFF'), findsOneWidget);
    expect(lampIcon(tester).color, isNot(AppColors.warning));

    await tester.tap(lightSwitch);
    await tester.pumpAndSettle();
    provider.updateTemperature('S2', 44);
    final overheat = find.byKey(const ValueKey('overheat-button'));
    await showWidget(tester, overheat);
    await tester.tap(overheat);
    await tester.pumpAndSettle();
    expect(
      provider.sensors.every((sensor) => sensor.state == 'DANGER'),
      isTrue,
    );

    final reset = find.byKey(const ValueKey('reset-button'));
    await showWidget(tester, reset);
    await tester.tap(reset);
    await tester.pumpAndSettle();
    await showWidget(tester, find.byType(ControlCard), scrollDelta: -200);
    expect(find.text('Lampu OFF'), findsOneWidget);
    expect(tester.widget<Switch>(lightSwitch).value, isFalse);
    expect(lampIcon(tester).color, isNot(AppColors.warning));

    final firstCard = find.byKey(const ValueKey('S1'));
    await showWidget(tester, firstCard, scrollDelta: -200);
    expect(tester.widget<StatusCard>(firstCard).value, 24.5);
    expect(tester.widget<StatusCard>(firstCard).status, 'OK');
    final secondCard = find.byKey(const ValueKey('S2'));
    expect(tester.widget<StatusCard>(secondCard).value, 30.2);
    expect(tester.widget<StatusCard>(secondCard).status, 'WARNING');
    expect(tester.takeException(), isNull);
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets('layout 320px tetap dapat digunakan pada skala teks $scale', (
      tester,
    ) async {
      await pumpDashboard(tester, size: const Size(320, 844), textScale: scale);
      expect(tester.takeException(), isNull);

      for (final key in [
        'S1',
        'S2',
        'light-switch',
        'overheat-button',
        'warning-button',
        'reset-button',
      ]) {
        final widget = find.byKey(ValueKey(key));
        await showWidget(tester, widget, scrollDelta: 140);
        expect(widget.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets(
    'kartu menerima WARN dan menampilkan status asing secara netral',
    (tester) async {
      Future<void> pumpCard(String status) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SizedBox(
                width: 320,
                child: StatusCard(
                  label: 'Sensor uji',
                  value: 35,
                  unit: '°C',
                  status: status,
                ),
              ),
            ),
          ),
        );
      }

      await pumpCard('WARN');
      expect(find.text('Peringatan'), findsOneWidget);
      expect(find.text('ACTION REQUIRED'), findsOneWidget);
      expect(
        statusBorderColor(tester, find.byType(StatusCard)),
        AppColors.warning,
      );

      await pumpCard('UNKNOWN');
      expect(find.text('Belum diketahui'), findsOneWidget);
      expect(find.text('STATUS UNAVAILABLE'), findsOneWidget);
      expect(
        statusBorderColor(tester, find.byType(StatusCard)),
        isNot(AppColors.primary),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
