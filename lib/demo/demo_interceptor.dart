import 'package:dio/dio.dart';

import '/demo/demo_data.dart';

class DemoInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final reply = DemoData.resolve(options);
    handler.resolve(
      Response<Object?>(
        requestOptions: options,
        data: reply.body,
        statusCode: reply.status,
      ),
    );
  }
}
