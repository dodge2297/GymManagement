import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Exercises extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Black AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
        title: const Text(
          'Exercises',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(), // Smooth scrolling
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, // 1 per row for full width
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1, // Makes the cards square
          ),
          itemCount: exerciseList.length,
          itemBuilder: (context, index) {
            return ExerciseCard(
              title: exerciseList[index]['title']!,
              imageUrl: exerciseList[index]['imageUrl']!,
            );
          },
        ),
      ),
    );
  }
}

// Exercise List (Cardio Removed)
final List<Map<String, String>> exerciseList = [
  {'title': 'Upper Body', 'imageUrl': 'lib/images/upperbody.svg'},
  {'title': 'Legs', 'imageUrl': 'lib/images/legs.svg'},
  {'title': 'Abs', 'imageUrl': 'lib/images/abs.svg'},
];

class ExerciseCard extends StatelessWidget {
  final String title;
  final String imageUrl;

  const ExerciseCard({required this.title, required this.imageUrl, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
state