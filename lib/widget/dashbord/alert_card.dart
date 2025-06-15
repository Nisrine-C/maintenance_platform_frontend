import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Assure-toi d'ajouter intl dans pubspec.yaml
import 'package:maintenance_platform_frontend/model/Failure.dart';
import 'package:maintenance_platform_frontend/services/DashbordService/FailureService.dart';

class AlertsSection extends StatefulWidget {
  const AlertsSection({super.key});

  @override
  State<AlertsSection> createState() => _AlertsSectionState();
}

class _AlertsSectionState extends State<AlertsSection> {
  final AlertService _service = AlertService();
  late Future<List<Failure>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchLatestAlertes();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Failure>>(
      future: _future,
      builder: (context, snapshot) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                ' Dernières alertes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator()),

              if (snapshot.hasError)
                Text("Erreur : ${snapshot.error}"),

              if (snapshot.hasData) ...[
                if (snapshot.data!.isEmpty)
                  const Center(
                    child: Text(
                      "Aucune alerte récente",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                if (snapshot.data!.isNotEmpty)
                  ...snapshot.data!.map((alert) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              " ${alert.faultType} - ${alert.machineName}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Durée d'arrêt : ${alert.downtimeHours.toStringAsFixed(2)} h",
                              style: const TextStyle(fontSize: 13),
                            ),
                            Text(
                              "Date : ${DateFormat('yyyy-MM-dd – HH:mm').format(alert.createdAt.toLocal())}",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ))
              ],
            ],
          ),
        );
      },
    );
  }
}
