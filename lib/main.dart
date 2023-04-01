import 'package:balanceit/pages/add_transaction.dart';
import 'package:balanceit/themes/mainTheme.dart';
import 'package:balanceit/utils/database/database_adapter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().db;
  runApp(const BalanceIt());
}

class BalanceIt extends StatelessWidget {
  const BalanceIt({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: mainTheme,
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> dataList = [];
  String? budgetValue = '0';

  _getTransactions() async {
    List<Map<String, dynamic>> result = await dbHelper.getData('transactions');
    setState(() {
      dataList = result;
    });
  }

  @override
  void initState() {
    _getTransactions();
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
                  _getTransactions();
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
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    // TODO: Обработчик нажатия кнопки настройки
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: SizedBox(
              child: ListView.builder(
                  itemCount: dataList.length,
                  itemBuilder: (context, index) {
                    final typeConfig = {
                      '0': {
                        'icon': const Icon(Icons.money_off,
                            color: Colors.red, size: 34),
                        'transactionType': const Text('Потрачено'),
                        'textColor': Colors.red,
                        'textAmount': '-${dataList[index]['amount']}',
                      },
                      '1': {
                        'icon': const Icon(Icons.attach_money,
                            color: Colors.green, size: 34),
                        'transactionType': const Text('Получено'),
                        'textColor': Colors.green,
                        'textAmount': '+${dataList[index]['amount']}',
                      }
                    };
                    final config = typeConfig[dataList[index]['type']];
                    return Dismissible(
                      key: Key(dataList[index]['id'].toString()),
                      direction: DismissDirection.horizontal,
                      onDismissed: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          await dbHelper.deleteData(
                              'transactions', dataList[index]['id']);
                          setState(() {
                            _getTransactions();
                          });
                        } else {
                          //TODO: Сделать левый свайп.
                        }
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        color: Colors.red,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('Удалить', style: TextStyle(color: Colors.white),),
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
                          leading: config!['icon'] as Icon,
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
