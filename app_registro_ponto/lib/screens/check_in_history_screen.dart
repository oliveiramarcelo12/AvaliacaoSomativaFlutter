import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CheckInHistoryScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<List<Map<String, dynamic>>> _fetchCheckInHistory() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('check_ins')
        .where('userId', isEqualTo: user?.uid)
        .orderBy('date', descending: true) // Ordena por data
        .orderBy('time', descending: true) // Ordena por hora
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Registro de Ponto'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchCheckInHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar histórico.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhum registro encontrado.'));
          }

          List<Map<String, dynamic>> checkInHistory = snapshot.data!;

          // Agrupar os dados por data
          Map<String, List<Map<String, dynamic>>> groupedData = {};
          for (var record in checkInHistory) {
            String date = record['date'];

            if (!groupedData.containsKey(date)) {
              groupedData[date] = [];
            }
            groupedData[date]!.add(record);
          }

          List<String> dates = groupedData.keys.toList();
          dates.sort((a, b) => b.compareTo(a)); // Ordenar as datas

          return ListView.builder(
            itemCount: dates.length,
            itemBuilder: (context, index) {
              String date = dates[index];
              List<Map<String, dynamic>> records = groupedData[date]!;

              return ExpansionTile(
                title: Text(
                  date,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                children: records.map((record) {
                  return ListTile(
                    title: Text('${record['type']} às ${record['time']}'),
                    subtitle: Text('Localização: ${record['location']}'),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
