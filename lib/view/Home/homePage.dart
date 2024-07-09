import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home_budget_calculator/view/totalPage/totalPage.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  ontapped(int index) {
    setState(() {
      _selectedIndex = index;

      print("sasas${_selectedIndex}");
    });
  }

  List<Widget> pages = [
    HomePage(),
    TotalPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: ontapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.monetization_on), label: 'Total'),
        ],
      ),
      body: pages[_selectedIndex],
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    TextEditingController _description = TextEditingController();
    TextEditingController _amount = TextEditingController();
    TextEditingController _projectNameController = TextEditingController();
    String? type;
    String? createdBy;

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Expenses')),

      ),
      body: Center(
        child: StreamBuilder(
          stream: getexpenses(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else {
              if (snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No Expenses'),
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var expense = snapshot.data!.docs[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          capitalizeFirstLetter(expense['category']),
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              capitalizeFirstLetter(expense['description']),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Created by: ${expense['createdBy']}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Date: ${_formatTimestamp(expense['created_at'])}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        trailing: Text(
                          '\₹ ${expense['amount']}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
            ),
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Add Expense',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _projectNameController,
                        decoration: const InputDecoration(
                          labelText: 'Expense Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _amount,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          border: OutlineInputBorder(),
                          prefixText: '\₹',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _description,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField(
                        value: type ?? 'Material',
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          'Material',
                          'Labour',
                          'Food',
                          'Transport',
                          'Other'
                        ]
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            type = value as String?;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField(
                        value: createdBy ?? 'Created By',
                        decoration: const InputDecoration(
                          labelText: 'Created By',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          'Dasaradhan',
                          'Preethi',
                          'Diljith',
                          'Created By'

                        ]
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            createdBy = value as String?;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            style: ButtonStyle(
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.red),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green),
                            onPressed: () {
                              addexpense(
                                name: _projectNameController.text,
                                amount: int.parse(_amount.text),
                                description: _description.text,
                                type: _projectNameController.text,
                                createdBy: createdBy ?? 'Unknown',
                              );
                              _projectNameController.clear();
                              Navigator.pop(context);
                            },
                            child: const Text('Add Expense'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

addexpense(
    {required String type,
    required int amount,
    String? description,
    required String name,
    required String createdBy}) {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // String id = firestore.collection('accounts').doc().id;
  firestore.collection('projects').doc().set({
    'name': name,
    'created_at': Timestamp.now(),
    // 'created_by': FirebaseAuth.instance.currentUser!.uid,
    'category': type,
    'amount': amount,
    'description': description,
    'createdBy': createdBy,
  }).then((value) {});
}

Stream<QuerySnapshot> getexpenses() {
  return FirebaseFirestore.instance.collection('projects').snapshots();
}

extension CapitalizeExtension on String {
  String capitalize() {
    if (isEmpty) return "";
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

String _formatTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}
