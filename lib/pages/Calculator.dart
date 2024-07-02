import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class Calculator extends StatelessWidget {
  const Calculator({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const CalculatorBody(),
    );
  }
}

class CalculatorBody extends StatefulWidget {
  const CalculatorBody({super.key});

  @override
  State<CalculatorBody> createState() => _CalculatorBodyState();
}

class _CalculatorBodyState extends State<CalculatorBody> {
  String _output = "0";
  String _input = "";
  String _operator = "";
  double _num1 = 0;
  double _num2 = 0;

  void _buttonPressed(String value) {
    setState(() {
      if (value == "C") {
        _input = "";
        _output = "0";
        _num1 = 0;
        _num2 = 0;
        _operator = "";
      } else if (value == "+" || value == "-" || value == "*" || value == "/") {
        if (_input.isNotEmpty) {
          _num1 = double.parse(_input);
          _operator = value;
          _input = "";
        }
      } else if (value == "=") {
        if (_input.isNotEmpty) {
          _num2 = double.parse(_input);
          switch (_operator) {
            case "+":
              _output = (_num1 + _num2).toString();
              break;
            case "-":
              _output = (_num1 - _num2).toString();
              break;
            case "*":
              _output = (_num1 * _num2).toString();
              break;
            case "/":
              _output = (_num1 / _num2).toString();
              break;
          }
          _input = _output;
          _operator = "";
        }
      } else {
        _input += value;
        _output = _input;
      }
    });
  }

  Widget _buildButton(String value, {Color color = Colors.white}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(20),
            backgroundColor: const Color.fromARGB(255, 25, 32, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _buttonPressed(value),
          child: Text(
            value,
            style: TextStyle(fontSize: 24, color: color),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.centerRight,
          height: 120,
          child: Text(
            _output,
            style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.blue),
          ),
        ),
        const Divider(color: Colors.white),
        Column(
          children: [
            Row(
              children: <Widget>[
                _buildButton("7"),
                _buildButton("8"),
                _buildButton("9"),
                _buildButton("/", color: Colors.orange),
              ],
            ),
            Row(
              children: <Widget>[
                _buildButton("4"),
                _buildButton("5"),
                _buildButton("6"),
                _buildButton("*", color: Colors.orange),
              ],
            ),
            Row(
              children: <Widget>[
                _buildButton("1"),
                _buildButton("2"),
                _buildButton("3"),
                _buildButton("-", color: Colors.orange),
              ],
            ),
            Row(
              children: <Widget>[
                _buildButton("0"),
                _buildButton("C", color: Colors.red),
                _buildButton("=", color: Colors.green),
                _buildButton("+", color: Colors.orange),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
