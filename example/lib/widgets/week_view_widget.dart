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

  double _calculateScrollOffset() {
    final now = TimeOfDay.now();
    final minutesSinceStart = (now.hour - 1) * 60 + now.minute;
    return minutesSinceStart * heightPerMinute;
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
