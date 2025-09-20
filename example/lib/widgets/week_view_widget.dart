import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

import '../pages/event_details_page.dart';

class WeekViewWidget extends StatefulWidget {
  final double? width;

  const WeekViewWidget({super.key, this.width});

  @override
  State<WeekViewWidget> createState() => _WeekViewWidgetState();
}

class _WeekViewWidgetState extends State<WeekViewWidget> {
  double heightPerMinute = 1;
  final Map<int, Offset> _pointerPositions = {};
  final ValueNotifier<bool> canScrollNotifier = ValueNotifier(true);
  double initialDistance = 0;
  double initialHeightPerMinute = 1;

  // Create a custom day boundary: start at midnight and end 28 hours later (4 AM day after tomorrow)
  CustomDayBoundary get customDayBoundary {
    return CustomDayBoundary(
      startOffset: Duration(hours: 0), // Start at midnight
      endOffset:
          Duration(hours: 28), // End 28 hours later (4 AM day after tomorrow)
    );

    // Other examples:
    //
    // Night shift (6 PM to 6 AM next day):
    // CustomDayBoundary(
    //   startOffset: Duration(hours: -6), // 6 PM previous day
    //   endOffset: Duration(hours: 6),    // 6 AM same day
    // )
    //
    // Early morning shift (4 AM to 4 AM next day):
    // CustomDayBoundary(
    //   startOffset: Duration(hours: 4),  // 4 AM same day
    //   endOffset: Duration(hours: 28),   // 4 AM next day
    // )
  }

  double _calculateScrollOffset() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final boundary = customDayBoundary;

    // Calculate minutes from the start of the custom day boundary
    final minutesFromBoundaryStart = boundary.getMinutesFromStart(today, now);

    // If current time is before the boundary start, scroll to near the beginning
    if (minutesFromBoundaryStart < 0) {
      return 0;
    }

    // If current time is after the boundary end, scroll to near the end
    if (minutesFromBoundaryStart > boundary.totalMinutes) {
      return (boundary.totalMinutes - 60) * heightPerMinute; // Show last hour
    }

    // Normal case: scroll to current time position minus 1 hour for context
    return (minutesFromBoundaryStart - 60)
            .clamp(0, boundary.totalMinutes - 60) *
        heightPerMinute;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
        onPointerDown: (details) {
          print('pointer down ${details.pointer}');
          _pointerPositions[details.pointer] = details.position;
          if (_pointerPositions.length > 1) {
            setState(() {
              canScrollNotifier.value = false;
            });
          }
          if (_pointerPositions.length == 2) {
            final values = _pointerPositions.values.toList();
            initialDistance = (values[1].dy - values[0].dy).abs();
            initialHeightPerMinute = heightPerMinute;
          }
        },
        onPointerUp: (details) {
          print('pointer up ${details.pointer}');
          _pointerPositions.remove(details.pointer);
          if (_pointerPositions.length != 2) {
            setState(() {
              canScrollNotifier.value = true;
            });
          }
        },
        onPointerMove: (details) {
          if (_pointerPositions.containsKey(details.pointer)) {
            _pointerPositions[details.pointer] = details.position;
          }
          if (_pointerPositions.length == 2) {
            final values = _pointerPositions.values.toList();
            final distance = (values[1].dy - values[0].dy).abs();
            final delta = distance - initialDistance;
            final deltaPerMinute = delta / 60.0;
            print('delta per minute: $deltaPerMinute');
            setState(() {
              heightPerMinute = initialHeightPerMinute + deltaPerMinute;
            });
          }
        },
        child: WeekView(
          width: widget.width,
          showLiveTimeLineInAllDays: true,
          timeLineWidth: 65,
          keepScrollOffset: true,
          heightPerMinute: heightPerMinute,
          customDayBoundary: customDayBoundary,
          // testCurrentTime: DateTime(2025, 9, 13, 1, 0),
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
              customDayBoundary: customDayBoundary,
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
          scrollViewBuilder: (
              {required Widget child, required ScrollController controller}) {
            return ValueListenableBuilder<bool>(
              valueListenable: canScrollNotifier,
              builder: (context, canScroll, child) {
                return SingleChildScrollView(
                  physics: canScroll ? null : NeverScrollableScrollPhysics(),
                  controller: controller,
                  child: child,
                );
              },
              child: child,
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
        ));
  }
}

class DateEvents<T extends Object?> extends StatefulWidget {
  final DateTime date;
  final double width;
  final double height;
  final double heightPerMinute;
  final CustomDayBoundary? customDayBoundary;

  const DateEvents(
      {super.key,
      required this.date,
      required this.width,
      required this.height,
      required this.heightPerMinute,
      this.customDayBoundary});

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
    // Create sample events that span across the custom day boundary
    final events = <CalendarEventData<T>>[];

    if (widget.customDayBoundary != null) {
      // Early morning event (5 AM - 7 AM)
      events.add(CalendarEventData<T>(
        title: "Early Morning Task",
        date: widget.date,
        startTime: DateTime(
            widget.date.year, widget.date.month, widget.date.day, 5, 0),
        endTime: DateTime(
            widget.date.year, widget.date.month, widget.date.day, 7, 0),
      ));

      // Late night event (11 PM - 2 AM next day)
      events.add(CalendarEventData<T>(
        title: "Night Shift",
        date: widget.date,
        startTime: DateTime(
            widget.date.year, widget.date.month, widget.date.day, 23, 0),
        endTime: DateTime(
            widget.date.year, widget.date.month, widget.date.day + 1, 2, 0),
      ));

      // Midnight to 1 AM event (next day - near end of custom day)
      events.add(CalendarEventData<T>(
        title: "Midnight Meeting",
        date: widget.date,
        startTime: DateTime(
            widget.date.year, widget.date.month, widget.date.day, 0, 0),
        endTime: DateTime(
            widget.date.year, widget.date.month, widget.date.day, 1, 0),
      ));

      // 1:30 AM to 3:15 AM event (next day - near end of custom day)
      events.add(CalendarEventData<T>(
        title: "Late Night Work",
        date: widget.date,
        startTime: DateTime(
            widget.date.year, widget.date.month, widget.date.day + 1, 1, 30),
        endTime: DateTime(
            widget.date.year, widget.date.month, widget.date.day + 1, 3, 15),
      ));

      // 3:30 AM to 4 AM event (ends at boundary end)
      events.add(CalendarEventData<T>(
        title: "Final Task",
        date: widget.date,
        startTime: DateTime(
            widget.date.year, widget.date.month, widget.date.day + 1, 3, 30),
        endTime: DateTime(
            widget.date.year, widget.date.month, widget.date.day + 1, 5, 0),
      ));
    } else {
      // Standard event for regular day view
      events.add(CalendarEventData<T>(
        title: "Test Event",
        date: widget.date,
        startTime: widget.date.add(const Duration(hours: 6, minutes: 1)),
        endTime: widget.date.add(const Duration(hours: 7, minutes: 59)),
      ));
    }

    final arrangedEvents = eventArranger.arrange(
        events: events,
        height: widget.height,
        width: widget.width,
        heightPerMinute: widget.heightPerMinute,
        startHour: 0,
        customDayBoundary: widget.customDayBoundary,
        date: widget.date);

    return List.generate(arrangedEvents.length, (index) {
      return Positioned(
          top: arrangedEvents[index].top,
          bottom: arrangedEvents[index].bottom,
          left: arrangedEvents[index].left,
          right: arrangedEvents[index].right,
          child: _defaultEventTileBuilder(
            widget.date,
            arrangedEvents[index].events,
            Rect.fromLTWH(
                arrangedEvents[index].left,
                arrangedEvents[index].top,
                widget.width -
                    arrangedEvents[index].right -
                    arrangedEvents[index].left,
                widget.height -
                    arrangedEvents[index].bottom -
                    arrangedEvents[index].top),
            arrangedEvents[index].startDuration,
            arrangedEvents[index].endDuration,
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
