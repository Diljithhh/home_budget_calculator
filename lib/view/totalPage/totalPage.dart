import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:home_budget_calculator/view/Home/homePage.dart';

class TotalPage extends StatelessWidget {
  const TotalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('Total Expenses'
        ,style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getexpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No expenses found'));
          }

          Map<String, double> totalByCreator = {};
          double grandTotal = 0;

          for (var doc in snapshot.data!.docs) {
            String createdBy = doc['createdBy'] ?? 'Unknown';
            double amount = (doc['amount'] as num).toDouble();

            totalByCreator[createdBy] =
                (totalByCreator[createdBy] ?? 0) + amount;
            grandTotal += amount;
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  title: const Text('Grand Total',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text('\₹ ${grandTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Totals by Creators'

              ,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white)),
              const SizedBox(height: 10),
              ...totalByCreator.entries
                  .map((entry) => Card(
                        child: ListTile(
                          title: Text(entry.key),
                          trailing: Text('\₹ ${entry.value.toStringAsFixed(2)}'),
                        ),
                      ))
                  .toList(),
            ],
          );
        },
      ),
    );
  }
}

