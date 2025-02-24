import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? prevValue;
  final double? percentageChange;
  final IconData icon;
  final Color iconColor;

  const MetricCard({
    Key? key,
    required this.title,
    required this.value,
    this.prevValue,
    this.percentageChange,
    required this.icon,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFFF7F9F8),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Color(0xFFD8E0DE)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title and icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Color(0xFFDD9178),
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.labelSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Value
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge,
            ),

            SizedBox(height: 8),

            // Percentage and subtitle
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (percentageChange != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: percentageChange! >= 0
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        // Adding a colored border
                        color: percentageChange! >= 0
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        width: 1, // Adjust thickness as needed
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          percentageChange! >= 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color: percentageChange! >= 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${percentageChange!.abs().toStringAsFixed(2)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: percentageChange! >= 0
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (prevValue != null)
                  Padding(
                    padding: EdgeInsets.only(
                      left: percentageChange != null ? 8.0 : 0.0,
                    ),
                    child: Text(
                      prevValue!,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
