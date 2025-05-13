import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/deformat_provider.dart';
import '../../core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/deformat_record.dart';

class DeformatPage extends StatefulWidget {
  const DeformatPage({super.key});

  @override
  State<DeformatPage> createState() => _DeformatPageState();
}

class _DeformatPageState extends State<DeformatPage> {
  int rotationTurns = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<DeformatProvider>().fetchDeformats(),
    );
  }

  Widget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AppBar(
        title: Text(
          'Деформат',
          style: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryButtonTextColor,
          ),
        ),
        backgroundColor: AppColors.primaryButtonColor,
        actions: [
          Tooltip(
            message: 'Оновити дані',
            child: IconButton(
              onPressed: () {
                context.read<DeformatProvider>().fetchDeformats();
              },
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterButtons(BuildContext context) {
    final provider = context.watch<DeformatProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: 100,
              child: _buildDateButton(
                context,
                'Сьогодні',
                'today',
                provider.dateRangeType == 'today',
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: _buildDateButton(
                context,
                'Тиждень',
                'week',
                provider.dateRangeType == 'week',
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: _buildCustomDateButton(context, provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateButton(
      BuildContext context, String text, String type, bool isSelected) {
    return GestureDetector(
      onTap: () => context.read<DeformatProvider>().setDateRange(type),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[300] : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey[400]!),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomDateButton(
      BuildContext context, DeformatProvider provider) {
    String buttonText = 'Обрати період';
    if (provider.dateRangeType == 'custom' &&
        provider.startDate != null &&
        provider.endDate != null) {
      buttonText =
          "${provider.startDate!.day.toString().padLeft(2, '0')}.${provider.startDate!.month.toString().padLeft(2, '0')} - ${provider.endDate!.day.toString().padLeft(2, '0')}.${provider.endDate!.month.toString().padLeft(2, '0')}";
    }

    return GestureDetector(
      onTap: () async {
        final DateTimeRange? picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDateRange:
              provider.startDate != null && provider.endDate != null
                  ? DateTimeRange(
                      start: provider.startDate!, end: provider.endDate!)
                  : null,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primaryButtonColor,
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
          context.read<DeformatProvider>().setDateRange(
                'custom',
                start: picked.start,
                end: picked.end,
              );
        }
      },
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: provider.dateRangeType == 'custom'
              ? Colors.grey[300]
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey[400]!),
        ),
        alignment: Alignment.center,
        child: Text(
          buttonText,
          style: TextStyle(
            color: provider.dateRangeType == 'custom'
                ? Colors.black
                : Colors.grey[700],
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildBarChart(List<MapEntry<int, DeformatRecord>> sortedEntries) {
    if (sortedEntries.isEmpty) {
      return const Center(
        child: Text(
          'Немає даних для відображення',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        rotationQuarterTurns: rotationTurns,
        maxY: sortedEntries
                .map((e) => e.value.iceMass + e.value.defMass)
                .reduce((a, b) => a > b ? a : b) *
            1.2,
        barTouchData: _buildBarTouchData(sortedEntries),
        titlesData: _buildTitlesData(sortedEntries),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10000,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        barGroups: _buildBarGroups(sortedEntries),
      ),
    );
  }

  BarTouchData _buildBarTouchData(
      List<MapEntry<int, DeformatRecord>> sortedEntries) {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        direction: TooltipDirection.auto,
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        tooltipPadding: const EdgeInsets.all(18),
        // tooltipRoundedRadius: 8,
        // tooltipBgColor: Colors.black87,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final deformat = sortedEntries[groupIndex].value;
          return BarTooltipItem(
            // '${deformat.iceName}\n'
            'Маса: ${deformat.defMass.toStringAsFixed(1)} кг\n'
            'Ice-Маса: ${deformat.iceMass.toStringAsFixed(1)} кг\n'
            'Лінія: ${deformat.lineName}',
            const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          );
        },
      ),
    );
  }

  FlTitlesData _buildTitlesData(
      List<MapEntry<int, DeformatRecord>> sortedEntries) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            if (value < 0 || value >= sortedEntries.length) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: RotatedBox(
                quarterTurns: -1,
                child: Text(
                  '${sortedEntries[value.toInt()].key}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          maxIncluded: false,
          interval: 10000,
          getTitlesWidget: (value, meta) {
            final rounded = (value / 1000).ceil();

            return RotatedBox(
              quarterTurns: -1,
              child: Text(
                value == 0 ? "0" : '${rounded.toStringAsFixed(1)}k',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      leftTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(
      List<MapEntry<int, DeformatRecord>> sortedEntries) {
    if (sortedEntries.isEmpty) {
      return [];
    }

    final maxValue = sortedEntries
        .map((e) => e.value.iceMass + e.value.defMass)
        .reduce((a, b) => a > b ? a : b);

    return sortedEntries
        .asMap()
        .entries
        .map(
          (entry) => BarChartGroupData(
            barsSpace: -20,
            x: entry.key,
            barRods: [
              BarChartRodData(
                fromY: 0,
                toY: entry.value.value.iceMass,
                color: Colors.blue[300],
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(6),
                ),
              ),
              BarChartRodData(
                fromY: entry.value.value.iceMass,
                toY: entry.value.value.iceMass + entry.value.value.defMass,
                color: AppColors.primaryButtonColor,
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          ),
        )
        .toList();
  }

  Widget _buildDeformatsList(
      List<MapEntry<int, DeformatRecord>> sortedEntries) {
    return ListView.builder(
      itemCount: sortedEntries.length,
      itemBuilder: (context, index) {
        final deformat = sortedEntries[index].value;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          surfaceTintColor: Colors.blueAccent,
          child: ListTile(
            title: Text(
              'Лінія ${deformat.iceLine}: ${deformat.iceName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Лінія: ${deformat.lineName}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Деформат: ${deformat.defMass.toStringAsFixed(1)} кг',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryButtonColor,
                  ),
                ),
                Text(
                  'Ice: ${deformat.iceMass.toStringAsFixed(1)} кг',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Text(
        'Error: $error',
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('No data available'),
    );
  }

  Widget _buildContent(BuildContext context, DeformatProvider provider) {
    final groupedDeformats = provider.getGroupedDeformats();
    final sortedEntries = groupedDeformats.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Column(
      children: [
        _buildDateFilterButtons(context),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > constraints.maxHeight;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: isLandscape
                    ? Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildBarChart(sortedEntries),
                          ),
                          const SizedBox(width: 16),
                          // Expanded(
                          //   flex: 1,
                          //   child: _buildDeformatsList(sortedEntries),
                          // ),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: _buildBarChart(sortedEntries),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Divider(
                              color: Colors.grey,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: _buildDeformatsList(sortedEntries),
                          ),
                        ],
                      ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar() as PreferredSizeWidget,
      body: Consumer<DeformatProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState();
          }

          if (provider.error.isNotEmpty) {
            return _buildErrorState(provider.error);
          }

          if (provider.deformats.isEmpty) {
            return _buildEmptyState();
          }

          return _buildContent(context, provider);
        },
      ),
    );
  }
}
