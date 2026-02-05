// ignore: file_names
import 'package:flutter/material.dart';
import 'package:thrivewithms/constants/constants.dart';
import 'package:thrivewithms/featuresScreens/MealDetail.dart';
import 'package:thrivewithms/models/meals.model.dart';
import 'package:thrivewithms/services/api_service.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  final ApiService apiService = ApiService();
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: textNavy,
        elevation: 0,
        title: const Text(
          "Meals",
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: textNavy.withOpacity(0.1),
                    width: 1.5,
                  ),
                ),
                child: DropdownButton<String>(
                  hint: Text(
                    "Select category",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  value: selectedCategory,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.orange.shade600,
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text("All")),
                    DropdownMenuItem(
                        value: "Breakfast", child: Text("Breakfast")),
                    DropdownMenuItem(value: "Lunch", child: Text("Lunch")),
                    DropdownMenuItem(value: "Dinner", child: Text("Dinner")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Meals>>(
                future: ApiService.fetchMeals(category: selectedCategory),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.orange.shade600,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Loading meals...",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Error loading meals",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No meals found!",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final meals = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: meals.length,
                    itemBuilder: (context, index) {
                      final meal = meals[index];
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: textNavy.withOpacity(0.1),
                            width: 1.5,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MealDetailPage(meal: meal),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                child: Image.network(
                                  meal.imageUrl,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: double.infinity,
                                      height: 200,
                                      color: Colors.grey[100],
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                padding: const EdgeInsets.all(16),
                                child: Row(
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
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: textNavy,
                                        ),
                                      ),
                                    ),
                                    Container(
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
                                  ],
                                ),
                              ),
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

/* class MealDetailPage extends StatelessWidget {
  final Meals meal;

  const MealDetailPage({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meal Detail',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: textNavy,
        iconTheme: IconThemeData(
          color: whiteColor,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12.0),
                bottomRight: Radius.circular(12.0),
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
                    color: Colors.grey[300],
                    child: const Icon(Icons.error, color: Colors.red),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meal.description,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (meal.ingredients != null && meal.ingredients!.isNotEmpty)
                    ...meal.ingredients!.map<Widget>((ingredient) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        padding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 16.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          ingredient,
                          style: const TextStyle(fontSize: 15),
                        ),
                      );
                    })
                  else
                    const Text(
                      'No ingredients available.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 */