// ignore: file_names
import 'package:flutter/material.dart';
import 'package:thrivewithms/constants/constants.dart';
import 'package:thrivewithms/models/meals.model.dart';

class MealDetailPage extends StatelessWidget {
  final Meals meal;

  const MealDetailPage({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: textNavy,
        elevation: 0,
        title: const Text(
          'Meal Detail',
          style: TextStyle(
            color: whiteColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(
          color: whiteColor,
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: Image.network(
                  meal.imageUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 250,
                      color: Colors.grey[100],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Image not available",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                            meal.category ?? "Meal",
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
                            meal.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textNavy,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: textNavy.withOpacity(0.1),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        meal.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.restaurant_menu_rounded,
                            color: Colors.orange.shade600,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Ingredients',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (meal.ingredients != null &&
                        meal.ingredients!.isNotEmpty)
                      ...meal.ingredients!.map<Widget>((ingredient) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: textNavy.withOpacity(0.1),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  color: Colors.orange.shade600,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  ingredient,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      })
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 20,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'No ingredients available',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
