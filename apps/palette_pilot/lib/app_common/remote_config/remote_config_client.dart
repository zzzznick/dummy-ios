import 'package:dio/dio.dart';

import 'remote_config.dart';

class RemoteConfigClient {
  RemoteConfigClient({
    required String endpoint,
    required RemoteConfigKeys keys,
    RemoteConfigKeys? fallbackKeys,
    Dio? dio,
  }) : _endpoint = endpoint,
       _keys = keys,
       _fallbackKeys = fallbackKeys,
       _dio = dio ?? Dio();

  final String _endpoint;
  final RemoteConfigKeys _keys;
  final RemoteConfigKeys? _fallbackKeys;
  final Dio _dio;

  Future<RemoteConfigItem?> fetchFirstItem() async {
    final response = await _dio.get<dynamic>(_endpoint);
    final data = response.data;
    if (data is List && data.isNotEmpty) {
      return RemoteConfigItem.tryFromDynamic(
        data.first,
        keys: _keys,
        fallbackKeys: _fallbackKeys,
      );
    }
    return null;
  }
}

