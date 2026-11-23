import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:iot_mobile_app/main.dart';
import 'package:iot_mobile_app/providers/sensor_provider.dart';
import 'package:iot_mobile_app/services/api_service.dart';
import 'package:iot_mobile_app/widgets/status_card.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('dashboard API memuat, mempertahankan data, dan mencoba lagi', (
    tester,
  ) async {
    final initialResponse = Completer<void>();
    final requests = <String>[];
    var failSensors = false;
    var isLightOn = true;
    var temperature = 28.5;
    final api = ApiService(
      baseUrl: 'http://modul6.test/',
      client: MockClient((request) async {
        final path = request.url.path;
        requests.add(path);
        expect(request.method, 'GET');
        expect(request.url.host, 'modul6.test');
        await initialResponse.future;

        if (path == '/light-control/mobile') {
          return http.Response(jsonEncode({'isOn': isLightOn}), 200);
        }
        expect(path, '/sensor/mobile/dashboard');
        if (failSensors) return http.Response('', 503);
        return http.Response.bytes(
          utf8.encode(
            jsonEncode([
              {'id': 'S1', 'v': temperature, 'u': '°C', 'st': 'WARN'},
              {'id': 'S3', 'v': 1012, 'u': 'hPa', 'st': 'OK'},
            ]),
          ),
          200,
        );
      }),
    );
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => SensorProvider.connected(apiService: api),
        child: const MyApp(),
      ),
    );
    await tester.pump();

    final refresh = find.text('REFRESH DARI API');
    final refreshButton = find.ancestor(
      of: refresh,
      matching: find.byWidgetPredicate((widget) => widget is FilledButton),
    );
    final sensor = find.byKey(const ValueKey('S1'));
    final lamp = find.byKey(const ValueKey('light-switch'));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(tester.widget<FilledButton>(refreshButton).onPressed, isNull);
    expect(
      requests,
      unorderedEquals(['/sensor/mobile/dashboard', '/light-control/mobile']),
    );

    initialResponse.complete();
    await tester.pumpAndSettle();
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(tester.widget<StatusCard>(sensor).value, 28.5);
    expect(tester.widget<StatusCard>(sensor).unit, '°C');
    expect(tester.widget<StatusCard>(sensor).status, 'WARNING');
    expect(find.text('2 sensor · Data BFF'), findsOneWidget);
    expect(find.text('Lampu ON'), findsOneWidget);
    expect(tester.widget<Switch>(lamp).value, isTrue);
    expect(tester.widget<Switch>(lamp).onChanged, isNull);
    expect(find.byKey(const ValueKey('overheat-button')), findsNothing);

    failSensors = true;
    isLightOn = false;
    await tester.tap(refresh);
    await tester.pumpAndSettle();
    expect(find.text('Sensor: Server mengembalikan HTTP 503.'), findsOneWidget);
    expect(tester.widget<StatusCard>(sensor).value, 28.5);
    expect(tester.widget<Switch>(lamp).value, isFalse);

    failSensors = false;
    temperature = 29.25;
    await tester.tap(refresh);
    await tester.pumpAndSettle();
    expect(find.textContaining('HTTP 503'), findsNothing);
    expect(tester.widget<StatusCard>(sensor).value, 29.25);
    expect(requests, hasLength(6));
  });
}
