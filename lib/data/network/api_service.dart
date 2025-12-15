import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../../data/models/url_data.dart';

import 'package:html/parser.dart' show parse;

class ApiService {
  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  Future<UrlData> shorten(String provider, String longUrl) async {
    try {
      String? shortenedUrl;
      bool success = false;

      switch (provider) {
        case AppConstants.tinyUrl:
          shortenedUrl = await _simpleGet(AppConstants.tinyUrlBase, {
            'url': longUrl,
          });
          break;
        case AppConstants.chilpIt:
          shortenedUrl = await _simpleGet(AppConstants.chilpItBase, {
            'url': longUrl,
          });
          break;
        case AppConstants.clckRu:
          shortenedUrl = await _simpleGet(AppConstants.clckRuBase, {
            'url': longUrl,
          });
          break;
        case AppConstants.daGd:
          shortenedUrl = await _simpleGet(AppConstants.daGdBase, {
            'url': longUrl,
          });
          break;
        case AppConstants.isGd:
          shortenedUrl = await _simpleGet(AppConstants.isGdBase, {
            'format': 'simple',
            'url': longUrl,
          });
          break;
        case AppConstants.osdb:
          // OSDB might return HTML based on Kotlin code Jsoup.parse(data).selectFirst("label#surl")
          // Or it might be JSON if we change endpoint. But Kotlin code uses Jsoup.
          final response = await client.post(
            Uri.parse(AppConstants.osdbBase),
            body: jsonEncode({'url': longUrl}),
          );
          if (response.statusCode == 200 || response.statusCode == 201) {
            // In kotlin code: providers == Providers.osdb -> parse custom
            // Wait, Kotlin code says:
            // if(providers == Providers.osdb) { val doc = Jsoup.parse(data)... }
            // But the API call is `apiService.osdb(data)`.
            // Retofit `@POST("/") fun osdb(@Body data: Osdb): Call<String>`
            // Let's assume it returns HTML string.
            shortenedUrl = _parseOsdbResponse(response.body);
          }
          break;
        case AppConstants.cuttLy:
          // Cuttly returns JSON
          final response = await client.get(
            Uri.parse(
              "${AppConstants.cuttLyBase}?key=23cfc51f98e71afea0c6d454f084a255ffe16&short=$longUrl",
            ),
          );
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            // Kotlin: response.body()?.url?.shortLink
            // Cuttly response: { "url": { "status": 7, "fullLink": "...", "date": "...", "shortLink": "..." } }
            if (data['url'] != null && data['url']['shortLink'] != null) {
              shortenedUrl = data['url']['shortLink'];
            }
          }
          break;
      }

      if (shortenedUrl != null && shortenedUrl.isNotEmpty) {
        success = true;
      }

      return UrlData(
        provider: provider,
        originalUrl: longUrl,
        shortenedUrl: shortenedUrl,
        expandedUrl: longUrl, // Initially same
        success: success,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      return UrlData(
        provider: provider,
        originalUrl: longUrl,
        success: false,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  Future<String?> _simpleGet(
    String baseUrl,
    Map<String, String> queryParams,
  ) async {
    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    final response = await client.get(uri);

    if (response.statusCode == 200) {
      return response.body.trim();
    }
    return null;
  }

  String? _parseOsdbResponse(String html) {
    try {
      var document = parse(html);
      var element = document.querySelector("label#surl");
      if (element != null) {
        return element.text.replaceAll("Your shortened URL is:", "").trim();
      }
    } catch (e) {
      // Parsing error
    }
    return null;
  }
}
