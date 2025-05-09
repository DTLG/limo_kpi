import 'package:flutter/material.dart';
import '../entities/metric.dart';

abstract class MetricsRepository {
  Future<List<Metric>> getMetrics();
}
