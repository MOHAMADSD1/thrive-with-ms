import 'package:flutter/material.dart';
import 'package:thrivewithms/constants/constants.dart';
import 'package:thrivewithms/models/supplements.model.dart';

class SupplementDetailPage extends StatelessWidget {
  final Supplements supplement;

  const SupplementDetailPage({super.key, required this.supplement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Supplement Detail',
          style: TextStyle(
            color: whiteColor,
          ),
        ),
        backgroundColor: textNavy,
        iconTheme: const IconThemeData(
          color: whiteColor,
        ),
      ),
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12.0),
                  bottomRight: Radius.circular(12.0),
                ),
                child: Image.network(
                  supplement.imageUrl,
                  width: double.infinity,
                  height: 330,
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
                      supplement.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      supplement.description,
                      style: const TextStyle(
                        fontSize: 16,
                        color: textNavy,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Food Sources',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      supplement.foodSources,
                      style: const TextStyle(
                        fontSize: 16,
                        color: textNavy,
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
