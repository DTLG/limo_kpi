import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../domain/entities/failure_record.dart';
import '../providers/failure_provider.dart';
import '../widgets/pie_chart.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/error_animation.dart';
import '../providers/pie_chart_provider.dart';

class FailureChartPage extends StatefulWidget {
  const FailureChartPage({Key? key}) : super(key: key);

  @override
  _FailureChartPageState createState() => _FailureChartPageState();
}

class _FailureChartPageState extends State<FailureChartPage> {
  int? hoveredIndex;
  String selectedCategory = 'dep_name';
  String? selectedValue;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _endDate = DateTime.now();
    _startDate = _endDate!.subtract(const Duration(days: 30));
  }

  bool _isDateInRange(DateTime date) {
    if (_startDate == null || _endDate == null) return true;
    final startOfDay =
        DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
    final endOfDay =
        DateTime(_endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
    return date.isAfter(startOfDay) && // ← Без віднімання дня
        date.isBefore(endOfDay);

    // if (_startDate == null || _endDate == null) return true;
    // return date.isAfter(_startDate!) &&
    //     date.isBefore(_endDate!.add(const Duration(days: 1)));
  }

  List<FailureRecord> _filterFailuresByDate(List<FailureRecord> failures) {
    return failures
        .where((failure) => _isDateInRange(failure.dtStart))
        .toList();
  }

  void _updateDateRange(DateTime? start, DateTime? end) {
    setState(() {
      _startDate = start;
      _endDate = end;
    });
    Future.microtask(() {
      context.read<PieChartProvider>().setDateRange(start, end);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            Navigator.pop(context);
          }
        },
        onVerticalDragEnd: (details) async {
          if (details.primaryVelocity! > 0) {
            await context.read<FailureProvider>().fetchFailures();
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<FailureProvider>().fetchFailures();
          },
          child: Consumer<FailureProvider>(
            builder: (context, failureProvider, child) {
              if (failureProvider.isLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/lottiefiles/loading.json',
                        width: 200,
                        height: 200,
                      ),
                      const SizedBox(height: 20),
                      // const Text('Loading data...'),
                    ],
                  ),
                );
              }

              if (failureProvider.error.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const ErrorAnimation(),
                      const SizedBox(height: 20),
                      Text(failureProvider.error),
                    ],
                  ),
                );
              }

              // Group data based on selected category
              final groupedData = <String, List<FailureRecord>>{};
              for (var failure in failureProvider.failures) {
                String key;
                switch (selectedCategory) {
                  case 'dep_name':
                    key = failure.depName;
                    break;
                  case 'line':
                    key = failure.line.toString();
                    break;
                  case 'fail_name':
                    key = failure.failName;
                    break;
                  default:
                    key = failure.depName;
                }
                groupedData.putIfAbsent(key, () => []);
                groupedData[key]!.add(failure);
              }

              // Calculate totals for pie chart with date filtering
              final pieData = groupedData.values.map((failures) {
                final filteredFailures = _filterFailuresByDate(failures);
                return filteredFailures.fold<double>(
                    0, (sum, failure) => sum + failure.minutes);
              }).toList();

              // Формуємо pieLabels: якщо selectedCategory == 'line', то беремо lineName з першого FailureRecord у групі
              List<String> pieLabels;
              if (selectedCategory == 'line') {
                pieLabels = groupedData.values
                    .map((failures) =>
                        failures.isNotEmpty ? failures.last.lineName : '')
                    .toList();
              } else {
                pieLabels = groupedData.keys.toList();
              }

              // Get dates for each group
              final pieDates = groupedData.values.map((failures) {
                return failures.map((f) => f.dtStart).toList();
              }).toList();

              return Column(
                children: [
                  SafeArea(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.grey[400]!),
                          ),
                          child: DropdownButton<String>(
                            value: selectedCategory,
                            isExpanded: true,
                            underline: Container(),
                            icon: Icon(Icons.arrow_drop_down,
                                color: Colors.grey[700]),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            items: const [
                              DropdownMenuItem(
                                value: 'dep_name',
                                child: Text('За відділенням'),
                              ),
                              DropdownMenuItem(
                                value: 'line',
                                child: Text('За лінією'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedCategory = value;
                                  selectedValue = null;
                                  pieLabels = groupedData.keys.toList();
                                });
                              }
                            },
                          ),
                        ),
                        _buildDateFilterButtons(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PieChart(
                      data: pieData,
                      labels: pieLabels,
                      colors: AppColors.chartColors,
                      dates: pieDates,
                      onCategorySelected: (category) {
                        setState(() {
                          selectedValue = category;
                        });
                      },
                      categoryType: selectedCategory,
                      animated: true,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilterButtons() {
    final today = DateTime.now();
    final isToday = _startDate != null &&
        _endDate != null &&
        _startDate!.year == today.year &&
        _startDate!.month == today.month &&
        _startDate!.day == today.day &&
        _endDate!.year == today.year &&
        _endDate!.month == today.month &&
        _endDate!.day == today.day;

    final last7Start = today.subtract(const Duration(days: 6));
    final isLast7 = _startDate != null &&
        _endDate != null &&
        _startDate!.year == last7Start.year &&
        _startDate!.month == last7Start.month &&
        _startDate!.day == last7Start.day &&
        _endDate!.year == today.year &&
        _endDate!.month == today.month &&
        _endDate!.day == today.day;

    final last30Start = today.subtract(const Duration(days: 29));
    final isLast30 = _startDate != null &&
        _endDate != null &&
        _startDate!.year == last30Start.year &&
        _startDate!.month == last30Start.month &&
        _startDate!.day == last30Start.day &&
        _endDate!.year == today.year &&
        _endDate!.month == today.month &&
        _endDate!.day == today.day;

    final isCustom = !isToday && !isLast7 && !isLast30;

    String customLabel;
    if (_startDate != null && _endDate != null) {
      customLabel =
          "${_startDate!.day.toString().padLeft(2, '0')}.${_startDate!.month.toString().padLeft(2, '0')} - ${_endDate!.day.toString().padLeft(2, '0')}.${_endDate!.month.toString().padLeft(2, '0')}";
    } else {
      customLabel = "Custom Range";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFilterButton(
            label: 'Сьогодні',
            selected: isToday,
            onTap: () {
              _updateDateRange(
                DateTime(today.year, today.month, today.day),
                DateTime(today.year, today.month, today.day),
              );
            },
          ),
          const SizedBox(width: 4),
          _buildFilterButton(
            label: 'Останні 7 днів',
            selected: isLast7,
            onTap: () {
              _updateDateRange(
                DateTime(last7Start.year, last7Start.month, last7Start.day),
                DateTime(today.year, today.month, today.day),
              );
            },
          ),
          const SizedBox(width: 4),
          _buildFilterButton(
            label: isCustom ? customLabel : 'Обрати період',
            selected: isLast30 || isCustom,
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: today,
                initialDateRange: DateTimeRange(
                  start: _startDate ?? last30Start,
                  end: _endDate ?? today,
                ),
              );
              if (picked != null) {
                _updateDateRange(picked.start, picked.end);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          decoration: BoxDecoration(
            color: selected ? Colors.grey[300] : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey[400]!),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
