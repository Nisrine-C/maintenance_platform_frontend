import 'package:flutter/material.dart';
import 'package:maintenance_platform_frontend/widget/machines/progress_bar.widget.dart';
import '../../constants/colors.dart';
import '../../model/Failure.model.dart';
import '../../model/Machine.model.dart';
import '../../model/Prediction.model.dart';
import '../../screen/machines/machine_detail.screen.dart';

class MachineItem extends StatelessWidget {
  final Machine machine;
  final Failure? failure;
  final Prediction? prediction;

  // FIX 1: The constructor was asking for required nullable parameters.
  // This is not an error, but it's cleaner to just mark them as nullable.
  const MachineItem({
    super.key,
    required this.machine,
    this.failure,
    this.prediction,
  });

  @override
  Widget build(BuildContext context) {
    // FIX 2: Calculate progress safely.
    // If prediction or expectedLifetimeHours is null or 0, default to a safe value.
    double progress = 0.0; // Default to 0% used life (full health)
    if (prediction != null && machine.expectedLifetimeHours > 0) {
      // This calculation now only runs if the data exists.
      progress = 1 - (prediction!.predictedRULHours / machine.expectedLifetimeHours);
    }

    // FIX 3: Define status text and color based on data.
    // This keeps your UI logic clean and in one place.
    String conditionText;
    Color conditionColor;
    Color conditionTextColor;

    if (failure != null) {
      conditionText = 'Code ${failure!.faultType ?? "Failure"}';
      conditionColor = tdRed;
      conditionTextColor = textRed;
    } else if (prediction != null) {
      conditionText = prediction!.faultType ?? 'Warning';
      conditionColor = tdYellow;
      conditionTextColor = textYellow;
    } else {
      conditionText = 'OK';
      conditionColor = tdGreen;
      conditionTextColor = textGreen;
    }


    return InkWell(
      onTap: () {
        // FIX 4: Pass the dynamic data to the detail screen.
        // This makes the Detail screen dynamic too.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Detail(
              machine: machine,
              prediction: prediction,
              failure: failure,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
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
                machine.name ?? 'Unnamed Machine', // Use ?? for safety
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),

              // Fault Info - Now fully dynamic
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
                      color: conditionColor, // Use the dynamic color
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      conditionText, // Use the dynamic text
                      style: TextStyle(color: conditionTextColor),
                    ),
                  ),
                ],
              ),

              // FIX 5: Remove the line that was guaranteed to crash.
              // This information is now handled correctly in the "Condition" row above.
              // Text(failure!.faultType), // <-- REMOVED THIS CRASH POINT

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
                    // Use ?? to provide a default value if prediction is null
                    '${prediction?.predictedRULHours.toStringAsFixed(0) ?? "N/A"} hours',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 5),

              ProgressBar(
                width: MediaQuery.of(context).size.width,
                height: 20,
                progress: progress.clamp(0.0, 1.0), // Use the safely calculated progress
              ),

              const SizedBox(height: 10),

              // FIX 6: Only show the "Recommended Action" if there is a reason to.
              if (failure != null || prediction != null)
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
                      Text(
                        // Use a dynamic recommendation based on severity
                        failure != null
                            ? 'Immediate inspection required!'
                            : 'Schedule inspection within 72 hours',
                        style: const TextStyle(color: tdPurple, fontSize: 14),
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
                                    (context) => Detail(
                                    machine: machine,
                                    prediction: prediction,
                                    failure: failure
                                ),
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