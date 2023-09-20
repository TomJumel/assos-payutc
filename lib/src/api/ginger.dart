import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:payutc/src/models/ginger_user_infos.dart';

import '../env.dart';

class Ginger {
  @Deprecated('Use getUserDetails() in [NemoPayApi] instead')
  static Future<GingerUserInfos> getUserInfos(String user, String key) async {
    try {
      return await Dio().get("$gingerUrl$user", queryParameters: {
        "key": key
      }).then((value) => GingerUserInfos.fromJson(value.data));
    } on DioError catch (e) {
      log(jsonEncode(e.response?.data));
      rethrow;
    }
  }
}
