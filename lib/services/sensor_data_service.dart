import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/SensorData.model.dart';


class SensorDataService {
  final String _baseUrl = "http://localhost:8087/api";

  final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<List<SensorData>> getSensorDatas() async {
    final response = await http.get(Uri.parse('$_baseUrl/sensor-data'));

    print('DEBUG: Server responded with: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<SensorData> sensorDatas = body
          .map(
            (dynamic item) => SensorData.fromJson(item as Map<String, dynamic>),
      ).toList();
      return sensorDatas;
    } else {
      throw Exception('Failed to load sensorDatas');
    }
  }
  Future<SensorData> createSensorData(SensorData sensorData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/sensor-data'),
      headers: _headers,
      body: jsonEncode(sensorData.toJson()),
    );

    if (response.statusCode == 201) {
      return SensorData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create sensorData. Status code: ${response.statusCode}');
    }
  }

  Future<SensorData> getSensorDataById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/sensor-data/$id'));
    if (response.statusCode == 200) {
      return SensorData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load sensorData with id $id');
    }
  }

  Future<void> deleteSensorData(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/sensor-data/$id'),
      headers: _headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete sensorData with id $id');
    }
  }
}