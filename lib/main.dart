import 'package:balanceit/pages/fckng_debts.dart';
import 'package:balanceit/pages/main.dart';
import 'package:balanceit/pages/monthly_payments.dart';
import 'package:balanceit/themes/mainTheme.dart';
import 'package:balanceit/utils/database/database_adapter.dart';
import 'package:balanceit/utils/notification_service.dart';
import 'package:flutter/material.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  await DatabaseHelper().initDb();
  runApp(const BalanceIt());
}

class BalanceIt extends StatelessWidget {
  const BalanceIt({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: mainTheme,
      home: const NavigationBar(),
    );
  }
}

class NavigationBar extends StatefulWidget {
  const NavigationBar({Key? key}) : super(key: key);

  @override
  State<NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  int _currentIndex = 1;

  final List<Widget> _screens = [
    const MonthlyPayments(),
    const MainPage(),
    const Debts(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Плановые'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.attach_money),
              label: 'Доход/расход'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card),
              label: 'Долги'
          )
        ],
      ),
    );
  }
}
