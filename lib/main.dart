<<<<<<< HEAD
import 'package:balanceit/pages/main.dart';
import 'package:flutter/material.dart';

void main() {
=======
import 'package:balanceit/pages/scan_screen.dart';
import 'package:balanceit/themes/mainTheme.dart';
import 'package:balanceit/utils/database/database_adapter.dart';
import 'package:balanceit/utils/parsing/receipt_info.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var db = await DatabaseHelper().db;
>>>>>>> Добавлена поддержка SQLite, набросана базовая "архитектура" бд.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
<<<<<<< HEAD
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BalanceIt',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: QRScanner(),
=======
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: mainTheme,
      home: const MyHomePage(title: 'BalanceIT'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? budgetValue;
  final TextEditingController _rublesController = TextEditingController();
  final TextEditingController _kopeksController = TextEditingController();

  @override
  void dispose() {
    _rublesController.dispose();
    _kopeksController.dispose();
    super.dispose();
  }

  void _convertToKopeks() {
    double rubles = double.tryParse(_rublesController.text) ?? 0;
    int kopeks =
        (rubles * 100).round() + 1000; // добавляем 10 рублей в копейках
    _kopeksController.text = kopeks.toString();
  }

  void _convertToRubles() {
    int kopeks = int.tryParse(_kopeksController.text) ?? 0;
    double rubles = kopeks / 100;
    budgetValue = rubles.toStringAsFixed(2);
    _rublesController.text = rubles.toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: <Widget>[
              Text('$budgetValue', style: const TextStyle(fontSize: 26),),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _rublesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Рубли',
                suffixText: '₽',
              ),
            ),
            TextField(
              controller: _kopeksController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Копейки',
                suffixText: 'коп.',
              ),
            ),
            ElevatedButton(
              onPressed: _convertToKopeks,
              child: const Text('Преобразовать в копейки и добавить 10 рублей'),
            ),
            ElevatedButton(
              onPressed: _convertToRubles,
              child: const Text('Преобразовать в рубли и копейки'),
            ),
            ElevatedButton(
              onPressed: () async {
                ReceiptInfo? scanResult = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanScreen()),
                );
                if (scanResult != null) {
                  setState(() {
                    budgetValue = scanResult.sum;
                    _kopeksController.text = scanResult.sum;
                    _convertToRubles();
                  });
                }
              },
              child: const Text('Сканировать QR'),
            ),
          ],

        ),
      ),
>>>>>>> Добавлена поддержка SQLite, набросана базовая "архитектура" бд.
    );
  }
}
