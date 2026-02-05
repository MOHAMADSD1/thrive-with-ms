import 'package:flutter/material.dart';
import 'package:thrivewithms/constants/constants.dart';
import 'package:thrivewithms/featuresScreens/SupplementDetail.dart';
import 'package:thrivewithms/models/supplements.model.dart';
import 'package:thrivewithms/services/api_service.dart';

class SupplementsScreen extends StatefulWidget {
  const SupplementsScreen({super.key});

  @override
  State<SupplementsScreen> createState() => _SupplementsScreenState();
}

class _SupplementsScreenState extends State<SupplementsScreen> {
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade50,
              Colors.white,
            ],
            stops: const [0.0, 0.8],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: textNavy,
              title: const Text(
                "Supplements",
                style: TextStyle(
                  color: whiteColor,
                ),
              ),
              iconTheme: const IconThemeData(
                color: whiteColor,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Supplements>>(
                future: ApiService.fetchSupplements(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No supplements found!"));
                  }
                  final supplements = snapshot.data!;
                  return GridView.builder(
                    padding: const EdgeInsets.all(10.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 cards per row
                      crossAxisSpacing:
                          16.0, // Horizontal spacing between cards
                      mainAxisSpacing: 16.0, // Vertical spacing between cards
                      childAspectRatio: 3 / 4, // Adjust card height/width ratio
                    ),
                    itemCount: supplements.length,
                    itemBuilder: (context, index) {
                      final supplement = supplements[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SupplementDetailPage(
                                    supplement: supplement),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: Image.network(
                                  supplement.imageUrl,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: double.infinity,
                                      height: 150,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  supplement.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textNavy,
                                  ),
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
