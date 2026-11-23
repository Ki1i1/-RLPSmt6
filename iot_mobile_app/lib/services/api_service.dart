import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;
}

class ApiService {
  ApiService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = (baseUrl ?? _defaultBaseUrl).replaceFirst(RegExp(r'/+$'), '');

  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const _timeout = Duration(seconds: 8);

  final http.Client _client;
  final String _baseUrl;

  static String get _defaultBaseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  Future<List<Map<String, dynamic>>> fetchMobileDashboard() async {
    final data = await _getJson('/sensor/mobile/dashboard');
    if (data is List && data.every((item) => item is Map<String, dynamic>)) {
      return List<Map<String, dynamic>>.from(data);
    }
    throw const ApiException('Format daftar sensor dari server tidak sesuai.');
  }

  Future<bool> fetchLightStatus() async {
    final data = await _getJson('/light-control/mobile');
    if (data case {'isOn': final bool isOn}) return isOn;
    throw const ApiException('Format status lampu dari server tidak sesuai.');
  }

  Future<Object?> _getJson(String path) async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl$path'))
          .timeout(_timeout);
      if (response.statusCode != 200) {
        throw ApiException('Server mengembalikan HTTP ${response.statusCode}.');
      }
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on TimeoutException {
      throw const ApiException('Waktu tunggu koneksi ke server habis.');
    } on http.ClientException {
      throw const ApiException('Tidak dapat terhubung ke server.');
    } on FormatException {
      throw const ApiException('Respons server bukan JSON yang valid.');
    }
  }

  void close() => _client.close();
}
