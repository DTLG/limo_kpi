import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../domain/entities/failure_record.dart';
import '../providers/failure_provider.dart';
import '../widgets/bar_chart.dart';
import '../widgets/pie_chart.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/error_animation.dart';

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
    return date.isAfter(_startDate!) &&
        date.isBefore(_endDate!.add(const Duration(days: 1)));
  }

  List<FailureRecord> _filterFailuresByDate(List<FailureRecord> failures) {
    return failures
        .where((failure) => _isDateInRange(failure.dtStart))
        .toList();
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

              List<String> pieLabels = groupedData.keys.toList();

              // Get dates for each group
              final pieDates = groupedData.values.map((failures) {
                return failures.map((f) => f.dtStart).toList();
              }).toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        DropdownButton<String>(
                          value: selectedCategory,
                          items: const [
                            DropdownMenuItem(
                              value: 'dep_name',
                              child: Text('За відділенням'),
                            ),
                            DropdownMenuItem(
                              value: 'line',
                              child: Text('За лінією'),
                            ),
                            // DropdownMenuItem(
                            //   value: 'fail_name',
                            //   child: Text('За типом простою'),
                            // ),
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
                        TextButton.icon(
                          onPressed: () async {
                            final DateTimeRange? picked =
                                await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                              initialDateRange: DateTimeRange(
                                start: _startDate ??
                                    DateTime.now()
                                        .subtract(const Duration(days: 30)),
                                end: _endDate ?? DateTime.now(),
                              ),
                            );
                            if (picked != null) {
                              setState(() {
                                _startDate = picked.start;
                                _endDate = picked.end;
                              });
                            }
                          },
                          icon: const Icon(Icons.date_range),
                          label: Text(
                            '${_startDate?.toString().split(' ')[0].substring(5)} - ${_endDate?.toString().split(' ')[0].substring(5)}',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PieChart(
                      data: pieData,
                      labels: pieLabels,
                      colors: AppColors.chartColors,
                      dates: pieDates.expand((dates) => dates).toList(),
                      onCategorySelected: (category) {
                        setState(() {
                          selectedValue = category;
                        });
                      },
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

  Widget _buildDetailsView(List<FailureRecord> failures, String category) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Details for $category',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: failures.length,
                itemBuilder: (context, index) {
                  final failure = failures[index];
                  return ListTile(
                    title: Text(failure.failName),
                    subtitle: Text(
                      'Line ${failure.line} - ${failure.depName}\n'
                      'Duration: ${failure.minutes.toStringAsFixed(1)} minutes',
                    ),
                    trailing: Text(
                      '${failure.dtStart.hour}:${failure.dtStart.minute.toString().padLeft(2, '0')}',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
