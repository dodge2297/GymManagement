// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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

class AbsExercisesListPage extends StatefulWidget {
  const AbsExercisesListPage({Key? key}) : super(key: key);

  @override
  _AbsExercisesListPageState createState() => _AbsExercisesListPageState();
}

class _AbsExercisesListPageState extends State<AbsExercisesListPage> {
  late List<Exercise> absExercises;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() {
    setState(() => isLoading = true);
    try {
      absExercises = [
        Exercise(
          name: "Cable Crunch",
          setsReps: "4 Sets x 12 Reps",
          videoId: "ToJeyhydUxU",
          instructions:
              "Use a cable machine to crunch down slowly. Focus on squeezing your abs at the bottom.",
          focus: "Upper Abs",
          image: "lib/images/cable_crunch.png",
        ),
        Exercise(
          name: "Hanging Leg Raise",
          setsReps: "4 Sets x 10 Reps",
          videoId: "7FwGZ8qY5OU",
          instructions:
              "Hang from a bar and lift your legs to 90°, engaging lower abs.",
          focus: "Lower Abs",
          image: "lib/images/hanging_leg_raise.png",
        ),
        Exercise(
          name: "Decline Sit-Up",
          setsReps: "4 Sets x 15 Reps",
          videoId: "N7hf1_vcX5w",
          instructions:
              "On a decline bench, perform sit-ups for added resistance.",
          focus: "Abs",
          image: "lib/images/decline_situp.png",
        ),
        Exercise(
          name: "Ab Wheel Rollout",
          setsReps: "3 Sets x 12 Reps",
          videoId: "DA2QGI0NPWU",
          instructions:
              "Kneel down and roll forward with an ab wheel, keeping your core tight.",
          focus: "Core, Abs",
          image: "lib/images/ab_wheel_rollout.png",
        ),
        Exercise(
          name: "Russian Twists",
          setsReps: "3 Sets x 20 Reps",
          videoId: "Tau0hsW8iR0",
          instructions:
              "Sit with your knees bent and twist side to side using a medicine ball.",
          focus: "Obliques, Abs",
          image: "lib/images/russian_twists.png",
        ),
        Exercise(
          name: "Weighted Plank",
          setsReps: "3 Sets x 30 Sec",
          videoId: "H88Ip-MUWn0",
          instructions:
              "Hold a plank with added weight on your back for extra resistance.",
          focus: "Core, Abs",
          image: "lib/images/weighted_plank.png",
        ),
        Exercise(
          name: "Cable Woodchopper",
          setsReps: "4 Sets x 12 Reps",
          videoId: "iWxTGXIViro",
          instructions:
              "Use a cable machine to perform diagonal woodchoppers for rotational strength.",
          focus: "Obliques",
          image: "lib/images/cable_woodchopper.png",
        ),
        Exercise(
          name: "Machine Crunch",
          setsReps: "4 Sets x 12 Reps",
          videoId: "6GMKPQVERzw",
          instructions: "Use the ab crunch machine with slow, controlled reps.",
          focus: "Abs",
          image: "lib/images/machine_crunch.png",
        ),
        Exercise(
          name: "Hanging Knee Raise",
          setsReps: "4 Sets x 12 Reps",
          videoId: "RD_A-Z15ER4",
          instructions:
              "Hang from a bar and tuck your knees toward your chest to engage the lower abs.",
          focus: "Lower Abs",
          image: "lib/images/hanging_knee_raise.png",
        ),
        Exercise(
          name: "Medicine Ball Slam",
          setsReps: "3 Sets x 15 Reps",
          videoId: "CkO1mfSBvv4",
          instructions:
              "Slam the medicine ball with full force, engaging your entire core.",
          focus: "Abs, Full Body",
          image: "lib/images/medicine_ball_slam.png",
        ),
      ];
    } catch (e) {
      absExercises = [];
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Abs Exercises"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: absExercises.length,
              itemBuilder: (context, index) {
                final exercise = absExercises[index];
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
                            onReady: () {},
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
