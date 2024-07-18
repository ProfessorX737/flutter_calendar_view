import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

import '../pages/event_details_page.dart';

class WeekViewWidget extends StatelessWidget {
  final GlobalKey<WeekViewState>? state;
  final double? width;
  final double heightPerMinute = 1;

  const WeekViewWidget({super.key, this.state, this.width});

  double _calculateScrollOffset() {
    final now = TimeOfDay.now();
    final minutesSinceStart = (now.hour - 1) * 60 + now.minute;
    return minutesSinceStart * heightPerMinute;
  }

  @override
  Widget build(BuildContext context) {
    return WeekView(
      key: state,
      width: width,
      showLiveTimeLineInAllDays: true,
      timeLineWidth: 65,
      keepScrollOffset: true,
      heightPerMinute: heightPerMinute,
      scrollOffset: _calculateScrollOffset(),
      liveTimeIndicatorSettings: LiveTimeIndicatorSettings(
        color: Colors.redAccent,
        showTime: true,
      ),
      onEventTap: (events, date) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailsPage(
              event: events.first,
            ),
          ),
        );
      },
      onEventLongTap: (events, date) {
        SnackBar snackBar = SnackBar(content: Text("on LongTap"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
    );
  }
}
