import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/result_provider.dart';
import 'Mild_screen.dart';
import 'Moderate_screen.dart';
import 'Severe_screen.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  void _navigateBySeverity(BuildContext context, String severity) {
    final s = severity.toLowerCase();

    if (s.contains("mild")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MildScreen()),
      );
    } else if (s.contains("moderate")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ModerateScreen()),
      );
    } else if (s.contains("severe")) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SevereScreen()),
      );
    }
  }

  Color _severityColor(String severity) {
    if (severity.toLowerCase().contains("mild")) return Colors.green;
    if (severity.toLowerCase().contains("moderate")) return Colors.orange;
    if (severity.toLowerCase().contains("severe")) return Colors.red;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResultProvider>(context);
    final severity = provider.severity;

    return Scaffold(
      body: SizedBox.expand(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/dashbg.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.black.withOpacity(0.3),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),

                          const SizedBox(width: 10),

                          const Text(
                            "Summary Dashboard",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Overall Card
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Overall Average: ${provider.overallAverage.toStringAsFixed(2)}%",
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              provider.asdDetected
                                  ? "ASD Detected"
                                  : "No ASD Detected",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: provider.asdDetected
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Severity Card
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Severity Level",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _severityColor(severity),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () =>
                                  _navigateBySeverity(context, severity),
                              child: Text(
                                severity.toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "Category Results",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      ...provider.allResults.map(
                        (r) => Card(
                          color: Colors.white.withOpacity(0.9),
                          child: ListTile(
                            title: Text(r.category),
                            subtitle: Text(
                              "CNN: ${r.cnn}% | XGB: ${r.xgboost}% | Overall: ${r.overall}%",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      color: Colors.white.withOpacity(0.92),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}
