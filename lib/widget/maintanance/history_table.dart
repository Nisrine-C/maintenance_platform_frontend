import 'package:flutter/material.dart';

class HistoryTable extends StatelessWidget {
  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.blueGrey.shade100),
      children: [
        _tableCell("Date", isHeader: true),
        _tableCell("Action", isHeader: true),
        _tableCell("Responsable", isHeader: true),
      ],
    );
  }

  TableRow _buildDataRow(String date, String action, String user) {
    return TableRow(
      children: [
        _tableCell(date),
        _tableCell(action),
        _tableCell(user),
      ],
    );
  }

  Widget _tableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Historique des maintenances",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Table(
          border: TableBorder.all(color: Colors.grey.shade300),
          columnWidths: {
            0: FixedColumnWidth(100),
            1: FlexColumnWidth(),
            2: FixedColumnWidth(120),
          },
          children: [
            _buildHeaderRow(),
            _buildDataRow("9 avr. 24", "💪 Vérifier les roulements", "Paul"),
            _buildDataRow("2 avr. 24", "🔄 Augmer logiciel des vibrations", "Sophie"),
            _buildDataRow("26 mar. 24", "🔍 Inspecter le mécanisme de five", "Antoine"),
            _buildDataRow("15 mar. 15", "⚙ Remplacer les roulements", "Pierre"),
          ],
        )
      ],
    );
  }
}
