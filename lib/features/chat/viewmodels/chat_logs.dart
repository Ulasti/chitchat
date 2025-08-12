import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatApi {
  final String baseUrl;
  ChatApi(this.baseUrl);

  Future<List<Map<String, dynamic>>> fetchHistory(
    String me,
    String other,
  ) async {
    final uri = Uri.parse(
      '$baseUrl/messages/${Uri.encodeComponent(me)}/${Uri.encodeComponent(other)}',
    );
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('Failed to load History');
    final data = json.decode(res.body) as List;
    return data.cast<Map<String, dynamic>>();
  }
}
