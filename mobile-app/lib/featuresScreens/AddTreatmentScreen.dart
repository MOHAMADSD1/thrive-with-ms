import 'package:flutter/material.dart';
import 'package:thrivewithms/constants/constants.dart';
import 'package:thrivewithms/services/api_service.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:intl/intl.dart';
import 'package:thrivewithms/models/treatment.model.dart';

class AddTreatmentScreen extends StatefulWidget {
  final Treatment? initialTreatment;

  const AddTreatmentScreen({
    super.key,
    this.initialTreatment,
  });

  @override
  _AddTreatmentScreenState createState() => _AddTreatmentScreenState();
}

class _AddTreatmentScreenState extends State<AddTreatmentScreen> {
  int _currentStep = 1;
  String? _selectedTreatment;
  DateTime? _startDate;
  bool? _isStopped;
  bool _isLoading = false;
  String _userId = '';
  String? _treatmentId;

  final List<String> _treatments = [
    'Avonex',
    'Gilenya',
    'Rituximab',
    'Tysabri',
  ];

  @override
  void initState() {
    super.initState();
    _initUserId();
    if (widget.initialTreatment != null) {
      _initializeEditingData();
    }
  }

  void _initializeEditingData() {
    final treatment = widget.initialTreatment!;
    setState(() {
      _selectedTreatment = treatment.name;
      _startDate = treatment.startDate;
      _isStopped = treatment.isStopped;
      _treatmentId = treatment.id;
    });
  }

  Future<void> _initUserId() async {
    try {
      final userId = await ApiService.getUserId();
      setState(() {
        _userId = userId;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting user ID: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime displayDate = _startDate ?? DateTime.now();
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.white,
            colorScheme: ColorScheme.light(
              primary: Colors.orange.shade600,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select Month/Year',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textNavy,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    width: 300,
                    child: CalendarDatePicker(
                      initialDate: displayDate,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      onDateChanged: (DateTime date) {
                        Navigator.of(context).pop(date);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = DateTime(picked.year, picked.month);
      });
    }
  }

  Future<void> _saveTreatment() async {
    if (_selectedTreatment == null ||
        _startDate == null ||
        _isStopped == null ||
        _userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please make sure you are logged in and all fields are filled'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final treatmentData = {
        'userId': _userId,
        'name': _selectedTreatment,
        'startDate': _startDate!.toIso8601String(),
        'isStopped': _isStopped,
      };

      if (_treatmentId != null) {
        await ApiService.updateTreatment(_treatmentId!, treatmentData);
      } else {
        await ApiService.addTreatment(treatmentData);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Error ${_treatmentId != null ? 'updating' : 'adding'} treatment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'What MS treatment would you like to add?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textNavy,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: _treatments.length,
            itemBuilder: (context, index) {
              final treatment = _treatments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: textNavy.withOpacity(0.1),
                    width: 1.5,
                  ),
                ),
                child: RadioListTile<String>(
                  title: Text(
                    treatment,
                    style: TextStyle(
                      color: _selectedTreatment == treatment
                          ? textNavy
                          : Colors.grey[700],
                      fontWeight: _selectedTreatment == treatment
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  value: treatment,
                  groupValue: _selectedTreatment,
                  activeColor: Colors.orange.shade600,
                  onChanged: (value) {
                    setState(() {
                      _selectedTreatment = value;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'When did you start this treatment?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textNavy,
          ),
        ),
        const SizedBox(height: 24),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: textNavy.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              _startDate == null
                  ? 'Select start date'
                  : DateFormat('MMMM yyyy').format(_startDate!),
              style: TextStyle(
                fontSize: 16,
                color: _startDate == null ? Colors.grey[600] : textNavy,
                fontWeight:
                    _startDate == null ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                color: Colors.orange.shade600,
                size: 20,
              ),
            ),
            onTap: () => _selectDate(context),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Did you stop the treatment?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textNavy,
          ),
        ),
        const SizedBox(height: 24),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: textNavy.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              RadioListTile<bool>(
                title: Text(
                  'Yes',
                  style: TextStyle(
                    color: _isStopped == true ? textNavy : Colors.grey[700],
                    fontWeight: _isStopped == true
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                value: true,
                groupValue: _isStopped,
                activeColor: Colors.orange.shade600,
                onChanged: (value) {
                  setState(() {
                    _isStopped = value;
                  });
                },
              ),
              RadioListTile<bool>(
                title: Text(
                  'No',
                  style: TextStyle(
                    color: _isStopped == false ? textNavy : Colors.grey[700],
                    fontWeight: _isStopped == false
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                value: false,
                groupValue: _isStopped,
                activeColor: Colors.orange.shade600,
                onChanged: (value) {
                  setState(() {
                    _isStopped = value;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool get _canContinue {
    switch (_currentStep) {
      case 1:
        return _selectedTreatment != null;
      case 2:
        return _startDate != null;
      case 3:
        return _isStopped != null;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: textNavy,
        elevation: 0,
        iconTheme: const IconThemeData(color: whiteColor),
        title: Text(
          _treatmentId != null ? 'Edit Treatment' : 'Step $_currentStep of 3',
          style: const TextStyle(
            color: whiteColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.orange.shade600,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Loading...",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.orange.shade50,
                    Colors.white.withOpacity(0.9),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _currentStep == 1
                          ? _buildStep1()
                          : _currentStep == 2
                              ? _buildStep2()
                              : _buildStep3(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canContinue
                          ? () {
                              if (_currentStep < 3) {
                                setState(() {
                                  _currentStep++;
                                });
                              } else {
                                _saveTreatment();
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        disabledBackgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentStep == 3 ? 'Save' : 'Continue',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
