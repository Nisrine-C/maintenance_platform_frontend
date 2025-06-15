import 'package:flutter/material.dart';

class CreateMachineForm extends StatefulWidget {
  const CreateMachineForm({super.key});

  @override
  State<CreateMachineForm> createState() => _CreateMachineFormState();
}

class _CreateMachineFormState extends State<CreateMachineForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _machineNameController = TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();
  final TextEditingController _expectedLifetimeHoursController =
  TextEditingController();

  bool _isActive = true;

  @override
  void dispose() {
    _machineNameController.dispose();
    _serialNumberController.dispose();
    _expectedLifetimeHoursController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      print('Form Submitted:');
      print('Machine Name: ${_machineNameController.text}');
      print('Serial Number: ${_serialNumberController.text}');
      print(
          'Expected Lifetime Hours: ${_expectedLifetimeHoursController.text}');
      print('Active Status: $_isActive');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create Machine form submitted!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Maintenance'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 56.0, 16.0, 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                color: Color.fromARGB(255, 250, 222, 255),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 24.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8.0),
                      Text(
                        'Machine Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Machine Name',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      TextFormField(
                        controller: _machineNameController,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(8.0)),
                            borderSide:
                            BorderSide(color: Colors.grey, width: 0.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(8.0)),
                            borderSide:
                            BorderSide(color: Colors.grey, width: 0.0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(8.0)),
                            borderSide:
                            BorderSide(color: Colors.grey, width: 0.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter machine name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        ' Serial Number',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      TextFormField(
                        controller: _serialNumberController,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(8.0)),
                            borderSide:
                            BorderSide(color: Colors.grey, width: 0.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(8.0)),
                            borderSide:
                            BorderSide(color: Colors.grey, width: 0.0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(8.0)),
                            borderSide:
                            BorderSide(color: Colors.grey, width: 0.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter serial number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        'Expected Lifetime Hours',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      TextFormField(
                        controller: _expectedLifetimeHoursController,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(8.0)),
                            borderSide:
                            BorderSide(color: Colors.grey, width: 0.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(8.0)),
                            borderSide:
                            BorderSide(color: Colors.grey, width: 0.0),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(8.0)),
                            borderSide:
                            BorderSide(color: Colors.grey, width: 0.0),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter expected lifetime hours';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 24.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Machine Status',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Active Status',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                'Set machine as active in the system',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          Switch(
                            value: _isActive,
                            onChanged: (bool value) {
                              setState(() {
                                _isActive = value;
                              });
                            },
                            activeColor: Colors.deepPurple,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Create Machine',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
