import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

class TenorApi {
  final String apiKey = dotenv.env['TENOR_API_KEY']!;
  final String baseUrl = 'https://tenor.googleapis.com/v2';

  String buildUrl({required String type, String additionalParameters = ''}) =>
      '$baseUrl/$type?key=$apiKey&$additionalParameters';

  Future<Response> getFeatured({required String limit}) async {
    return await get(Uri.parse(
        buildUrl(type: 'featured', additionalParameters: 'limit=$limit')));
  }

  Future<Response> search(
          {required String search, required String limit}) async =>
      await get(Uri.parse(buildUrl(
          type: 'search', additionalParameters: 'q=$search&limit=$limit')));
}
