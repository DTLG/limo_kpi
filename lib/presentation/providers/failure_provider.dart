import 'package:flutter/material.dart';
import '../../domain/entities/failure_record.dart';
import '../../domain/repositories/failure_repository.dart';

class FailureProvider with ChangeNotifier {
  final FailureRepository repository;
  List<FailureRecord> _failures = [];
  bool _isLoading = true;
  String _error = '';

  FailureProvider({required this.repository}) {
    fetchFailures();
  }

  List<FailureRecord> get failures => _failures;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchFailures() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Add minimum 2 second delay
      await Future.delayed(const Duration(seconds: 3));

      _failures = await repository.getFailures();
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
