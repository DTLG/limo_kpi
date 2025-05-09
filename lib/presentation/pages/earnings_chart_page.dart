import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../providers/metrics_provider.dart';
import '../widgets/bar_chart.dart';

class EarningsChartPage extends StatefulWidget {
  const EarningsChartPage({Key? key}) : super(key: key);

  @override
  _EarningsChartPageState createState() => _EarningsChartPageState();
}

class _EarningsChartPageState extends State<EarningsChartPage> {
  int? hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings Charts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<MetricsProvider>().fetchMetrics(),
          ),
        ],
      ),
      body: Consumer<MetricsProvider>(
        builder: (context, metricsProvider, child) {
          if (metricsProvider.isLoading) {
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

          if (metricsProvider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.network(
                    'https://assets8.lottiefiles.com/packages/lf20_qpwbiyxf.json',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 20),
                  Text(metricsProvider.error),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: metricsProvider.metrics.length,
            itemBuilder: (context, index) {
              final metric = metricsProvider.metrics[index];
              return MouseRegion(
                onEnter: (_) => setState(() => hoveredIndex = index),
                onExit: (_) => setState(() => hoveredIndex = null),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: hoveredIndex == index
                            ? metric.color.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.2),
                        blurRadius: hoveredIndex == index ? 12 : 6,
                        spreadRadius: hoveredIndex == index ? 4 : 2,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          metric.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: BarChart(
                            data: metric.data,
                            labels: metric.labels,
                            color: metric.color,
                            animated: hoveredIndex == index,
                          ),
                        ),
                      ),
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
