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
  final bool showFilters;

  const AllFailuresPage({
    Key? key,
    required this.category,
    required this.categoryType,
    this.startDate,
    this.endDate,
    this.showFilters = false,
  }) : super(key: key);

  static Widget allFailures() {
    return const AllFailuresPage(
      category: 'all',
      categoryType: 'all',
      showFilters: true,
    );
  }

  @override
  _AllFailuresPageState createState() => _AllFailuresPageState();
}

class _AllFailuresPageState extends State<AllFailuresPage> {
  String _sortColumn = 'dtStart';
  bool _sortAscending = true;
  String? selectedLine;
  String? selectedDepName;
  String? selectedFailName;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    startDate = widget.startDate;
    endDate = widget.endDate;
  }

  Widget _buildFilterButtons(List<FailureRecord> failures) {
    final uniqueLines = failures.map((e) => e.lineName).toSet().toList();
    final uniqueDepNames = failures.map((e) => e.depName).toSet().toList();
    final uniqueFailNames = failures.map((e) => e.failName).toSet().toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            _buildFilterDropdown(
              'Лінія',
              selectedLine,
              uniqueLines,
              (value) => setState(() => selectedLine = value),
            ),
            const SizedBox(width: 8),
            _buildFilterDropdown(
              'Підрозділ',
              selectedDepName,
              uniqueDepNames,
              (value) => setState(() => selectedDepName = value),
            ),
            const SizedBox(width: 8),
            _buildFilterDropdown(
              'Тип простою',
              selectedFailName,
              uniqueFailNames,
              (value) => setState(() => selectedFailName = value),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () async {
                final DateTimeRange? picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: startDate != null && endDate != null
                      ? DateTimeRange(start: startDate!, end: endDate!)
                      : null,
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Colors.blue,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Colors.black,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (picked != null) {
                  setState(() {
                    startDate = picked.start;
                    endDate = picked.end;
                  });
                }
              },
              icon: const Icon(Icons.date_range),
              label: Text(
                startDate != null && endDate != null
                    ? '${startDate!.day.toString().padLeft(2, '0')}.${startDate!.month.toString().padLeft(2, '0')} - ${endDate!.day.toString().padLeft(2, '0')}.${endDate!.month.toString().padLeft(2, '0')}'
                    : 'Період',
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  selectedLine = null;
                  selectedDepName = null;
                  selectedFailName = null;
                  startDate = null;
                  endDate = null;
                });
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Скинути'),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _sortAscending = !_sortAscending;
                });
              },
              icon: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
              label: Text(_sortAscending ? 'Спочатку нові' : 'Спочатку старі'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String? selectedValue,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButton<String>(
        value: selectedValue,
        hint: Text(label),
        underline: const SizedBox(),
        items: [
          DropdownMenuItem<String>(
            value: null,
            child: Text('Всі $label'),
          ),
          ...items.map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              )),
        ],
        onChanged: onChanged,
      ),
    );
  }

  List<FailureRecord> _filterFailures(List<FailureRecord> failures) {
    var filteredFailures = failures.where((failure) {
      bool dateInRange = _isDateInRange(failure.dtStart);
      if (widget.categoryType == 'all') {
        if (!dateInRange) return false;
        if (selectedLine != null && failure.lineName != selectedLine)
          return false;
        if (selectedDepName != null && failure.depName != selectedDepName)
          return false;
        if (selectedFailName != null && failure.failName != selectedFailName)
          return false;
        return true;
      }

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

    // Сортування по даті
    filteredFailures.sort((a, b) {
      final comparison = a.dtStart.compareTo(b.dtStart);
      return _sortAscending ? comparison : -comparison;
    });

    return filteredFailures;
  }

  bool _isDateInRange(DateTime date) {
    if (startDate == null || endDate == null) return true;
    final startOfDay =
        DateTime(startDate!.year, startDate!.month, startDate!.day);
    final endOfDay =
        DateTime(endDate!.year, endDate!.month, endDate!.day, 23, 59, 59);
    return date.isAfter(startOfDay) && date.isBefore(endOfDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showFilters
          ? null
          : AppBar(
              title: Text(
                'Простої: ${widget.category == 'all' ? "Всі" : widget.category}',
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () =>
                      context.read<FailureProvider>().fetchFailures(),
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

          if (widget.showFilters) {
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  title: Text(
                    'Простої: ${widget.category == 'all' ? "Всі" : widget.category}',
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () =>
                          context.read<FailureProvider>().fetchFailures(),
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(66),
                    child: _buildFilterButtons(failureProvider.failures),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final failure = failures[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                              Text('Підрозділ: ${failure.depName}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: failure.depName == "Не заповнено"
                                        ? Colors.red
                                        : Colors.blue,
                                  )),
                              Text('Лінія: ${failure.lineName}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  )),
                              if (failure.comment.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Коментар: ${failure.comment == 'None' ? "Відсутній" : failure.comment}',
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: failures.length,
                  ),
                ),
              ],
            );
          } else {
            return ListView.builder(
              itemCount: failures.length,
              itemBuilder: (context, index) {
                final failure = failures[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        Text('Підрозділ: ${failure.depName}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: failure.depName == "Не заповнено"
                                  ? Colors.red
                                  : Colors.blue,
                            )),
                        Text('Лінія: ${failure.lineName}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            )),
                        if (failure.comment.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Коментар: ${failure.comment == 'None' ? "Відсутній" : failure.comment}',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
