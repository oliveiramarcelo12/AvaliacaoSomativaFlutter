import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class WorkTimeReportScreen extends StatefulWidget {
  @override
  _WorkTimeReportScreenState createState() => _WorkTimeReportScreenState();
}

class _WorkTimeReportScreenState extends State<WorkTimeReportScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = true;
  List<Map<String, dynamic>> _workReport = [];

  @override
  void initState() {
    super.initState();
    _fetchWorkTimeReport();
  }

  Future<void> _fetchWorkTimeReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Verificar o userId
      print("User ID logado: ${user?.uid}");

      // Buscar os registros de check-in e check-out no Firestore
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('check_ins')
          .where('userId', isEqualTo: user?.uid)
          .orderBy('date')  // Garanta que o índice esteja correto no Firestore
          .orderBy('time')  // Garanta que o índice esteja correto no Firestore
          .get();

      if (snapshot.docs.isEmpty) {
        print("Nenhum registro encontrado.");
      } else {
        List<Map<String, dynamic>> records = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        print("Registros recuperados: $records");

        // Agrupar os registros por data
        Map<String, List<Map<String, dynamic>>> groupedByDate = {};
        for (var record in records) {
          String date = record['date'];
          if (groupedByDate.containsKey(date)) {
            groupedByDate[date]?.add(record);
          } else {
            groupedByDate[date] = [record];
          }
        }

        // Calcular o tempo total por dia (com base na primeira entrada e última saída)
        List<Map<String, dynamic>> reportData = [];
        groupedByDate.forEach((date, records) {
          DateTime? firstEntryTime;
          DateTime? lastExitTime;

          // Encontrar a primeira entrada e a última saída
          for (var record in records) {
            DateTime recordTime = _parseDateTime(record);
            if (record['type'] == 'entrada') {
              if (firstEntryTime == null || recordTime.isBefore(firstEntryTime)) {
                firstEntryTime = recordTime;
              }
            } else if (record['type'] == 'saida') {
              if (lastExitTime == null || recordTime.isAfter(lastExitTime)) {
                lastExitTime = recordTime;
              }
            }
          }

          if (firstEntryTime != null && lastExitTime != null) {
            Duration workedTime = lastExitTime.difference(firstEntryTime);

            reportData.add({
              'date': date,
              'checkInTime': DateFormat('HH:mm').format(firstEntryTime),
              'checkOutTime': DateFormat('HH:mm').format(lastExitTime),
              'workedTime': _formatDuration(workedTime),
            });
          }
        });

        setState(() {
          _workReport = reportData;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Erro ao carregar os registros: $e");
    }
  }

  // Função para converter a data e hora de string para DateTime
  DateTime _parseDateTime(Map<String, dynamic> record) {
    String date = record['date']; // Espera o formato dd/MM/yyyy
    String time = record['time']; // Espera o formato HH:mm:ss
    String dateTimeString = '$date $time';
    return DateFormat('dd/MM/yyyy HH:mm:ss').parse(dateTimeString);
  }

  // Função para formatar a duração trabalhada
  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    return '$hours h $minutes min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relatório de Ponto', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Exibição dos registros de ponto
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _workReport.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhum registro de ponto encontrado.',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _workReport.length,
                          itemBuilder: (context, index) {
                            final report = _workReport[index];
                            return Card(
                              color: Colors.white12,
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text(
                                  'Data: ${report['date']}',
                                  style: TextStyle(color: Colors.white),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Entrada: ${report['checkInTime']}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Saída: ${report['checkOutTime']}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Text(
                                      'Tempo Trabalhado: ${report['workedTime']}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
            
            // Botão para fechar ou realizar outra ação
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Exemplo de fechar a tela atual
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.black, // Cor do texto do botão
                ),
                child: Text('Fechar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
