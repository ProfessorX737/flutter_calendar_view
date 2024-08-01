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
      dateEventsBuilder: (
          {required DateTime date,
          required double height,
          required double heightPerMinute,
          required double width}) {
        return DateEvents(
          date: date,
          height: height,
          heightPerMinute: heightPerMinute,
          width: width,
        );
      },
      weekDecorationBuilder: ({
        required double widthOffset,
        required double widthPerDay,
        required double heightPerMinute,
        required double width,
        required double height,
        required List<DateTime> dates,
      }) {
        return Positioned(
          top: 0,
          left: widthOffset,
          child: Container(
            width: widthPerDay,
            height: heightPerMinute * 60,
            color: Colors.redAccent,
          ),
        );
      },
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

class DateEvents<T extends Object?> extends StatefulWidget {
  final DateTime date;
  final double width;
  final double height;
  final double heightPerMinute;

  const DateEvents(
      {super.key,
      required this.date,
      required this.width,
      required this.height,
      required this.heightPerMinute});

  @override
  State<DateEvents<T>> createState() => _DateEventsState<T>();
}

class _DateEventsState<T> extends State<DateEvents<T>> {
  SideEventArranger<T> eventArranger = SideEventArranger<T>();

  Widget _defaultEventTileBuilder(
    DateTime date,
    List<CalendarEventData<T>> events,
    Rect boundary,
    DateTime startDuration,
    DateTime endDuration,
  ) =>
      DefaultEventTile(
        date: date,
        events: events,
        boundary: boundary,
        startDuration: startDuration,
        endDuration: endDuration,
      );

  /// Arrange events and returns list of [Widget] that displays event
  /// tile on display area. This method uses [eventArranger] to get position
  /// of events and [eventTileBuilder] to display events.
  List<Widget> _generateEvents(BuildContext context) {
    final eventData = CalendarEventData<T>(
      title: "Test",
      date: widget.date,
      startTime: widget.date.add(const Duration(hours: 6, minutes: 1)),
      endTime: widget.date.add(const Duration(hours: 7, minutes: 59)),
    );

    final events = eventArranger.arrange(
        events: [eventData],
        height: widget.height,
        width: widget.width,
        heightPerMinute: widget.heightPerMinute,
        startHour: 0);

    return List.generate(events.length, (index) {
      return Positioned(
          top: events[index].top,
          bottom: events[index].bottom,
          left: events[index].left,
          right: events[index].right,
          child: _defaultEventTileBuilder(
            widget.date,
            events[index].events,
            Rect.fromLTWH(
                events[index].left,
                events[index].top,
                widget.width - events[index].right - events[index].left,
                widget.height - events[index].bottom - events[index].top),
            events[index].startDuration,
            events[index].endDuration,
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    print('building events for ${widget.date}');
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Stack(
        children: _generateEvents(context),
      ),
    );
  }
}
