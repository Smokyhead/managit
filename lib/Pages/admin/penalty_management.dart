import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PenaltyManagement extends StatefulWidget {
  const PenaltyManagement({super.key});

  @override
  State<StatefulWidget> createState() => _PenaltyManagementState();
}

class _PenaltyManagementState extends State<PenaltyManagement> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedEmployee;
  final TextEditingController _penaltyController = TextEditingController();

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
                        child: Text(
                            '${employee['Nom']} ${employee['Prénom']}'),
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
                controller: _penaltyController,
                decoration: const InputDecoration(
                  labelText: 'Jour de pénalité',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir le nombre de jours de pénalité';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Veuillez saisir un nombre valide';
                  }
                  return null;
                },
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
                          _savePenalty();
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

  Future<void> _savePenalty() async {
    if (_selectedEmployee != null && _penaltyController.text.isNotEmpty) {
      final penaltyDays = double.parse(_penaltyController.text);
      
      // Update employee's penalty in Firestore
      await FirebaseFirestore.instance.collection('Penalties').add({
        'employeeId': _selectedEmployee,
        'penaltyDays': penaltyDays,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Optionally, you might want to update the employee's leave credit directly
      final employeeDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(_selectedEmployee)
          .get();
      if (employeeDoc.exists) {
        final leaveCredit = employeeDoc['Solde congé'] ?? 0;
        final updatedLeaveCredit = leaveCredit - penaltyDays;
        await FirebaseFirestore.instance
            .collection('User')
            .doc(_selectedEmployee)
            .update({'Solde congé': updatedLeaveCredit});
      }

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Penalty assigned successfully')),
      );

      // Clear form
      setState(() {
        _selectedEmployee = null;
        _penaltyController.clear();
      });
    }
  }
}
