import 'package:dio/dio.dart';

import '../models/remote_config.dart';

class RemoteConfigService {
  RemoteConfigService({Dio? dio}) : _dio = dio ?? Dio();

  static const String defaultEndpoint =
      'https://680dea93c47cb8074d9187d5.mockapi.io/testtestaaa';

  final Dio _dio;

  Future<RemoteConfigItem?> fetchFirstItem({
    String endpoint = defaultEndpoint,
  }) async {
    final response = await _dio.get<dynamic>(endpoint);
    final data = response.data;
    if (data is List && data.isNotEmpty) {
      return RemoteConfigItem.tryFromDynamic(data.first);
    }
    return null;
  }
}
