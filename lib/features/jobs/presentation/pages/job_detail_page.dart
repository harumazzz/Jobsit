import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class JobDetailPage extends StatelessWidget {
  const JobDetailPage({super.key, required this.jobId});

  final int jobId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFefeff0),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 38.0,
            floating: true,
            backgroundColor: const Color(0xFFefeff0),
            flexibleSpace: const FlexibleSpaceBar(title: Text('Job Detail'), centerTitle: true),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(IconlyLight.bookmark),
                  tooltip: 'Bookmark',
                  iconSize: 30.0,
                  onPressed: () async {
                    // TODO(self): Implement bookmark functionality
                  },
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Job Title', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8.0),
                    const Text('Company Name', style: TextStyle(fontSize: 18.0, color: Colors.grey)),
                    const SizedBox(height: 16.0),
                    const Text('Job Description', style: TextStyle(fontSize: 16.0)),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _ApplyNavBar(),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('jobId', jobId));
  }
}

class _ApplyNavBar extends StatelessWidget {
  const _ApplyNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12.0), bottomRight: Radius.circular(12.0)),
      ),
      child: ElevatedButton(
        onPressed: () async {
          // TODO(self): Implement apply functionality
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 32.0),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0))),
        ),
        child: const Text('Apply Now', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
