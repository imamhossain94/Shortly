import '../models/url_data.dart';
import '../db/database_helper.dart';
import '../network/api_service.dart';
import '../network/expander_service.dart';

class UrlRepository {
  final ApiService _apiService;
  final ExpanderService _expanderService;
  final DatabaseHelper _databaseHelper;

  UrlRepository({
    ApiService? apiService,
    ExpanderService? expanderService,
    DatabaseHelper? databaseHelper,
  }) : _apiService = apiService ?? ApiService(),
       _expanderService = expanderService ?? ExpanderService(),
       _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  Future<UrlData> shortenUrl(String provider, String longUrl) async {
    final result = await _apiService.shorten(provider, longUrl);
    if (result.success == true) {
      await _saveToHistory(result);
    }
    return result;
  }

  Future<UrlData> expandUrl(String shortUrl) async {
    final result = await _expanderService.expand(shortUrl);
    if (result.success == true) {
      await _saveToHistory(result);
    }
    return result;
  }

  Future<List<UrlData>> getHistory() async {
    return await _databaseHelper.getAllUrls();
  }

  Future<void> deleteUrl(int id) async {
    await _databaseHelper.delete(id);
  }

  Future<void> _saveToHistory(UrlData data) async {
    await _databaseHelper.insert(data);
  }
}
