import 'package:dio/dio.dart';

import 'remote_config.dart';

class RemoteConfigClient {
  RemoteConfigClient({
    required String endpoint,
    Dio? dio,
  }) : _endpoint = endpoint,
       _dio = dio ?? Dio();

  final String _endpoint;
  final Dio _dio;

  Future<RemoteConfigItem?> fetchFirstItem() async {
    final response = await _dio.get<dynamic>(_endpoint);
    final data = response.data;
    if (data is List && data.isNotEmpty) {
      return RemoteConfigItem.tryFromDynamic(data.first);
    }
    return null;
  }
}

