import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/Prediction.model.dart';


class PredictionService {
  final String _baseUrl = "http://localhost:8087/api";

  final Map<String, String> _headers = {
    'Content-Type': 'application/json; charset=UTF-8',
  };

  Future<List<Prediction>> getPredictions() async {
    final response = await http.get(Uri.parse('$_baseUrl/prediction'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Prediction> predictions = body
          .map(
            (dynamic item) => Prediction.fromJson(item as Map<String, dynamic>),
      ).toList();
      return predictions;
    } else {
      throw Exception('Failed to load predictions');
    }
  }
  Future<Prediction> createPrediction(Prediction prediction) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/prediction'),
      headers: _headers,
      body: jsonEncode(prediction.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('response : ${response.body}');
      return Prediction.fromJson(jsonDecode(response.body));
    } else {
      print('response : ${response.body}');
      throw Exception('Failed to create prediction. Status code: ${response.statusCode}');
    }
  }

  Future<Prediction> getPredictionById(int id) async {
    final response = await http.get(Uri.parse('$_baseUrl/prediction/$id'));
    if (response.statusCode == 200) {
      return Prediction.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load prediction with id $id');
    }
  }

  Future<void> deletePrediction(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/prediction/$id'),
      headers: _headers,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete prediction with id $id');
    }
  }
}