// lib/features/home/data/datasources/evacuation_center_remote_datasource.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:e_legtas/features/home/data/models/evacuation_center_model.dart';
import 'package:e_legtas/core/constants/api_constants.dart';

class EvacuationCenterRemoteDataSource {
  final http.Client client;

  EvacuationCenterRemoteDataSource({required this.client});

  Future<List<EvacuationCenterModel>> fetchDetailedMapData() async {
    final response = await client.get(Uri.parse('${ApiConstants.baseUrl}/evacuation-centers/detailed-map-data'));

    if (response.statusCode == 200) {
      // Decode the entire JSON response as a Map
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Access the 'data' key, which contains the list of evacuation centers
      // We are confident 'data' exists and is a List<dynamic> based on your provided JSON.
      final List<dynamic> evacuationCentersJson = responseData['data'];

      // Map each JSON object in the list to an EvacuationCenterModel
      return evacuationCentersJson.map((json) => EvacuationCenterModel.fromJson(json)).toList();
    } else {
      // Provide more context in the exception for debugging
      throw Exception('Failed to load evacuation centers: Status Code ${response.statusCode}, Body: ${response.body}');
    }
  }
}