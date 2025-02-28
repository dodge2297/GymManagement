import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// Exercise model class
class Exercise {
  final String name;
  final String setsReps;
  final String videoId;
  final String instructions;
  final String focus;
  final String image;

  Exercise({
    required this.name,
    required this.setsReps,
    required this.videoId,
    required this.instructions,
    required this.focus,
    required this.image,
  });
}

class UpperBodyExercisesListPage extends StatefulWidget {
  const UpperBodyExercisesListPage({Key? key}) : super(key: key);

  @override
  _UpperBodyExercisesListPageState createState() =>
      _UpperBodyExercisesListPageState();
}

class _UpperBodyExercisesListPageState
    extends State<UpperBodyExercisesListPage> {
  late List<Exercise> upperBodyExercises;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() {
    setState(() => isLoading = true);
    try {
      upperBodyExercises = [
        Exercise(
          name: "Bench Press (Flat)",
          setsReps: "4 Sets x 8-12 Reps",
          videoId: "YQ2s_Y7g5Qk",
          instructions: "Keep your back flat and push through your chest.",
          focus: "Chest, Triceps, Shoulders",
          image: "lib/images/bench_press.png",
        ),
        Exercise(
          name: "Incline Bench Press",
          setsReps: "4 Sets x 10 Reps",
          videoId: "8urE8Z8AMQ4",
          instructions: "Use a 30-45 degree incline for upper chest focus.",
          focus: "Upper Chest, Shoulders, Triceps",
          image: "lib/images/incline_bench_press.png",
        ),
        Exercise(
          name: "Chest Fly",
          setsReps: "3 Sets x 12 Reps",
          videoId: "eGjt4lk6g34",
          instructions: "Keep a slight bend in the elbows and stretch fully.",
          focus: "Chest",
          image: "lib/images/chest_fly.png",
        ),
        Exercise(
          name: "Pull-Ups",
          setsReps: "3 Sets x 8-12 Reps",
          videoId: "b3L_d3zACC0",
          instructions:
              "Use a full range of motion for maximum back engagement.",
          focus: "Back, Biceps, Core",
          image: "lib/images/pull_ups.png",
        ),
        Exercise(
          name: "Lat Pulldown",
          setsReps: "4 Sets x 10-12 Reps",
          videoId: "NAIEnMjN-6w",
          instructions:
              "Pull down to your chest while keeping your back straight.",
          focus: "Lats, Upper Back, Biceps",
          image: "lib/images/lat_pulldown.png",
        ),
        Exercise(
          name: "Seated Row",
          setsReps: "4 Sets x 12 Reps",
          videoId: "UCXxvVItLoM",
          instructions:
              "Keep your back straight and pull towards your midsection.",
          focus: "Back, Biceps",
          image: "lib/images/seated_row.png",
        ),
        Exercise(
          name: "Overhead Shoulder Press",
          setsReps: "4 Sets x 8-10 Reps",
          videoId: "WvLMauqrnK8",
          instructions:
              "Press the weight overhead without arching your lower back.",
          focus: "Shoulders, Triceps",
          image: "lib/images/shoulder_press.png",
        ),
        Exercise(
          name: "Lateral Raises",
          setsReps: "3 Sets x 12-15 Reps",
          videoId: "XPPfnSEATJA",
          instructions:
              "Raise dumbbells to the sides with a slight elbow bend.",
          focus: "Shoulders",
          image: "lib/images/lateral_raises.png",
        ),
        Exercise(
          name: "Bicep Curls",
          setsReps: "3 Sets x 12 Reps",
          videoId: "qeI6R6r4jlM",
          instructions:
              "Keep elbows close to your body and control the movement.",
          focus: "Biceps",
          image: "lib/images/bicep_curls.png",
        ),
        Exercise(
          name: "Tricep Dips",
          setsReps: "3 Sets x 10-12 Reps",
          videoId: "oA8Sxv2WeOs",
          instructions: "Lower yourself slowly and push up using your triceps.",
          focus: "Triceps, Chest, Shoulders",
          image: "lib/images/tricep_dips.png",
        ),
      ];
    } catch (e) {
      upperBodyExercises = [];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading exercises: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    super.dispose();
    // Clean up any remaining resources if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upper Body Exercises"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: upperBodyExercises.length,
              itemBuilder: (context, index) {
                final exercise = upperBodyExercises[index];
                return ExerciseCard(
                  exercise: exercise,
                  onTap: () => _showExerciseBottomSheet(context, exercise),
                );
              },
            ),
    );
  }

  void _showExerciseBottomSheet(BuildContext context, Exercise exercise) {
    late YoutubePlayerController youtubeController;
    try {
      youtubeController = YoutubePlayerController(
        initialVideoId: exercise.videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          disableDragSeek: false,
          loop: false,
          enableCaption: true,
        ),
      );

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return DraggableScrollableSheet(
                initialChildSize: 0.7,
                minChildSize: 0.4,
                maxChildSize: 0.9,
                expand: false,
                builder: (context, scrollController) {
                  return SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          YoutubePlayer(
                            controller: youtubeController,
                            showVideoProgressIndicator: true,
                            progressIndicatorColor: Colors.red,
                            onReady: () {
                              // Ensure the controller is ready
                            },
                            onEnded: (metaData) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Video ended')),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Sets & Reps: ${exercise.setsReps}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Focus: ${exercise.focus}",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Instructions:",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            exercise.instructions,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              youtubeController.pause();
                              Navigator.pop(context);
                            },
                            child: const Text("Close"),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ).then((_) {
        youtubeController.dispose();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading video: $e')),
      );
    }
  }
}

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  const ExerciseCard({Key? key, required this.exercise, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: Image.asset(
          exercise.image,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
        ),
        title: Text(
          exercise.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(exercise.setsReps),
        onTap: onTap,
      ),
    );
  }
}
