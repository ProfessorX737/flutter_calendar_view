import 'package:flutter/material.dart';

import '../enumerations.dart';
import '../extension.dart';
import '../widgets/n_day_view_widget.dart';
import '../widgets/responsive_widget.dart';
import 'create_event_page.dart';
import 'web/web_home_page.dart';

class NDayViewPageDemo extends StatefulWidget {
  const NDayViewPageDemo({super.key});

  @override
  _NDayViewPageDemoState createState() => _NDayViewPageDemoState();
}

class _NDayViewPageDemoState extends State<NDayViewPageDemo> {
  int selectedDayCount = 3; // Default to 3 days
  final List<int> dayCountOptions = [1, 2, 3, 4, 6, 7];

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      webWidget: WebHomePage(
        selectedView: CalendarView.week, // Use week view for web fallback
      ),
      mobileWidget: Scaffold(
        appBar: AppBar(
          title: Text('$selectedDayCount-Day View'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          actions: [
            PopupMenuButton<int>(
              icon: Icon(Icons.view_week),
              tooltip: 'Select number of days',
              onSelected: (int dayCount) {
                setState(() {
                  selectedDayCount = dayCount;
                });
              },
              itemBuilder: (BuildContext context) {
                return dayCountOptions.map((int dayCount) {
                  return PopupMenuItem<int>(
                    value: dayCount,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$dayCount Day${dayCount > 1 ? 's' : ''}'),
                        if (dayCount == selectedDayCount)
                          Icon(Icons.check, color: Theme.of(context).primaryColor),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          elevation: 8,
          onPressed: () => context.pushRoute(CreateEventPage()),
        ),
        body: Column(
          children: [
            // Quick selector for common day counts
            Container(
              height: 60,
              padding: EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dayCountOptions.length,
                itemBuilder: (context, index) {
                  final dayCount = dayCountOptions[index];
                  final isSelected = dayCount == selectedDayCount;
                  
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text('$dayCount'),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          selectedDayCount = dayCount;
                        });
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.3),
                      checkmarkColor: Theme.of(context).primaryColor,
                    ),
                  );
                },
              ),
            ),
            // Info text about current view
            Container(
              padding: EdgeInsets.all(8),
              child: Text(
                _getViewDescription(selectedDayCount),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // The actual N-day view
            Expanded(
              child: NDayViewWidget(
                numberOfDays: selectedDayCount,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getViewDescription(int dayCount) {
    switch (dayCount) {
      case 1:
        return 'Single day view - Traditional day calendar view';
      case 2:
        return 'Two-day view - Perfect for planning short trips or weekends';
      case 3:
        return 'Three-day view - Great for extended weekend planning';
      case 4:
        return 'Four-day view - Ideal for short work weeks or conferences';
      case 6:
        return 'Six-day view - Work week plus one extra day';
      case 7:
        return 'Seven-day view - Traditional full week view';
      default:
        return '$dayCount-day view - Custom view for your specific needs';
    }
  }
}