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
    const TotalPage(),
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
    String? _selectedFilter;
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Expenses')),
      ),
      body: StreamBuilder(
        stream: getexpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Expenses'));
          } else {
            var expenses = snapshot.data!.docs;
            if (_selectedFilter != null && _selectedFilter != 'All') {
              expenses = expenses
                  .where((doc) => doc['category'] == _selectedFilter)
                  .toList();
            }
            return ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                var expense = expenses[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Dismissible(


                     key: Key(expense.id),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,

       confirmDismiss: (DismissDirection direction) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure you want to delete this expense?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("CANCEL"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("DELETE"),
            ),
          ],
        );
      },
    );
  },
      onDismissed: (direction) {


        deleteExpense(expense.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense deleted')),
        );
      },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        title: Text(
                          capitalizeFirstLetter(expense['category']),
                          style: const TextStyle(
                              color: Colors.orange, fontSize: 24),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(capitalizeFirstLetter(
                                expense['description'] ?? '')),
                            Text(_formatTimestamp(expense['created_at'])),
                            Text('Created by: ${expense['createdBy']}'),
                          ],
                        ),
                        trailing: Wrap(
                          children: [
                            Text(
                              '₹${expense['amount'].toString()}',
                              style: const TextStyle(fontSize: 20),
                            ),

                                IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showUpdateDialog(context, expense);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
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
                            type = value;
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
                            createdBy = value;
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
                              if (_amount.text.isEmpty ||
                                  type == null ||
                                  createdBy == null) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('All fields are required'),
                                ));
                              } else {
                                addexpense(
                                  name: _projectNameController.text,
                                  amount: int.parse(_amount.text),
                                  description: _description.text,
                                  type: type ?? 'Material',
                                  createdBy: createdBy ?? 'Unknown',
                                );
                                _projectNameController.clear();
                                Navigator.pop(context);
                              }
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

  void _showUpdateDialog(BuildContext context, DocumentSnapshot expense) {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: expense['amount'].toString());
  final _descriptionController = TextEditingController(text: expense['description']);
  String? _category = expense['category'];
  String? createdBy = expense['createdBy'];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Update Expense'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    return null;
                  },
                ),

                DropdownButtonFormField<String>(
                  value: _category,
                  items: ['Food', 'Material', 'Labour', 'Permission', 'Other']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _category = newValue;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                 DropdownButtonFormField<String>(
                  value: createdBy,
                  items: ['Dasaradhan', 'Preethi', 'Diljith', 'Created By']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      createdBy = newValue;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Created By'),
                ),

              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Update'),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                updateExpense(expense.id, {
                  'amount': int.parse(_amountController.text),
                 'createdBy': createdBy,
                  'category': _category,
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Expense updated')),
                );
              }
            },
          ),
        ],
      );
    },
  );
}
}


  Future<void> updateExpense(String docId, Map<String, dynamic> newData) async {
    await FirebaseFirestore.instance.collection('projects').doc(docId).update(newData);
  }
 Future<void> deleteExpense(String docId) async {
    await FirebaseFirestore.instance.collection('projects').doc(docId).delete();
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
