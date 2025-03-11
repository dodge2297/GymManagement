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

class LegsExercisesListPage extends StatefulWidget {
  const LegsExercisesListPage({Key? key}) : super(key: key);

  @override
  _LegsExercisesListPageState createState() => _LegsExercisesListPageState();
}

class _LegsExercisesListPageState extends State<LegsExercisesListPage> {
  late List<Exercise> legsExercises;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() {
    setState(() => isLoading = true);
    try {
      legsExercises = [
        Exercise(
          name: "Barbell Squat",
          setsReps: "4 Sets x 10 Reps",
          videoId: "i7J5h7BJ07g",
          instructions:
              "Stand with feet shoulder-width apart, lower yourself by bending knees, keep your back straight, then push up.",
          focus: "Quads, Hamstrings, Glutes, Core",
          image: "lib/images/barbell_squat.png",
        ),
        Exercise(
          name: "Leg Press",
          setsReps: "4 Sets x 12 Reps",
          videoId: "yZmx_Ac3880",
          instructions:
              "Position feet shoulder-width apart on the platform and push up without locking knees.",
          focus: "Quads, Hamstrings, Glutes",
          image: "lib/images/leg_press.png",
        ),
        Exercise(
          name: "Romanian Deadlift",
          setsReps: "4 Sets x 10 Reps",
          videoId: "Wou9zVQrAfs",
          instructions:
              "Keep a slight bend in knees, lower the bar while keeping your back straight, then return to standing.",
          focus: "Hamstrings, Glutes, Lower Back",
          image: "lib/images/romanian_deadlift.png",
        ),
        Exercise(
          name: "Lunges",
          setsReps: "3 Sets x 12 Reps (Each Leg)",
          videoId: "eFWCn5iEbTU",
          instructions:
              "Step forward with one leg, lower your body until your knee is at 90°. Then, return to standing and repeat.",
          focus: "Quads, Hamstrings, Glutes, Core",
          image: "lib/images/lunges.png",
        ),
        Exercise(
          name: "Bulgarian Split Squats",
          setsReps: "3 Sets x 12 Reps (Each Leg)",
          videoId: "XPlFxw_HbJk",
          instructions:
              "Place one foot on a bench behind you, lower your body until your thigh is parallel to the ground, then return to standing.",
          focus: "Quads, Glutes, Hamstrings",
          image: "lib/images/bulgarian_split_squats.png",
        ),
        Exercise(
          name: "Leg Extensions",
          setsReps: "3 Sets x 15 Reps",
          videoId: "MpEydcQ1oDw",
          instructions:
              "Sit on the leg extension machine, adjust the pad, and extend your legs until your knees are straight.",
          focus: "Quads",
          image: "lib/images/leg_extensions.png",
        ),
        Exercise(
          name: "Lying Hamstring Curls",
          setsReps: "4 Sets x 12 Reps",
          videoId: "SbSNUXPRkc8",
          instructions:
              "Lie on the machine and curl your legs toward your glutes, keeping your hips in contact with the pad.",
          focus: "Hamstrings",
          image: "lib/images/lying_hamstring_curls.png",
        ),
        Exercise(
          name: "Calf Raises",
          setsReps: "4 Sets x 15-20 Reps",
          videoId: "g_E7_q1z2bo",
          instructions:
              "Stand with feet shoulder-width apart, raise your heels as high as possible, then slowly lower them back down.",
          focus: "Calves (Gastrocnemius & Soleus)",
          image: "lib/images/calf_raises.png",
        ),
        Exercise(
          name: "Hack Squats",
          setsReps: "4 Sets x 10 Reps",
          videoId: "rYgNArpwE7E",
          instructions:
              "Place your feet on the platform, keep your back flat against the pad, and squat down to a 90° angle.",
          focus: "Quads, Glutes, Hamstrings",
          image: "lib/images/hack_squats.png",
        ),
        Exercise(
          name: "Sissy Squats",
          setsReps: "3 Sets x 12 Reps",
          videoId: "p_2jIY7foxA",
          instructions:
              "Stand with feet shoulder-width apart, lean back while lowering your body towards the ground, and return to standing.",
          focus: "Quads",
          image: "lib/images/sissy_squats.png",
        ),
      ];
    } catch (e) {
      legsExercises = [];
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
        title: const Text("Legs Exercises"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: legsExercises.length,
              itemBuilder: (context, index) {
                final exercise = legsExercises[index];
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
