import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AbsenceManagement extends StatefulWidget {
  const AbsenceManagement({super.key});

  @override
  State<StatefulWidget> createState() => _AbsenceManagementState();
}

class _AbsenceManagementState extends State<AbsenceManagement> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedEmployee;
  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('User')
                    .where('role', isEqualTo: 'employee')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final employees = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Séléctionner un employé',
                    ),
                    items: employees.map((employee) {
                      return DropdownMenuItem<String>(
                        value: employee.id,
                        child: Text('${employee['Nom']} ${employee['Prénom']}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedEmployee = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Veuillez séléctionner un employé' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Séléctionnez la date',
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = pickedDate;
                      _dateController.text =
                          DateFormat('dd/MM/yyyy').format(pickedDate);
                    });
                  }
                },
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez séléctionnez une date' : null,
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  margin: const EdgeInsetsDirectional.only(top: 5),
                  width: size.width * 0.4,
                  height: 60,
                  child: TextButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _saveAbsence();
                        }
                      },
                      style: ButtonStyle(
                        elevation: WidgetStateProperty.all(10),
                        backgroundColor: WidgetStateProperty.all(
                            const Color.fromARGB(255, 30, 60, 100)),
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      child: Text("Valider",
                          style: TextStyle(fontSize: size.width * 0.05))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveAbsence() async {
    if (_selectedEmployee != null && _selectedDate != null) {
      await FirebaseFirestore.instance.collection('Absences').add({
        'employeeId': _selectedEmployee,
        'date': _selectedDate,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Absence saved successfully')),
      );

      // Clear form
      setState(() {
        _selectedEmployee = null;
        _selectedDate = null;
        _dateController.clear();
      });
    }
  }
}
