abstract class BaseApiService {
  Future<dynamic> getApi(String url);

  Future<dynamic> postApi(String url, dynamic data);

  Future<dynamic> pacthApi(String url, dynamic data);

  Future<dynamic> putApi(String url, dynamic data);

  Future<dynamic> deleteApi(String url, dynamic data);

  Future<dynamic> postMultipartApi(String url, Map<String, dynamic> data, Map<String, String> files);
}
