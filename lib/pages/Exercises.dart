import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'routes.dart';

class Exercises extends StatelessWidget {
  final List<Map<String, String>> exerciseList = [
    {'title': 'Upper Body', 'imageUrl': 'lib/images/upperbody.svg'},
    {'title': 'Legs', 'imageUrl': 'lib/images/legs.svg'},
    {'title': 'Abs', 'imageUrl': 'lib/images/abs.svg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Exercises', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemCount: exerciseList.length,
          itemBuilder: (context, index) {
            final title = exerciseList[index]['title']!;
            return GestureDetector(
              onTap: () {
                if (title.toLowerCase() == 'abs') {
                  Navigator.pushNamed(context, AppRoutes.absExercises);
                } else if (title.toLowerCase() == 'legs') {
                  Navigator.pushNamed(context, AppRoutes.legsExercises);
                } else if (title.toLowerCase() == 'upper body') {
                  Navigator.pushNamed(context, AppRoutes.upperBodyExercises);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('$title page is not implemented yet.')),
                  );
                }
              },
              child: ExerciseCard(
                title: title,
                imageUrl: exerciseList[index]['imageUrl']!,
              ),
            );
          },
        ),
      ),
    );
  }
}

class ExerciseCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const ExerciseCard({Key? key, required this.title, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: SvgPicture.asset(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
