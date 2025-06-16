import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/Machine.model.dart';

class MachineService {
  final String _baseUrl = "http://localhost:8087/api";

  final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<List<Machine>> getMachines() async {
    final response = await http.get(Uri.parse('$_baseUrl/machine'));
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Machine> machines = body
          .map(
            (dynamic item) => Machine.fromJson(item as Map<String, dynamic>),
      ).toList();
      return machines;
    } else {
      throw Exception('Failed to load machines');
    }
  }
  Future<Machine> createMachine(Machine machine) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/machine'),
      headers: _headers,
      body: jsonEncode(machine.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return Machine.fromJson(jsonDecode(response.body));
    } else {
      print(response.body);
      throw Exception('Failed to create machine. Status code: ${response.statusCode}');
    }
  }

  Future<Machine> getMachineById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/machine/$id'));
    if (response.statusCode == 200) {
      return Machine.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load machine with id $id');
    }
  }

  Future<void> deleteMachine(int id) async {
    print('attempting delete');
    final response = await http.delete(
      Uri.parse('$_baseUrl/machine/$id'),
      headers: _headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete machine with id $id');
    }else{
      print('Machine ${id} deleted successfully');
    }
  }

  Future<Machine> updateMachine(int id, Machine machine) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/machine/$id'),
      headers: _headers,
      body: jsonEncode(machine.toJson()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      print(response.body);
      return Machine.fromJson(jsonDecode(response.body));
    } else {
      print(response.body);
      throw Exception('Failed to create machine. Status code: ${response.statusCode}');
    }
  }
}