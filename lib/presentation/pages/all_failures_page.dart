import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../domain/entities/failure_record.dart';
import '../providers/failure_provider.dart';
import '../providers/pie_chart_provider.dart';
import '../widgets/error_animation.dart';

class AllFailuresPage extends StatefulWidget {
  final String category;
  final String categoryType;
  final DateTime? startDate;
  final DateTime? endDate;

  const AllFailuresPage({
    Key? key,
    required this.category,
    required this.categoryType,
    this.startDate,
    this.endDate,
  }) : super(key: key);

  static Widget allFailures() {
    return const AllFailuresPage(
      category: 'all',
      categoryType: 'all',
    );
  }

  @override
  _AllFailuresPageState createState() => _AllFailuresPageState();
}

class _AllFailuresPageState extends State<AllFailuresPage> {
  String _sortColumn = 'dtStart';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
  }

  bool _isDateInRange(DateTime date) {
    if (widget.startDate == null || widget.endDate == null) return true;
    final startOfDay = DateTime(
        widget.startDate!.year, widget.startDate!.month, widget.startDate!.day);
    final endOfDay = DateTime(widget.endDate!.year, widget.endDate!.month,
        widget.endDate!.day, 23, 59, 59);
    return date.isAfter(startOfDay) && // ← Без віднімання дня
        date.isBefore(endOfDay);
  }

  List<FailureRecord> _filterFailures(List<FailureRecord> failures) {
    return failures.where((failure) {
      bool dateInRange = _isDateInRange(failure.dtStart);
      if (widget.categoryType == 'all') return dateInRange;

      bool categoryMatch = false;
      switch (widget.categoryType) {
        case 'line':
          categoryMatch = failure.lineName.toString() == widget.category;
          break;
        case 'dep_name':
          categoryMatch = failure.depName == widget.category;
          break;
        case 'failName':
          categoryMatch = failure.failName == widget.category;
          break;
      }

      return dateInRange && categoryMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Простої: ${widget.category}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<FailureProvider>().fetchFailures(),
          ),
        ],
      ),
      body: Consumer<FailureProvider>(
        builder: (context, failureProvider, child) {
          if (failureProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (failureProvider.error.isNotEmpty) {
            return Center(child: Text(failureProvider.error));
          }

          final failures = _filterFailures(failureProvider.failures);

          return ListView.builder(
            itemCount: failures.length,
            itemBuilder: (context, index) {
              final failure = failures[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Початок: ${failure.dtStart.toString().split(' ')[0].substring(5)} ${failure.dtStart.toString().split(' ')[1].substring(0, 5)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Кінець: ${failure.dtFinish.toString().split(' ')[0].substring(5)} ${failure.dtFinish.toString().split(' ')[1].substring(0, 5)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${failure.minutes} хв',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Підрозділ: ${failure.depName}'),
                      Text('Лінія: ${failure.line}'),
                      Text('Тип простою: ${failure.failName}'),
                      if (failure.comment.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Коментар: ${failure.comment}',
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
