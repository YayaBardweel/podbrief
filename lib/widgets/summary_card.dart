import 'package:echomind/mod/summary_model.dart';
import 'package:echomind/pages/FullSummaryPage.dart';
import 'package:flutter/material.dart';
import 'package:echomind/constants/colors.dart';


class SummaryCard extends StatelessWidget {
  final Summary summary;  // Use Summary model instead of Map

  const SummaryCard({Key? key, required this.summary}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Displaying the title
              Text(
                summary.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: kPrimaryColor,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 4),

              // Displaying the date
              Text(
                'Summarized on: ${summary.createdAt.toLocal().toString().split(' ')[0]}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),

              // Displaying the summary preview
              Text(
                summary.summaryText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: kTextColorDark.withOpacity(0.8),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // Navigate to FullSummaryPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullSummaryPage(summary: summary),
                        ),
                      );
                    },
                    icon: const Icon(Icons.visibility, color: kPrimaryColor),
                    label: const Text(
                      'View Full Summary',
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      // Action to share the summary (optional)
                    },
                    icon: const Icon(Icons.share, color: kPrimaryColor),
                    label: const Text(
                      'Share',
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
