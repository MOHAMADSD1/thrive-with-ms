import 'package:flutter/material.dart';
import 'package:thrivewithms/constants/constants.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../services/api_service.dart';
import '../models/exercises.model.dart';

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  final ApiService apiService = ApiService();
  String? selectedCategory;
  YoutubePlayerController? _activeController;
  int? _playingIndex;
  bool _isPlayerLoading = false;

  @override
  void dispose() {
    _activeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: textNavy,
              title: const Text(
                "Exercises",
                style: TextStyle(
                  color: whiteColor,
                ),
              ),
              iconTheme: const IconThemeData(
                color: whiteColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10.0, 8.0, 10.0, 4.0),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width *
                      0.5, // 50% of screen width
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 2.0),
                      child: DropdownButton<String>(
                        hint: Text("Filter by Category",
                            style: TextStyle(color: Colors.orange.shade600)),
                        value: selectedCategory,
                        isExpanded: true,
                        underline: Container(),
                        style: const TextStyle(color: textNavy, fontSize: 15),
                        items: const [
                          DropdownMenuItem(value: null, child: Text("All")),
                          DropdownMenuItem(
                              value: "strength", child: Text("Strength")),
                          DropdownMenuItem(
                              value: "stretch", child: Text("Stretch")),
                          DropdownMenuItem(
                              value: "relaxation", child: Text("Relaxation")),
                          DropdownMenuItem(
                              value: "balance", child: Text("Balance")),
                          DropdownMenuItem(
                              value: "mobility", child: Text("Mobility")),
                          DropdownMenuItem(value: "other", child: Text("Other"))
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Exercise>>(
                future: ApiService.fetchExercises(category: selectedCategory),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(textNavy),
                    ));
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No exercises found!"));
                  }

                  final exercises = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8.0),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      final isPlaying = _playingIndex == index;

                      return Card(
                        margin: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 8,
                          top: index == 0 ? 0 : 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        color: whiteColor,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.title,
                                style: const TextStyle(
                                  color: textNavy,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    if (isPlaying) {
                                      _activeController?.pause();
                                      _playingIndex = null;
                                      _activeController?.dispose();
                                      _activeController = null;
                                      _isPlayerLoading = false;
                                    } else {
                                      _activeController?.pause();
                                      _activeController?.dispose();
                                      _playingIndex = index;
                                      _isPlayerLoading = true;
                                      _activeController =
                                          YoutubePlayerController(
                                        initialVideoId: exercise.videoId,
                                        flags: const YoutubePlayerFlags(
                                          autoPlay: true,
                                          mute: false,
                                        ),
                                      );
                                    }
                                  });
                                  await Future.delayed(
                                      const Duration(milliseconds: 500));
                                  setState(() {
                                    _isPlayerLoading = false;
                                  });
                                },
                                child: isPlaying &&
                                        _activeController != null &&
                                        !_isPlayerLoading
                                    ? YoutubePlayer(
                                        controller: _activeController!,
                                        showVideoProgressIndicator: true,
                                        progressIndicatorColor:
                                            Colors.orange.shade600,
                                        aspectRatio: 16 / 9,
                                      )
                                    : _isPlayerLoading
                                        ? Center(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.orange.shade600),
                                            ),
                                          )
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              exercise.thumbnailUrl,
                                              width: double.infinity,
                                              height: 200,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Icon(
                                                  Icons.error,
                                                  size: 50,
                                                  color: Colors.orange.shade600,
                                                );
                                              },
                                            ),
                                          ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                exercise.derscription,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: textNavy,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Category: ${exercise.category}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textNavy,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Duration: ${exercise.duration}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textNavy,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
