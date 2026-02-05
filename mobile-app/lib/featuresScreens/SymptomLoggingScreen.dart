import 'package:flutter/material.dart';
import 'package:thrivewithms/models/symptom.model.dart';
import 'package:thrivewithms/services/api_service.dart';
import 'package:thrivewithms/constants/constants.dart';

class SymptomLoggingScreen extends StatefulWidget {
  final Symptom? initialSymptom;

  const SymptomLoggingScreen({
    Key? key,
    this.initialSymptom,
  }) : super(key: key);

  @override
  _SymptomLoggingScreenState createState() => _SymptomLoggingScreenState();
}

class _SymptomLoggingScreenState extends State<SymptomLoggingScreen> {
  late String _userId = '';
  final _notesController = TextEditingController();
  double _severity = 5;
  String _category = 'Physical';
  String? _selectedSymptom;
  List<Symptom> _symptoms = [];
  bool _isLoading = false;
  String? _editingSymptomId;

  // Predefined symptoms for each category
  final Map<String, List<String>> _categorySymptoms = {
    'Physical': [
      'Fatigue',
      'Numbness',
      'Tingling',
      'Muscle Weakness',
      'Balance Problems',
      'Vision Problems',
      'Pain',
      'Dizziness'
    ],
    'Emotional': [
      'Depression',
      'Anxiety',
      'Mood Swings',
      'Irritability',
      'Stress',
      'Emotional Sensitivity'
    ],
    'Mobility': [
      'Walking Difficulty',
      'Poor Coordination',
      'Tremors',
      'Muscle Spasms',
      'Stiffness',
      'Balance Issues'
    ],
    'Unique': [
      'Speech Problems',
      'Memory Issues',
      'Concentration Problems',
      'Sleep Disturbances',
      'Bladder Problems',
      'Heat Sensitivity'
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    if (widget.initialSymptom != null) {
      _initializeEditingData();
    }
  }

  void _initializeEditingData() {
    final symptom = widget.initialSymptom!;
    final symptomItem = symptom.symptom!.first;
    setState(() {
      _category = symptom.category;
      _selectedSymptom = symptomItem.name;
      _severity = symptomItem.severity.toDouble();
      _notesController.text = symptomItem.notes ?? '';
      _editingSymptomId = symptom.id;
    });
  }

  Future<void> _loadInitialData() async {
    try {
      await _initUserId();
      await _fetchSymptoms();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _initUserId() async {
    try {
    _userId = await ApiService.getUserId();
      print("User ID initialized: $_userId");
    } catch (e) {
      print("Error getting user ID: $e");
      throw Exception(
          "Could not get user ID. Please ensure you are logged in.");
    }
  }

  Future<void> _fetchSymptoms() async {
    if (_userId.isEmpty) {
      print("User ID is empty, attempting to initialize...");
      await _initUserId();
    }

    setState(() => _isLoading = true);
    try {
      final symptoms = await ApiService.fetchSymptomsByUser(_userId);
      if (mounted) {
      setState(() {
        _symptoms = symptoms;
        _isLoading = false;
      });
      }
    } catch (e) {
      print("Error fetching symptoms: $e");
      if (mounted) {
      setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching symptoms: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addSymptom() async {
    if (_selectedSymptom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a symptom"),
          backgroundColor: textNavy,
        ),
      );
      return;
    }

    if (_userId.isEmpty) await _initUserId();

    final symptomData = {
      "userId": _userId,
      "category": _category,
      "symptom": [
        {
          "name": _selectedSymptom,
          "severity": _severity.toInt(),
          "notes":
              _notesController.text.isNotEmpty ? _notesController.text : null,
        }
      ],
    };

    setState(() => _isLoading = true);
    try {
      await ApiService.createSymptom(symptomData);
      _notesController.clear();
      setState(() {
        _severity = 5;
        _selectedSymptom = null;
        _isLoading = false;
      });
      await _fetchSymptoms();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Symptom logged successfully"),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteSymptom(String symptomId) async {
    setState(() => _isLoading = true);
    try {
      await ApiService.deleteSymptom(symptomId);
      await _fetchSymptoms(); // Refresh the list
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Symptom deleted successfully")));
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _updateSymptom() async {
    if (_selectedSymptom == null || _editingSymptomId == null) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final symptomData = {
        "userId": _userId,
        "category": _category,
        "symptom": [
          {
            "name": _selectedSymptom,
            "severity": _severity.toInt(),
            "notes":
                _notesController.text.isNotEmpty ? _notesController.text : null,
          }
        ],
      };

      await ApiService.updateSymptom(_editingSymptomId!, symptomData);
      _notesController.clear();
      setState(() {
        _severity = 5;
        _selectedSymptom = null;
        _isLoading = false;
        _editingSymptomId = null;
      });
      await _fetchSymptoms();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Symptom updated successfully"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
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
          "Symptom Logger",
          style: TextStyle(
            color: whiteColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'View Symptom History',
            color: whiteColor,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SymptomHistoryScreen(symptoms: _symptoms),
                ),
              );

              if (result != null && result is Map<String, dynamic>) {
                if (result['delete'] == true && result['id'] != null) {
                  await _deleteSymptom(result['id']);
                }
              }
            },
          ),
        ],
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Selection Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: textNavy.withOpacity(0.1),
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.category_rounded,
                                      color: Colors.orange.shade600,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Select Symptom Category",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textNavy,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                    value: _category,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: textNavy.withOpacity(0.1),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: textNavy.withOpacity(0.1),
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                    onChanged: (value) {
                                  setState(() {
                                    _category = value!;
                                    _selectedSymptom = null;
                                  });
                    },
                                items: _categorySymptoms.keys
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                  ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Symptom Selection Card
                      if (_categorySymptoms[_category] != null)
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: textNavy.withOpacity(0.1),
                              width: 1.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.healing_rounded,
                                        color: Colors.orange.shade600,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "Select Symptom",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textNavy,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: _selectedSymptom,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: textNavy.withOpacity(0.1),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: textNavy.withOpacity(0.1),
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  hint: Text(
                                    "Select a symptom",
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  onChanged: (value) {
                                    setState(() => _selectedSymptom = value);
                                  },
                                  items: _categorySymptoms[_category]!
                                      .map((symptom) => DropdownMenuItem(
                                            value: symptom,
                                            child: Text(symptom),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Severity Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: textNavy.withOpacity(0.1),
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.show_chart_rounded,
                                      color: Colors.orange.shade600,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Symptom Severity",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textNavy,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Text(
                                    "Mild",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderThemeData(
                                        activeTrackColor:
                                            Colors.orange.shade600,
                                        inactiveTrackColor:
                                            Colors.orange.shade100,
                                        thumbColor: Colors.orange.shade600,
                                        overlayColor:
                                            Colors.orange.withOpacity(0.2),
                                        valueIndicatorColor:
                                            Colors.orange.shade600,
                                      ),
                                      child: Slider(
                    value: _severity,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: _severity.round().toString(),
                    onChanged: (value) {
                      setState(() => _severity = value);
                    },
                  ),
                                    ),
                                  ),
                                  Text(
                                    "Severe",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Notes Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: textNavy.withOpacity(0.1),
                            width: 1.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.note_alt_rounded,
                                      color: Colors.orange.shade600,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Additional Notes",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textNavy,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: textNavy.withOpacity(0.1),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: textNavy.withOpacity(0.1),
                                    ),
                                  ),
                                  hintText: "Add any additional notes here...",
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Add Symptom Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _editingSymptomId != null
                              ? _updateSymptom
                              : _addSymptom,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _editingSymptomId != null
                                ? "Update Symptom"
                                : "Log Symptom",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Recent Symptoms Section
                      if (_symptoms.isNotEmpty) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.history_rounded,
                                color: Colors.orange.shade600,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Recent Symptoms",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textNavy,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...(_symptoms.take(3).map((symptom) {
                          final symptomItem = symptom.symptom!.first;
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
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      symptom.category,
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
                                      "${symptomItem.name}",
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
                                      Icons.show_chart_rounded,
                                      size: 16,
                                      color: _getSeverityColor(
                                          symptomItem.severity),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Severity: ${symptomItem.severity}",
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
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.orange.shade600,
                                  size: 16,
                                ),
                              ),
                            ),
                          );
                        }).toList()),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Color _getSeverityColor(int severity) {
    if (severity <= 3) return Colors.green.shade600;
    if (severity <= 6) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}

// Separate screen for symptom history
class SymptomHistoryScreen extends StatelessWidget {
  final List<Symptom> symptoms;

  const SymptomHistoryScreen({Key? key, required this.symptoms})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: textNavy,
        elevation: 0,
        iconTheme: const IconThemeData(color: whiteColor),
        title: const Text(
          "Symptom History",
          style: TextStyle(
            color: whiteColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
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
        child: symptoms.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No symptoms logged yet",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
                        : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: symptoms.length,
                            itemBuilder: (context, index) {
                  final symptom = symptoms[index];
                              final symptomItem = symptom.symptom!.first;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: textNavy.withOpacity(0.1),
                        width: 1.5,
                      ),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              symptom.category,
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
                              symptomItem.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textNavy,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit_rounded,
                              size: 20,
                              color: Colors.orange.shade600,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Future.delayed(const Duration(milliseconds: 100),
                                  () {
                                if (context.mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SymptomLoggingScreen(
                                        initialSymptom: symptom,
                                      ),
                                    ),
                                  );
                                }
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                              color: Colors.orange.shade600,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Symptom'),
                                  content: const Text(
                                      'Are you sure you want to delete this symptom?'),
                                  actions: [
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    TextButton(
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(
                                            color: Colors.red.shade400),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.pop(context,
                                            {'delete': true, 'id': symptom.id});
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
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
                              symptom.date.toString().split('.').first,
                              style: TextStyle(
                                fontSize: 13,
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
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.orange.shade600,
                          size: 20,
                        ),
                      ),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.show_chart_rounded,
                                      color: Colors.orange.shade600,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Severity Level:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textNavy,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getSeverityColor(
                                          symptomItem.severity),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      "${symptomItem.severity}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (symptomItem.notes != null) ...[
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.note_alt_rounded,
                                        color: Colors.orange.shade600,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      "Notes:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: textNavy,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: textNavy.withOpacity(0.1),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(
                                    symptomItem.notes!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.4,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                  ),
                ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Color _getSeverityColor(int severity) {
    if (severity <= 3) return Colors.green.shade600;
    if (severity <= 6) return Colors.orange.shade600;
    return Colors.red.shade600;
  }
}
