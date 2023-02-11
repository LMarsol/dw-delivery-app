import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dw9_delivery_app/app/core/exceptions/expire_token_exception.dart';
import 'package:dw9_delivery_app/app/core/global/global_context.dart';
import 'package:dw9_delivery_app/app/core/rest_client/custom_dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  final CustomDio dio;

  AuthInterceptor(this.dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final sp = await SharedPreferences.getInstance();
    final accessToken = sp.getString('accessToken');

    options.headers['Authorization'] = 'Bearer $accessToken';

    handler.next(options);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        if (err.requestOptions.path != '/auth/refresh') {
          await _refreshToken(err);
          await _retryRequest(err, handler);
        } else {
          GlobalContext.i.loginExpire();
        }
      } catch (e) {
        GlobalContext.i.loginExpire();
      }

      handler.next(err);
    } else {
      handler.next(err);
    }
  }

  Future<void> _refreshToken(DioError err) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final refreshToken = sp.getString('refreshToken');

      if (refreshToken == null) {
        return;
      }

      final result = await dio.auth().put(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      sp.setString('accessToken', result.data['access_token']);
      sp.setString('refreshToken', result.data['refresh_token']);
    } on DioError catch (e, s) {
      log('Erro ao realizar refresh token', error: e, stackTrace: s);
      throw ExpireTokenException();
    }
  }

  Future<void> _retryRequest(
    DioError err,
    ErrorInterceptorHandler handler,
  ) async {
    final reqOptions = err.requestOptions;

    final result = await dio.request(
      reqOptions.path,
      options: Options(
        headers: reqOptions.headers,
        method: reqOptions.method,
      ),
      data: reqOptions.data,
      queryParameters: reqOptions.queryParameters,
    );

    handler.resolve(Response(
      data: result.data,
      requestOptions: reqOptions,
      statusCode: result.statusCode,
      statusMessage: result.statusMessage,
    ));
  }
}
