import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:video_gen/core/app_export.dart';
import 'package:video_gen/core/environment/environment.dart';

class RecraftApi {
  final Dio _dio = Dio();

  Future<String> postData(String prompt) async {
    try {
      Response response = await _dio.post(
        "https://external.api.recraft.ai/v1/images/generations",
        data: {
          "prompt": prompt,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Environment.recraftToken}',
          },
        ),
      );
      print(response.data);
      return response.data?['data']?[0]['url'] ?? "";
    } on DioException catch (_) {
      throw ServerException();
    }
  }
}
