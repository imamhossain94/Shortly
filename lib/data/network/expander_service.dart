import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import '../../data/models/url_data.dart';

class ExpanderService {
  final http.Client client;

  ExpanderService({http.Client? client}) : client = client ?? http.Client();

  Future<UrlData> expand(String shortUrl) async {
    try {
      final finalUrl = await _followRedirects(shortUrl);

      return UrlData(
        provider: null,
        originalUrl: shortUrl,
        shortenedUrl: shortUrl,
        expandedUrl: finalUrl,
        success: true,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      return UrlData(
        provider: null,
        originalUrl: shortUrl,
        shortenedUrl: shortUrl,
        expandedUrl: null,
        success: false,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  Future<String> _followRedirects(String url) async {
    String currentUrl = url;
    int redirectCount = 0;
    const int maxRedirects = 10;

    while (redirectCount < maxRedirects) {
      try {
        final request = http.Request('GET', Uri.parse(currentUrl))
          ..followRedirects = false
          ..headers['User-Agent'] =
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36';

        final streamedResponse = await client
            .send(request)
            .timeout(const Duration(seconds: 10));
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode >= 300 && response.statusCode < 400) {
          // HTTP Redirect
          final location = response.headers['location'];
          if (location != null && location.isNotEmpty) {
            currentUrl = _resolveUrl(currentUrl, location);
            redirectCount++;
            continue;
          } else {
            break;
          }
        } else if (response.statusCode == 200) {
          // Check for meta refresh or JS redirect
          final metaRefreshUrl = _extractMetaRefreshUrl(
            response.body,
            currentUrl,
          );
          if (metaRefreshUrl != null && metaRefreshUrl != currentUrl) {
            currentUrl = metaRefreshUrl;
            redirectCount++;
            continue;
          } else {
            break; // Reached final destination
          }
        } else {
          break; // Error or other status
        }
      } catch (e) {
        break; // Network error
      }
    }
    return currentUrl;
  }

  String _resolveUrl(String baseUrl, String location) {
    if (location.startsWith("http://") || location.startsWith("https://")) {
      return location;
    }
    final baseUri = Uri.parse(baseUrl);
    return baseUri.resolve(location).toString();
  }

  String? _extractMetaRefreshUrl(String html, String baseUrl) {
    try {
      final document = parse(html);

      // Meta Refresh
      final metaRefresh = document.querySelector("meta[http-equiv=refresh]");
      if (metaRefresh != null) {
        final content = metaRefresh.attributes['content'];
        if (content != null) {
          final urlMatch = RegExp(
            r"url=(.+)",
            caseSensitive: false,
          ).firstMatch(content);
          if (urlMatch != null) {
            String url = urlMatch.group(1)?.trim() ?? "";
            url = url.replaceAll("'", "").replaceAll('"', "");
            return _resolveUrl(baseUrl, url);
          }
        }
      }

      // JS Redirect
      final scripts = document.querySelectorAll("script");
      for (var script in scripts) {
        final content = script.text;
        final locationMatch = RegExp(
          r"""window\.location(?:\.href)?\s*=\s*['"]([^'"]+)['"]""",
        ).firstMatch(content);
        if (locationMatch != null) {
          final url = locationMatch.group(1);
          if (url != null) {
            return _resolveUrl(baseUrl, url);
          }
        }
      }
    } catch (e) {
      // Parse error
    }
    return null;
  }
}
