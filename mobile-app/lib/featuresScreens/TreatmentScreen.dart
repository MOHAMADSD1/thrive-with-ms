import 'package:flutter/material.dart';
import 'package:thrivewithms/constants/constants.dart';
import 'package:thrivewithms/models/treatment.model.dart';
import 'package:thrivewithms/services/api_service.dart';
import 'package:thrivewithms/featuresScreens/AddTreatmentScreen.dart';
import 'package:intl/intl.dart';

class TreatmentScreen extends StatefulWidget {
  const TreatmentScreen({Key? key}) : super(key: key);

  @override
  _TreatmentScreenState createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen> {
  List<Treatment> _treatments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTreatments();
  }

  Future<void> _loadTreatments() async {
    setState(() => _isLoading = true);
    try {
      final treatments = await ApiService.fetchTreatments();
      setState(() {
        _treatments = treatments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading treatments: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        title: const Text(
          'Your Treatments',
          style: TextStyle(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'You should add all current and past treatments. You can always go back and change your treatment information if needed.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _treatments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.medication_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No treatments added yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _treatments.length,
                            itemBuilder: (context, index) {
                              final treatment = _treatments[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: textNavy.withOpacity(0.1),
                                    width: 1.5,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  title: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade50,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          treatment.isStopped
                                              ? 'Stopped'
                                              : 'Active',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange.shade600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          treatment.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: textNavy,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          size: 14,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Started: ${DateFormat('MMMM yyyy').format(treatment.startDate)}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: PopupMenuButton(
                                      icon: Icon(
                                        Icons.more_vert,
                                        color: Colors.orange.shade600,
                                      ),
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                      ],
                                      onSelected: (value) async {
                                        if (value == 'delete') {
                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                  'Delete Treatment'),
                                              content: const Text(
                                                'Are you sure you want to delete this treatment?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  child: const Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirm == true) {
                                            try {
                                              await ApiService.deleteTreatment(
                                                treatment.id,
                                              );
                                              _loadTreatments();
                                            } catch (e) {
                                              if (mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Error deleting treatment: $e',
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        } else if (value == 'edit') {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddTreatmentScreen(
                                                initialTreatment: treatment,
                                              ),
                                            ),
                                          );
                                          if (result == true) {
                                            _loadTreatments();
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddTreatmentScreen(),
                          ),
                        );
                        if (result == true) {
                          _loadTreatments();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Add a new Treatment',
                        style: TextStyle(
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
