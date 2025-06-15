import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/Failure.model.dart';


class FailureService {
  final String _baseUrl = "http://localhost:8087/api";

  final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<List<Failure>> getFailures() async {
    final response = await http.get(Uri.parse('$_baseUrl/failure'));

    print('DEBUG: Server responded with: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Failure> failures = body
          .map(
            (dynamic item) => Failure.fromJson(item as Map<String, dynamic>),
      ).toList();
      return failures;
    } else {
      throw Exception('Failed to load failures');
    }
  }
  Future<Failure> createFailure(Failure failure) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/failure'),
      headers: _headers,
      body: jsonEncode(failure.toJson()),
    );

    if (response.statusCode == 201) {
      return Failure.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create failure. Status code: ${response.statusCode}');
    }
  }

  Future<Failure> getFailureById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/failure/$id'));
    if (response.statusCode == 200) {
      return Failure.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load failure with id $id');
    }
  }

  Future<void> deleteFailure(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/failure/$id'),
      headers: _headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete failure with id $id');
    }
  }
}