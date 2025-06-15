import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/Maintenance.model.dart';


class MaintenanceService {
  final String _baseUrl = "http://localhost:8087/api";

  final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<List<Maintenance>> getMaintenances() async {
    final response = await http.get(Uri.parse('$_baseUrl/maintenance'));

    print('DEBUG: Server responded with: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Maintenance> maintenances = body
          .map(
            (dynamic item) => Maintenance.fromJson(item as Map<String, dynamic>),
      ).toList();
      return maintenances;
    } else {
      throw Exception('Failed to load maintenances');
    }
  }
  Future<Maintenance> createMaintenance(Maintenance maintenance) async {
    print(maintenance.toJson());
    final response = await http.post(
      Uri.parse('$_baseUrl/maintenance'),
      headers: _headers,
      body: jsonEncode(maintenance.toJson()),
    );

    if (response.statusCode == 201) {
      return Maintenance.fromJson(jsonDecode(response.body));
    } else {
      print('response : ${response.body}');
      throw Exception('Failed to create maintenance. Status code: ${response.statusCode}');
    }
  }

  Future<Maintenance> getMaintenanceById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/maintenance/$id'));
    if (response.statusCode == 200) {
      return Maintenance.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load maintenance with id $id');
    }
  }

  Future<void> deleteMaintenance(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/maintenance/$id'),
      headers: _headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete maintenance with id $id');
    }
  }
}