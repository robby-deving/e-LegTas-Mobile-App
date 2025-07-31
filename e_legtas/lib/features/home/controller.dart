import 'dart:convert';
import 'package:http/http.dart' as http;
import './evacuation_center_model.dart';

class EvacuationCenterService {
  static const String _baseUrl = 'http://localhost:3000/api/v1/evacuation-centers';

  static Future<List<EvacuationCenter>> fetchDetailedMapData() async {
    final response = await http.get(Uri.parse('$_baseUrl/detailed-map-data'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => EvacuationCenter.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load evacuation centers');
    }
  }
}