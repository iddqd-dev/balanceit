import 'dart:math';

import 'package:balanceit/pages/add_transaction.dart';
import 'package:balanceit/pages/edit_transaction.dart';
import 'package:balanceit/utils/set_transaction_list_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import '../utils/database/database_adapter.dart';
import '../utils/notification_service.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> dataList = [];
  String? budgetValue = '0';
  Map<String, dynamic> transaction = {};
  bool _notificationsEnabled = false;

  Future<void> _isAndroidNotificationPermissionGranted() async {
    // Notifications
    final bool granted = await NotificationService.notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() ??
        false;

    setState(() {
      _notificationsEnabled = granted;
    });
    //
  }

  _requestPermissions() async {
    // Notifications
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        NotificationService.notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

    final bool? granted = await androidImplementation?.requestPermission();
    setState(() {
      _notificationsEnabled = granted ?? false;
    });
    //
  }

  _createTestTransaction() {
    DatabaseHelper dbHelper = DatabaseHelper();
    dbHelper.addTransaction({
      'type': Random().nextInt(2),
      'amount': 550.00,
      'category': 'Другое',
      'description': 'description',
      'date': DateTime.now().toIso8601String(),
      'is_owed': 0,
      'is_lent': 0,
    });
  }

  _getTransactions() async {
    List<Map<String, dynamic>> result = await dbHelper.getData('transactions');
    return result;
  }

  _updateTransactionList() async {
    List<Map<String, dynamic>> result = await _getTransactions();
    setState(() {
      dataList = result;
    });
  }

  _getBalance() async {
    double sum = 0;
    List<Map<String, dynamic>> result = await _getTransactions();
    for (transaction in result) {
      if (transaction['type'] == 1) {
        sum += transaction['amount'];
      } else if (transaction['type'] == 0) {
        sum -= transaction['amount'];
      }
    }
    setState(() => budgetValue = sum.toStringAsFixed(2));
  }

  @override
  void initState() {
    _isAndroidNotificationPermissionGranted();
    _requestPermissions();
    _updateTransactionList();
    _getBalance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AddTransactionForm(
                onFormSubmit: (option, amount, category, description, date) {
                  dbHelper.addTransaction({
                    'type': option,
                    'amount': double.parse(amount),
                    'category': category,
                    'description': description,
                    'date': DateFormat('dd.MM.yyyy HH:mm')
                        .parse(date)
                        .toIso8601String(),
                    'is_owed': 0,
                    'is_lent': 0,
                  });
                  _updateTransactionList();
                  _getBalance();
                },
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: <Widget>[
                Text(
                  '$budgetValue',
                  style: const TextStyle(fontSize: 26),
                ),
                const Icon(Icons.currency_ruble),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          ElevatedButton(
            child: const Text('Show notifications'),
            onPressed: () {
              NotificationService()
                  .showNotification(title: 'Sample title', body: 'It works!');
            },
          ),
          // ElevatedButton(onPressed: _createTestTransactions(10), child: Text('Генерим тестовые')),
          Expanded(
            child: SizedBox(
              child: ListView.builder(
                  itemCount: dataList.length,
                  itemBuilder: (context, index) {
                    final config =
                        Config.setTransactionListConfig(dataList, index);
                    return Dismissible(
                      key: Key(dataList[index]['id'].toString()),
                      direction: DismissDirection.horizontal,
                      confirmDismiss: (direction) async {
                        // Пользовательское подтверждение удаления элемента
                        if (direction == DismissDirection.startToEnd) {
                          // При свайпе в сторону редактирования не подтверждаем удаление
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return EditTransactionForm(
                                index: dataList[index]['id'],
                                onFormSubmit: (option, amount, category, description, date) {
                                  dbHelper.updateTransactionData({
                                    'type': option,
                                    'amount': double.parse(amount),
                                    'category': category,
                                    'description': description,
                                    'date': DateFormat('dd.MM.yyyy HH:mm')
                                        .parse(date)
                                        .toIso8601String(),
                                    'is_owed': 0,
                                    'is_lent': 0,
                                  }, dataList[index]['id']);
                                  _updateTransactionList();
                                  _getBalance();
                                },
                              );
                            },
                          );
                          return false;
                        }
                        return true;
                      },
                      onDismissed: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          await dbHelper.deleteData(
                              'transactions', dataList[index]['id']);
                        }
                        setState(() {
                          List<Map<String, dynamic>> newDataList =
                              List.from(dataList);
                          newDataList.removeAt(index);
                          dataList = newDataList;
                          _getBalance();
                          _updateTransactionList();
                        });
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(left: 10.0),
                        color: Colors.green,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.edit, color: Colors.white),
                            Padding(padding: EdgeInsets.only(left: 5.0)),
                            Text(
                              'Редактировать',
                              style: TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        color: Colors.red,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Удалить',
                              style: TextStyle(color: Colors.white),
                            ),
                            Icon(Icons.delete, color: Colors.white)
                          ],
                        ),
                      ),
                      child: Card(
                        color: Colors.white,
                        child: ListTile(
                          // TODO: сделать вывод настроек.
                          onLongPress: () {},
                          // TODO: сделать вывод чека. если договорюсь с налоговой.
                          onTap: () {},
                          leading: config['icon'] as Icon,
                          title: Text(dataList[index]['category']),
                          subtitle: config['transactionType'] as Text,
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                config['textAmount'].toString(),
                                style: TextStyle(
                                    fontSize: 16,
                                    color: config['textColor'] as Color),
                              ),
                              Text(DateFormat('hh:mm dd.MM.yyyy').format(
                                  DateTime.parse('${dataList[index]['date']}')))
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
