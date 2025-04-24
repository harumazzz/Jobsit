import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class JobDetailPage extends StatelessWidget {
  const JobDetailPage({super.key, required this.jobId});

  final int jobId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Placeholder());
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('jobId', jobId));
  }
}
