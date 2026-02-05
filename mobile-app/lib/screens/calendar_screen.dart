import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:thrivewithms/constants/constants.dart';
import 'package:thrivewithms/models/event.model.dart';
import 'package:thrivewithms/services/api_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  Map<DateTime, List<Event>> _events = {};
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      
      final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

      final events = await ApiService.fetchEvents(firstDay, lastDay);

      setState(() {
        _events = {};
        for (var event in events) {
          final day =
              DateTime(event.date.year, event.date.month, event.date.day);
          if (_events[day] == null) _events[day] = [];
          _events[day]!.add(event);
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  void _showAddEventDialog() {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String type = 'appointment';
    String description = '';
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text(
            'Add Event',
            style: TextStyle(color: textNavy),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Title is required' : null,
                    onSaved: (value) => title = value ?? '',
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'appointment',
                        child: Text('Appointment'),
                      ),
                      DropdownMenuItem(
                        value: 'medication',
                        child: Text('Medication'),
                      ),
                      DropdownMenuItem(
                        value: 'test',
                        child: Text('Test'),
                      ),
                    ],
                    onChanged: (value) => type = value ?? 'appointment',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 3,
                    onSaved: (value) => description = value ?? '',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (formKey.currentState?.validate() ?? false) {
                        formKey.currentState?.save();

                        setDialogState(() => isLoading = true);

                        try {
                          final Map<String, dynamic> eventData = {
                            'title': title.trim(),
                            'type': type,
                            'date': _selectedDay.toIso8601String(),
                          };

                          if (description.trim().isNotEmpty) {
                            eventData['description'] = description.trim();
                          }

                          final createdEvent =
                              await ApiService.createEvent(eventData);

                          if (!mounted) return;

                        
                          Navigator.pop(dialogContext);

                          
                          setState(() {
                            _loadEvents(); 
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Event added successfully'),
                              backgroundColor: textNavy,
                            ),
                          );
                        } catch (e) {
                         
                          if (mounted) {
                            setDialogState(() => isLoading = false);
                          }

                         
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    e.toString().replaceAll('Exception: ', '')),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 5),
                              ),
                            );

                            
                            if (e.toString().contains('timed out')) {
                              Navigator.pop(dialogContext);
                            }
                          }
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Calendar',
          style: TextStyle(
            color: textNavy,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: textNavy),
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
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Colors.orange.shade600,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.orange.shade600,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.orange.shade200,
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                _loadEvents(); // Reload events when month changes
              },
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_error != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading events: $_error',
                      style: const TextStyle(color: Colors.red),
                    ),
                    TextButton(
                      onPressed: _loadEvents,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: _buildEventsList(),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventDialog,
        backgroundColor: Colors.orange.shade600,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventsList() {
    final events = _getEventsForDay(_selectedDay);

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No events for this day',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        IconData iconData;
        Color iconColor;

        switch (event.type) {
          case 'appointment':
            iconData = Icons.calendar_today;
            iconColor = Colors.blue;
            break;
          case 'medication':
            iconData = Icons.medication;
            iconColor = Colors.green;
            break;
          case 'test':
            iconData = Icons.science;
            iconColor = Colors.purple;
            break;
          default:
            iconData = Icons.event;
            iconColor = Colors.grey;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: textNavy.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                iconData,
                color: iconColor,
              ),
            ),
            title: Text(
              event.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: textNavy,
              ),
            ),
            subtitle: event.description != null
                ? Text(
                    event.description!,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  )
                : null,
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red[400],
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Event'),
                    content: const Text(
                        'Are you sure you want to delete this event?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red[400]),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  try {
                    await ApiService.deleteEvent(event.id);

                    if (!mounted) return;

                    // Reload events after successful deletion
                    setState(() {
                      _loadEvents();
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Event deleted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(e.toString().replaceAll('Exception: ', '')),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }
}
