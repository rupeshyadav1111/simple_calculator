import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';


void main() {
  runApp(MyApp());
}

// Root widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CalculatorPage(),
    );
  }
}
// Main Calculator Page
class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}
class _CalculatorPageState extends State<CalculatorPage> {
  String display = '';

 void onButtonClick(String value) {
  setState(() {
    if (value == 'C') {
      display = '';
    } else if (value == '=') {
      try {
        Parser p = Parser();
        Expression exp = p.parse(display.replaceAll('X', '*').replaceAll('÷', '/'));
        ContextModel cm = ContextModel();
        double result = exp.evaluate(EvaluationType.REAL, cm);
        if (result == result.toInt()) {
           display = result.toInt().toString();
        } else {
           display = result.toString();
        }
      } catch (e) {
        display = 'Error';
      }
    } else {
      display += value;
    }
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simple Calculator')),
      backgroundColor: Colors.grey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            alignment: Alignment.centerRight,
            child: Text(
              display,
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ),
          Divider(),
          
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(10),
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  buildButton('7'),
                  buildButton('8'),
                  buildButton('9'),
                  buildButton('÷'),
                  buildButton('4'),
                  buildButton('5'),
                  buildButton('6'),
                  buildButton('X'),
                  buildButton('1'),
                  buildButton('2'),
                  buildButton('3'),
                  buildButton('-'),
                  buildButton('C'),
                  buildButton('0'),
                  buildButton('='),
                  buildButton('+'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton(String text) {
    return ElevatedButton(
      onPressed: () => onButtonClick(text),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}