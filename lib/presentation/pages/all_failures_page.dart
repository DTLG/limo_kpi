import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../domain/entities/failure_record.dart';
import '../providers/failure_provider.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/error_animation.dart';

class AllFailuresPage extends StatefulWidget {
  const AllFailuresPage({Key? key}) : super(key: key);

  @override
  _AllFailuresPageState createState() => _AllFailuresPageState();
}

class _AllFailuresPageState extends State<AllFailuresPage> {
  String _sortColumn = 'dtStart';
  bool _sortAscending = true;
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

  void _sort<T>(Comparable<T> Function(FailureRecord f) getField) {
    setState(() {
      final provider = context.read<FailureProvider>();
      final failures = _filterFailuresByDate(provider.failures);
      failures.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return _sortAscending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Всі простої'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<FailureProvider>().fetchFailures(),
          ),
        ],
      ),
      body: GestureDetector(
        // onHorizontalDragEnd: (details) {
        //   if (details.primaryVelocity! > 0) {
        //     Navigator.pop(context);
        //   }
        // },
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

              final failures = _filterFailuresByDate(failureProvider.failures);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          sortColumnIndex: _getSortColumnIndex(),
                          sortAscending: _sortAscending,
                          columns: [
                            DataColumn(
                              label: const Text('Дата початку'),
                              onSort: (columnIndex, ascending) {
                                setState(() {
                                  _sortColumn = 'dtStart';
                                  _sortAscending = ascending;
                                });
                                _sort<DateTime>((f) => f.dtStart);
                              },
                            ),
                            DataColumn(
                              label: const Text('Дата закінчення'),
                              onSort: (columnIndex, ascending) {
                                setState(() {
                                  _sortColumn = 'dtFinish';
                                  _sortAscending = ascending;
                                });
                                _sort<DateTime>((f) => f.dtFinish);
                              },
                            ),
                            DataColumn(
                              label: const Text('Підрозділ'),
                              onSort: (columnIndex, ascending) {
                                setState(() {
                                  _sortColumn = 'depName';
                                  _sortAscending = ascending;
                                });
                                _sort<String>((f) => f.depName);
                              },
                            ),
                            DataColumn(
                              label: const Text('Лінія'),
                              onSort: (columnIndex, ascending) {
                                setState(() {
                                  _sortColumn = 'line';
                                  _sortAscending = ascending;
                                });
                                _sort<num>((f) => f.line);
                              },
                            ),
                            DataColumn(
                              label: const Text('Тип простою'),
                              onSort: (columnIndex, ascending) {
                                setState(() {
                                  _sortColumn = 'failName';
                                  _sortAscending = ascending;
                                });
                                _sort<String>((f) => f.failName);
                              },
                            ),
                            DataColumn(
                              label: const Text('Тривалість (хв)'),
                              onSort: (columnIndex, ascending) {
                                setState(() {
                                  _sortColumn = 'minutes';
                                  _sortAscending = ascending;
                                });
                                _sort<num>((f) => f.minutes);
                              },
                            ),
                            DataColumn(
                              label: const Text('Коментар'),
                              onSort: (columnIndex, ascending) {
                                setState(() {
                                  _sortColumn = 'comment';
                                  _sortAscending = ascending;
                                });
                                _sort<String>((f) => f.comment);
                              },
                            ),
                          ],
                          rows: failures.map((failure) {
                            return DataRow(
                              cells: [
                                DataCell(Text(failure.dtStart
                                    .toString()
                                    .split(' ')[0]
                                    .substring(5))),
                                DataCell(Text(failure.dtFinish
                                    .toString()
                                    .split(' ')[0]
                                    .substring(5))),
                                DataCell(Text(failure.depName)),
                                DataCell(Text(failure.line.toString())),
                                DataCell(Text(failure.failName)),
                                DataCell(Text(failure.minutes.toString())),
                                DataCell(Text(failure.comment)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
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

  int? _getSortColumnIndex() {
    switch (_sortColumn) {
      case 'dtStart':
        return 0;
      case 'dtFinish':
        return 1;
      case 'depName':
        return 2;
      case 'line':
        return 3;
      case 'failName':
        return 4;
      case 'minutes':
        return 5;
      case 'comment':
        return 6;
      default:
        return null;
    }
  }
}
