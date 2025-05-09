import 'package:flutter/material.dart';
import 'dart:math' as math;

class PieChart extends StatefulWidget {
  final List<num> data;
  final List<String> labels;
  final List<Color> colors;
  final bool animated;
  final List<DateTime> dates;
  final Function(String) onCategorySelected;

  const PieChart({
    Key? key,
    required this.data,
    required this.labels,
    required this.colors,
    required this.dates,
    required this.onCategorySelected,
    this.animated = false,
  }) : super(key: key);

  @override
  State<PieChart> createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> {
  final Map<String, bool> _selectedLabels = {};
  int? _hoveredIndex;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _initializeLabels();
    _endDate = DateTime.now();
    _startDate = _endDate!.subtract(const Duration(days: 30));
  }

  void _initializeLabels() {
    _selectedLabels.clear();
    for (var label in widget.labels) {
      _selectedLabels[label] = true;
    }
  }

  @override
  void didUpdateWidget(PieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.labels != widget.labels) {
      _initializeLabels();
    }
  }

  List<num> get _filteredData {
    final List<num> filteredData = [];
    for (int i = 0; i < widget.data.length; i++) {
      if (_selectedLabels[widget.labels[i]] == true &&
          _isDateInRange(widget.dates[i])) {
        filteredData.add(widget.data[i]);
      } else {
        filteredData.add(0);
      }
    }
    return filteredData;
  }

  bool _isDateInRange(DateTime date) {
    if (_startDate == null || _endDate == null) return true;
    return date.isAfter(_startDate!) &&
        date.isBefore(_endDate!.add(const Duration(days: 1)));
  }

  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate!,
        end: _endDate!,
      ),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _showDetailedData(String category, num value) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Простій: ${value.toStringAsFixed(2)}'),
            Text(
                'Обрана дата з/до: ${_startDate?.toString().split(' ')[0].substring(5)} : ${_endDate?.toString().split(' ')[0].substring(5)}'),
            const SizedBox(height: 16),
            Text(
                'Частка від загального простою: ${(value / _filteredData.reduce((a, b) => a + b) * 100).toStringAsFixed(1)}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ок'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: _showDateRangePicker,
            icon: const Icon(Icons.date_range),
            label: Text(
              '${_startDate?.toString().split(' ')[0]} - ${_endDate?.toString().split(' ')[0]}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(double heightCoefficient) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * heightCoefficient,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.labels.length,
        itemBuilder: (context, index) {
          final total = _filteredData.reduce((a, b) => a + b);
          final percentage = total > 0
              ? (_filteredData[index] / total * 100).toStringAsFixed(1)
              : '0.0';
          final minutes = _filteredData[index].toStringAsFixed(1);

          return InkWell(
            onTap: () {
              setState(() {
                _hoveredIndex = _hoveredIndex == index ? null : index;
              });
              widget.onCategorySelected(widget.labels[index]);
            },
            onLongPress: () {
              if (_filteredData[index] > 0) {
                _showDetailedData(widget.labels[index], _filteredData[index]);
              }
            },
            child: Card(
              margin: const EdgeInsets.all(8),
              color:
                  _hoveredIndex == index ? widget.colors[index] : Colors.white,
              // padding: const EdgeInsets.all(8),

              // decoration: BoxDecoration(
              //   color: _hoveredIndex == index
              //       ? widget.colors[index].withOpacity(0.2)
              //       : Colors.transparent,
              //   border: Border(
              //     bottom: BorderSide(
              //       color: Colors.grey.withOpacity(0.2),
              //       width: 1,
              //     ),
              //   ),
              // ),
              child: Row(
                children: [
                  Checkbox(
                    value: _selectedLabels[widget.labels[index]] ?? true,
                    onChanged: (bool? value) {
                      setState(() {
                        _selectedLabels[widget.labels[index]] = value ?? true;
                      });
                    },
                    activeColor: widget.colors[index],
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    color: widget.colors[index],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.labels[index]} | \t$percentage% | \t$minutes хв',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChart() {
    final total = _filteredData.fold<num>(0, (a, b) => a + b);
    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.white, // темний фон
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomPaint(
                  size: Size.square(220),
                  painter: PieChartPainter(
                    data: _filteredData,
                    colors: widget.colors,
                    hoveredIndex: _hoveredIndex,
                    gap: 8, // градусів між секторами
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Загальний простій',
                  style: TextStyle(
                    color: Colors.blue[200],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  '${total % 1 == 0 ? total.toInt() : total.toStringAsFixed(2)} хв',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return Column(
            children: [
              // _buildDateRangeSelector(),
              Expanded(
                child: _buildChart(),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildLegend(0.4),
                ),
              ),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    // _buildDateRangeSelector(),
                    Expanded(child: _buildChart()),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildLegend(0.7),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<num> data;
  final List<Color> colors;
  final int? hoveredIndex;
  final double gap; // у градусах, наприклад 4-6

  PieChartPainter({
    required this.data,
    required this.colors,
    this.hoveredIndex,
    this.gap = 6, // градусів між секторами
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final total = data.fold<num>(0, (a, b) => a + b);
    if (total == 0) return;

    final thickness = radius * 0.25; // товщина кільця
    double startAngle = -math.pi / 2;
    final gapRadians = gap * math.pi / 180;

    for (int i = 0; i < data.length; i++) {
      if (data[i] == 0) continue;
      final sweepAngle = 2 * math.pi * (data[i] / total) - gapRadians;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = thickness *
            (i == hoveredIndex
                ? 1.2
                : 1.0) // збільшуємо товщину для вибраного сектора
        ..strokeCap = StrokeCap.round;

      // Малюємо тінь для вибраного сектора
      if (i == hoveredIndex) {
        final shadowPaint = Paint()
          ..color = colors[i].withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness * 1.4
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius - thickness / 2),
          startAngle + gapRadians / 2,
          sweepAngle > 0 ? sweepAngle : 0,
          false,
          shadowPaint,
        );
      }

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - thickness / 2),
        startAngle + gapRadians / 2,
        sweepAngle > 0 ? sweepAngle : 0,
        false,
        paint,
      );
      startAngle += 2 * math.pi * (data[i] / total);
    }
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.colors != colors ||
        oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.gap != gap;
  }
}
