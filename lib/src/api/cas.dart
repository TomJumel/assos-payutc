import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:payutc/src/env.dart' as env;
import 'package:sentry_dio/sentry_dio.dart';

class CasApi {
  late Dio client;

  CasApi() {
    client = Dio(BaseOptions(baseUrl: env.casUrl));
    client.interceptors.add(
      RetryInterceptor(
        dio: client,
        retryEvaluator: (error, at) =>
            error.response != null &&
            error.response!.statusCode == 401 &&
            at < 3,
      ),
    );
    client.addSentry();
  }

  Future<String> reConnectUser(String? ticket) async {
    if (ticket == null) throw "User not already connected";
    try {
      final response = await client.post(
        "v1/tickets/$ticket",
        data: {"service": env.nemoPayUrl},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.plain,
        ),
      );
      return response.data;
    } on DioException {
      rethrow;
    }
  }

  Future<String> connectUser(String user, String pass) async {
    try {
      final response = await client.post(
        "v1/tickets/",
        data: {"username": user, "password": pass},
        options: Options(
            contentType: Headers.formUrlEncodedContentType,
            responseType: ResponseType.plain),
      );
      return _extractToken(response.headers.value("location"));
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response!.statusCode == 401) {
          throw "cas/bad-credentials";
        }
      }
    }
    throw "cas/auth-error";
  }

  String _extractToken(String? header) {
    if (header == null) throw "Header not found";
    return Uri.parse(header).pathSegments.last;
  }
}
