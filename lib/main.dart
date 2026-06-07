import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  double _firstOperand = 0;
  String _operator = '';
  bool _justCalculated = false;
  bool _hasDecimal = false;

  void _onButton(String label) {
    setState(() {
      if (label == 'C') {
        _display = '0';
        _expression = '';
        _firstOperand = 0;
        _operator = '';
        _justCalculated = false;
        _hasDecimal = false;
        return;
      }

      if (label == '⌫') {
        if (_display.length > 1) {
          if (_display.endsWith('.')) _hasDecimal = false;
          _display = _display.substring(0, _display.length - 1);
        } else {
          _display = '0';
          _hasDecimal = false;
        }
        return;
      }

      if (label == '±') {
        if (_display != '0') {
          if (_display.startsWith('-')) {
            _display = _display.substring(1);
          } else {
            _display = '-$_display';
          }
        }
        return;
      }

      if (label == '%') {
        final val = double.tryParse(_display) ?? 0;
        _display = _cleanNumber(val / 100);
        _hasDecimal = _display.contains('.');
        return;
      }

      final isOperator = label == '+' || label == '-' || label == '×' || label == '÷';

      if (isOperator) {
        _firstOperand = double.tryParse(_display) ?? 0;
        _operator = label;
        _expression = '${_cleanNumber(_firstOperand)} $label';
        _justCalculated = false;
        _hasDecimal = false;
        _display = '0';
        return;
      }

      if (label == '=') {
        if (_operator.isEmpty) return;
        final second = double.tryParse(_display) ?? 0;
        _expression = '${_cleanNumber(_firstOperand)} $_operator ${_cleanNumber(second)} =';
        double result = 0;
        switch (_operator) {
          case '+':
            result = _firstOperand + second;
            break;
          case '-':
            result = _firstOperand - second;
            break;
          case '×':
            result = _firstOperand * second;
            break;
          case '÷':
            if (second == 0) {
              _display = 'Error';
              _operator = '';
              _justCalculated = true;
              return;
            }
            result = _firstOperand / second;
            break;
        }
        _display = _cleanNumber(result);
        _operator = '';
        _justCalculated = true;
        _hasDecimal = _display.contains('.');
        return;
      }

      if (label == '.') {
        if (_hasDecimal) return;
        if (_justCalculated) {
          _display = '0.';
          _justCalculated = false;
        } else {
          _display = '$_display.';
        }
        _hasDecimal = true;
        return;
      }

      if (_justCalculated) {
        _display = label;
        _expression = '';
        _justCalculated = false;
        _hasDecimal = false;
      } else if (_display == '0') {
        _display = label;
      } else {
        if (_display.replaceAll('-', '').replaceAll('.', '').length >= 12) return;
        _display = '$_display$label';
      }
    });
  }

  String _cleanNumber(double value) {
    if (value.isNaN || value.isInfinite) return 'Error';
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }
    String s = value.toStringAsFixed(8);
    s = s.replaceAll(RegExp(r'0+$'), '');
    s = s.replaceAll(RegExp(r'\.$'), '');
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_expression.isNotEmpty)
                      Text(
                        _expression,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 20,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        _display,
                        style: TextStyle(
                          color: _display == 'Error' ? Colors.redAccent : Colors.white,
                          fontSize: 72,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: Color(0xFF3A3A3C), height: 1),
            _buildKeypad(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    const rows = [
      ['C', '±', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '-'],
      ['1', '2', '3', '+'],
      ['⌫', '0', '.', '='],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: rows.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: row.map((label) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: _CalcButton(
                      label: label,
                      onTap: () => _onButton(label),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CalcButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _CalcButton({required this.label, required this.onTap});

  @override
  State<_CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<_CalcButton> {
  bool _pressed = false;

  Color get _bgColor {
    switch (widget.label) {
      case 'C':
      case '±':
      case '%':
        return const Color(0xFF636366);
      case '÷':
      case '×':
      case '-':
      case '+':
      case '=':
        return const Color(0xFFFF9F0A);
      default:
        return const Color(0xFF2C2C2E);
    }
  }

  Color get _textColor {
    switch (widget.label) {
      case 'C':
      case '±':
      case '%':
        return Colors.white;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          height: 70,
          decoration: BoxDecoration(
            color: _pressed ? _bgColor.withOpacity(0.7) : _bgColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                color: _textColor,
                fontSize: widget.label == '⌫' ? 22 : 26,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
