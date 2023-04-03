import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as svc;
import 'package:intl/intl.dart';

import '../utils/database/database_adapter.dart';

class EditTransactionForm extends StatefulWidget {
  final Function(String, String, String, String, String) onFormSubmit;
  final int index;
  const EditTransactionForm({super.key, required this.onFormSubmit, required this.index});

  @override
  State<EditTransactionForm> createState() => _EditTransactionFormState();
}

class _EditTransactionFormState extends State<EditTransactionForm> {

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  DatabaseHelper dbHelper = DatabaseHelper();
  String _selectedOption = "0";
  final _formKey = GlobalKey<FormState>();

  _getTransactionDataFromDatabase() async {
    List<Map<String, dynamic>> result = await dbHelper.getTransactionData(widget.index.toString());
    setState(() {
      DateTime inputDateTime = DateTime.parse(result[0]['date']);
      _amountController.text = result[0]['amount'].toString();
      _categoryController.text = result[0]['category'].toString();
      _descriptionController.text = result[0]['description'].toString();
      _dateController.text = DateFormat('dd.MM.yyyy HH:mm').format(inputDateTime);
      _selectedOption = result[0]['type'].toString();
    });
  }

  @override
  void initState() {
    _getTransactionDataFromDatabase();
    _amountController.addListener(() {
      final text = _amountController.text;
      _amountController.value = _amountController.value.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
    _categoryController.addListener(() {
      final text = _categoryController.text;
      _categoryController.value = _categoryController.value.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
    _descriptionController.addListener(() {
      final text = _descriptionController.text;
      _descriptionController.value = _descriptionController.value.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
    _dateController.addListener(() {
      final text = _dateController.text;
      _dateController.value = _dateController.value.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<String>(
            value: _selectedOption,
            items: const [
              DropdownMenuItem(
                value: "0",
                child: Text("Потрачено"),
              ),
              DropdownMenuItem(
                value: "1",
                child: Text("Получено"),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedOption = value!;
              });
            },
          ),
          Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      svc.FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'))
                    ],
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Сумма',
                      suffixIcon: Icon(Icons.currency_ruble),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Поле обязательно для заполнения';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _amountController.text = value;
                      });
                    },
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    controller: _categoryController,
                    decoration: const InputDecoration(
                        labelText: 'Категория',
                        hintText: 'Другое',
                        suffixIcon: Icon(Icons.category)),
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: "Описание",
                      suffixIcon: Icon(Icons.description),
                    ),
                  ),
                  TextFormField(
                    readOnly: true,
                    textDirection: svc.TextDirection.ltr,
                    textInputAction: TextInputAction.done,
                    controller: _dateController,
                    onTap: () {
                      showDatePicker(
                        initialEntryMode: DatePickerEntryMode.calendar,
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      ).then((date) {
                        if (date != null) {
                          showTimePicker(
                              context: context, initialTime: TimeOfDay.now())
                              .then((time) {
                            if (time != null) {
                              _dateController.text =
                                  DateFormat('dd.MM.yyyy HH:mm').format(DateTime(
                                      date.year, date.month, date.day, time.hour,
                                      time.minute));
                            }
                          });
                        }});
                    },
                    decoration: const InputDecoration(
                      labelStyle: TextStyle(),
                      labelText: "Дата",
                      suffixIcon: Icon(Icons.date_range),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Поле обязательно для заполнения';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _dateController.text = value;
                      });
                    },
                  ),
                ],
              ))
        ],
      ),
      actions: [
        ElevatedButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        ElevatedButton(
          child: const Text("Save"),
          onPressed: () {
            if (_formKey.currentState != null &&
                _formKey.currentState!.validate()) {
              if(_categoryController.text == '') {
                setState(() => _categoryController.text = 'Другое');
              }
              if(_descriptionController.text == '') {
                setState(() => _descriptionController.text = 'Нет описания');
              }
              widget.onFormSubmit(
                  _selectedOption.toString(),
                  _amountController.text,
                  _categoryController.text,
                  _descriptionController.text,
                  _dateController.text);
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
