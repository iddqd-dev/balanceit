import 'package:flutter/material.dart';


class Config {
  static setTransactionListConfig(List<Map<String, dynamic>> dataList, int index) {
    final typeConfig = {
      '0': {
        'icon': const Icon(Icons.money_off, color: Colors.red, size: 34),
        'transactionType': const Text('Потрачено'),
        'textColor': Colors.red,
        'textAmount': '-${dataList[index]['amount']}',
      },
      '1': {
        'icon': const Icon(Icons.attach_money, color: Colors.green, size: 34),
        'transactionType': const Text('Получено'),
        'textColor': Colors.green,
        'textAmount': '+${dataList[index]['amount']}',
      }
    };
    final config = typeConfig[dataList[index]['type'].toString()];
    return config;
  }
}