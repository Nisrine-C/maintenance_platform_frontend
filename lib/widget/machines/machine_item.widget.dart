import 'package:flutter/material.dart';
import 'package:maintenance_platform_frontend/widget/machines/progress_bar.widget.dart';
import '../../constants/colors.dart';
import '../../model/Failure.model.dart';
import '../../model/Machine.model.dart';
import '../../model/Prediction.model.dart';
import '../../screen/machienDetail/machine_detail.screen.dart';

class MachineItem extends StatelessWidget {
  final Machine machine;
  final Failure failure;
  final Prediction prediction;

  const MachineItem({
    super.key,
    required this.machine,
    required this.failure,
    required this.prediction,
  });

  @override
  Widget build(BuildContext context) {
    double progress =
        1 - (prediction.predictedRULHours / machine.expectedLifetimeHours);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Detail(machine: machine.name),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20), // Match the card radius
      child: Card(
        elevation: 2,
        color: bgGrey,
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${machine.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),

              // Fault Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Condition',
                    style: TextStyle(color: textGrey, fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: tdGreen,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'Code ${failure.faultType}',
                      style: TextStyle(color: textGreen),
                    ),
                  ),
                ],
              ),
              Text(failure.faultType),
              const SizedBox(height: 5),

              // Remaining Life
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Remaining life',
                    style: TextStyle(color: textGrey, fontSize: 16),
                  ),
                  Text(
                    '${prediction.predictedRULHours.toStringAsFixed(0)} hours',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 5),

              ProgressBar(
                width: MediaQuery.of(context).size.width,
                height: 20,
                progress: progress.clamp(0.0, 1.0),
              ),

              const SizedBox(height: 10),

              // Recommended Action
              Container(
                padding: const EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommended Action',
                      style: TextStyle(color: tdBlue, fontSize: 16),
                    ),
                    const Text(
                      'Schedule inspection within 72 hours',
                      style: TextStyle(color: tdPurple, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => Detail(machine: machine.name),
                            ),
                          );
                        },
                        child: const Text(
                          'Schedule Maintenance Now',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
