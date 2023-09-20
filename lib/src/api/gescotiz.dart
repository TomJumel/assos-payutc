import 'package:dio/dio.dart';
import 'package:payutc/compil.dart';
import 'package:payutc/src/api/nemopay.dart';
import 'package:payutc/src/membership.conf.dart';

class GesCotizApi {
  late Dio _dio;
  final NemoPayApi nemoPayApi;

  String get sessionId => nemoPayApi.sessionId;
  final String username;

  GesCotizApi(this.nemoPayApi, this.username) {
    _dio = Dio(
      BaseOptions(
        baseUrl: gesCotizUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-User-Token': sessionId,
        },
      ),
    );
    if (dioFineLogs) {
      _dio.interceptors.add(LogInterceptor(responseBody: true));
    }
  }

  Future<Map?> payMembership() async {
    try {
      return await _dio.post(
        'pay',
        data: {
          'username': username,
        },
      ).then((value) => value.data);
    } on DioException catch (e) {
      return e.response?.data;
    }
  }

  Future<bool> checkMembership() async {
    try {
      return await _dio.post(
        'check',
        data: {
          'username': username,
        },
      ).then((value) => value.statusCode == 200);
    } on DioException catch (_) {
      return false;
    }
  }
}
