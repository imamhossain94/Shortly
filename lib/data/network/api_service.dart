import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
      final prefs = await SharedPreferences.getInstance();

      switch (provider) {
        case AppConstants.tinyUrl:
          final token = prefs.getString('tinyurl_api_token') ?? '';
          if (token.isNotEmpty) {
            // Use modern authenticated API
            final response = await client.post(
              Uri.parse("https://api.tinyurl.com/create"),
              headers: {
                'accept': 'application/json',
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({'url': longUrl}),
            );
            if (response.statusCode == 200 || response.statusCode == 201) {
              final data = jsonDecode(response.body);
              if (data['data'] != null && data['data']['tiny_url'] != null) {
                shortenedUrl = data['data']['tiny_url'];
              }
            } else {
              final data = jsonDecode(response.body);
              final errors = data['errors'] as List?;
              throw Exception(errors != null && errors.isNotEmpty ? errors.first : "TinyURL API Error (${response.statusCode})");
            }
          } else {
            // Fall back to legacy api-create.php
            shortenedUrl = await _simpleGet(AppConstants.tinyUrlBase, {
              'url': longUrl,
            });
          }
          break;
        case AppConstants.cleanUri:
          final response = await client.post(
            Uri.parse(AppConstants.cleanUriBase),
            body: {'url': longUrl},
          );
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['result_url'] != null) {
              shortenedUrl = data['result_url'];
            }
          }
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
          final response = await client.post(
            Uri.parse(AppConstants.osdbBase),
            body: jsonEncode({'url': longUrl}),
          );
          if (response.statusCode == 200 || response.statusCode == 201) {
            shortenedUrl = _parseOsdbResponse(response.body);
          }
          break;
        case AppConstants.cuttLy:
          final customKey = prefs.getString('cuttly_api_key') ?? '';
          final apiKey = customKey.isNotEmpty ? customKey : "23cfc51f98e71afea0c6d454f084a255ffe16";
          // Cuttly returns JSON
          final response = await client.get(
            Uri.parse(
              "${AppConstants.cuttLyBase}?key=$apiKey&short=$longUrl",
            ),
          );
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['url'] != null) {
              final status = data['url']['status'];
              if (status == 7) {
                if (data['url']['shortLink'] != null) {
                  shortenedUrl = data['url']['shortLink'];
                }
              } else {
                String errMsg = "Cutt.ly Error";
                if (status == 1) errMsg = "The shortened link is the same as the source link.";
                if (status == 2) errMsg = "The entered link is not a valid URL.";
                if (status == 3) errMsg = "The preferred alias is already taken.";
                if (status == 4) errMsg = "Invalid API Key. Please check your Cutt.ly settings.";
                if (status == 5) errMsg = "Request limit reached or invalid URL.";
                throw Exception(errMsg);
              }
            }
          }
          break;
        case AppConstants.bitLy:
          final token = prefs.getString('bitly_api_token') ?? '';
          if (token.isEmpty) {
            throw Exception("Bit.ly Access Token is not set. Please configure it in settings.");
          }
          final response = await client.post(
            Uri.parse(AppConstants.bitLyBase),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'long_url': longUrl,
            }),
          );
          if (response.statusCode == 200 || response.statusCode == 201) {
            final data = jsonDecode(response.body);
            if (data['link'] != null) {
              shortenedUrl = data['link'];
            }
          } else {
            final data = jsonDecode(response.body);
            final message = data['message'] ?? "Bit.ly API Error (${response.statusCode})";
            final description = data['description'] != null ? ": ${data['description']}" : "";
            throw Exception("$message$description");
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
