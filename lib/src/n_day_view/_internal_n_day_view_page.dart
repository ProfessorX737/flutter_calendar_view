// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../components/_internal_components.dart';
import '../components/week_view_components.dart';
import '../components/event_scroll_notifier.dart';
import '../enumerations.dart';
import '../event_arrangers/event_arrangers.dart';
import '../event_controller.dart';
import '../modals.dart';
import '../painters.dart';
import '../typedefs.dart';
import '../week_view/full_day_event_header.dart';

/// A single page for n-day view (can display 1 to N consecutive days).
class InternalNDayViewPage<T extends Object?> extends StatefulWidget {
  /// Width of the page.
  final double width;

  /// Height of the page.
  final double height;

  /// Dates to display on page (consecutive days).
  final List<DateTime> dates;

  /// Builds tile for a single event.
  final EventTileBuilder<T> eventTileBuilder;

  /// A calendar controller that controls all the events and rebuilds widget
  /// if event(s) are added or removed.
  final EventController<T> controller;

  /// A builder to build time line.
  final DateWidgetBuilder timeLineBuilder;

  /// Settings for hour indicator lines.
  final HourIndicatorSettings hourIndicatorSettings;

  /// Custom painter for hour line.
  final CustomHourLinePainter hourLinePainter;

  /// Settings for half hour indicator lines.
  final HourIndicatorSettings halfHourIndicatorSettings;

  /// Settings for quarter hour indicator lines.
  final HourIndicatorSettings quarterHourIndicatorSettings;

  /// Flag to display live line.
  final bool showLiveLine;

  /// Settings for live time indicator.
  final LiveTimeIndicatorSettings liveTimeIndicatorSettings;

  ///  Height occupied by one minute time span.
  final double heightPerMinute;

  /// Width of timeline.
  final double timeLineWidth;

  /// Offset of timeline.
  final double timeLineOffset;

  /// Height occupied by one hour time span.
  final double hourHeight;

  /// Arranger to arrange events.
  final EventArranger<T> eventArranger;

  /// Flag to display vertical line or not.
  final bool showVerticalLine;

  /// Offset for vertical line offset.
  final double verticalLineOffset;

  /// Builder for day title.
  final DateWidgetBuilder dayBuilder;

  /// Builder for week number.
  final WeekNumberBuilder weekNumberBuilder;

  /// Builds custom PressDetector widget
  final DetectorBuilder dayDetectorBuilder;

  /// Height of day title.
  final double dayTitleHeight;

  /// Width of each day column.
  final double dayTitleWidth;

  /// Called when user taps on event tile.
  final CellTapCallback<T>? onTileTap;

  /// Called when user long press on event tile.
  final CellTapCallback<T>? onTileLongTap;

  /// Called when user double tap on any event tile.
  final CellTapCallback<T>? onTileDoubleTap;

  /// Called when user long press on calendar.
  final DatePressCallback? onDateLongPress;

  /// Called when user taps on day view page.
  final DateTapCallback? onDateTap;

  /// Minimum slot size
  final MinuteSlotSize minuteSlotSize;

  /// Builder for full day events.
  final FullDayEventBuilder<T>? fullDayEventBuilder;

  /// first hour displayed
  final int startHour;

  /// last hour displayed
  final int endHour;

  /// Show half hour indicator
  final bool showHalfHours;

  /// Show quarter hour indicator
  final bool showQuarterHours;

  /// Emulate vertical line offset from hour line starts.
  final double emulateVerticalOffsetBy;

  /// If true this will show week day at bottom position.
  final bool showWeekDayAtBottom;

  /// Full day header title
  final String fullDayHeaderTitle;

  /// full day header text config
  final FullDayHeaderTextConfig fullDayHeaderTextConfig;

  /// A scroll controller for week view.
  final ScrollController nDayViewScrollController;

  /// A scroll controller for page view.
  final ScrollController pageScrollController;

  /// A scroll listener that will be applied on the page scroll controller.
  final VoidCallback scrollListener;

  /// Scroll configuration for this page.
  final EventScrollNotifier scrollConfiguration;

  /// Flag to keep scrollOffset of pages on page change
  final bool keepScrollOffset;

  /// Last scroll offset
  final double lastScrollOffset;

  /// Date events builder
  final DateEventsBuilder<T> dateEventsBuilder;

  /// Scroll view builder  
  final ScrollViewBuilder scrollViewBuilder;

  /// N-day decoration builder
  final WeekDecorationBuilder nDayDecorationBuilder;

  /// Main constructor for internal n-day view page.
  const InternalNDayViewPage({
    Key? key,
    required this.width,
    required this.height,
    required this.dates,
    required this.eventTileBuilder,
    required this.controller,
    required this.timeLineBuilder,
    required this.hourIndicatorSettings,
    required this.hourLinePainter,
    required this.halfHourIndicatorSettings,
    required this.quarterHourIndicatorSettings,
    required this.showLiveLine,
    required this.liveTimeIndicatorSettings,
    required this.heightPerMinute,
    required this.timeLineWidth,
    required this.timeLineOffset,
    required this.hourHeight,
    required this.eventArranger,
    required this.showVerticalLine,
    required this.verticalLineOffset,
    required this.dayBuilder,
    required this.weekNumberBuilder,
    required this.dayDetectorBuilder,
    required this.dayTitleHeight,
    required this.dayTitleWidth,
    required this.onTileTap,
    required this.onTileLongTap,
    required this.onTileDoubleTap,
    required this.onDateLongPress,
    required this.onDateTap,
    required this.minuteSlotSize,
    required this.fullDayEventBuilder,
    required this.startHour,
    required this.endHour,
    required this.showHalfHours,
    required this.showQuarterHours,
    required this.emulateVerticalOffsetBy,
    required this.showWeekDayAtBottom,
    required this.fullDayHeaderTitle,
    required this.fullDayHeaderTextConfig,
    required this.nDayViewScrollController,
    required this.pageScrollController,
    required this.scrollListener,
    required this.scrollConfiguration,
    required this.keepScrollOffset,
    required this.lastScrollOffset,
    required this.dateEventsBuilder,
    required this.scrollViewBuilder,
    required this.nDayDecorationBuilder,
  }) : super(key: key);

  @override
  _InternalNDayViewPageState<T> createState() => _InternalNDayViewPageState<T>();
}

class _InternalNDayViewPageState<T extends Object?> extends State<InternalNDayViewPage<T>> {
  late double _totalWidth;
  late double _timeLineWidth;
  late double _dayWidth;
  late List<CalendarEventData<T>> _fullDayEvents;

  @override
  void initState() {
    super.initState();
    _updateViewDimensions();
    widget.pageScrollController.addListener(widget.scrollListener);
  }

  @override
  void didUpdateWidget(InternalNDayViewPage<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateViewDimensions();
  }

  @override
  void dispose() {
    widget.pageScrollController.removeListener(widget.scrollListener);
    super.dispose();
  }

  void _updateViewDimensions() {
    _totalWidth = widget.width;
    _timeLineWidth = widget.timeLineWidth;
    _dayWidth = (_totalWidth - _timeLineWidth - widget.verticalLineOffset) / widget.dates.length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: _totalWidth,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: _timeLineWidth),
                ...List.generate(widget.dates.length, (index) {
                  final date = widget.dates[index];
                  return Expanded(
                    child: Container(
                      height: widget.dayTitleHeight,
                      child: widget.dayBuilder(date),
                    ),
                  );
                }),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.pageScrollController,
              child: SizedBox(
                height: widget.hourHeight * (widget.endHour - widget.startHour),
                width: _totalWidth,
                child: _buildMainView(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainView() {
    return Stack(
      children: [
        CustomPaint(
          size: Size(_totalWidth, widget.hourHeight * (widget.endHour - widget.startHour)),
          painter: HourLinePainter(
            lineColor: widget.hourIndicatorSettings.color,
            lineHeight: widget.hourIndicatorSettings.height,
            offset: widget.timeLineWidth + widget.hourIndicatorSettings.offset,
            minuteHeight: widget.heightPerMinute,
            verticalLineOffset: widget.verticalLineOffset,
            showVerticalLine: widget.showVerticalLine,
            startHour: widget.startHour,
            emulateVerticalOffsetBy: widget.emulateVerticalOffsetBy,
            endHour: widget.endHour,
          ),
        ),
        _buildTimeLine(),
        _buildDayColumns(),
        if (widget.showLiveLine) _buildLiveTimeIndicator(),
      ],
    );
  }

  Widget _buildTimeLine() {
    return Positioned(
      left: 0,
      top: 0,
      child: Container(
        height: widget.hourHeight * (widget.endHour - widget.startHour),
        width: widget.timeLineWidth,
        child: Column(
          children: List.generate(
            (widget.endHour - widget.startHour),
            (index) {
              final hour = widget.startHour + index;
              final time = DateTime(2021, 1, 1, hour, 0);
              
              return Container(
                height: widget.hourHeight,
                width: widget.timeLineWidth,
                child: widget.timeLineBuilder(time),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDayColumns() {
    return Positioned(
      left: widget.timeLineWidth,
      top: 0,
      child: Row(
        children: List.generate(widget.dates.length, (index) {
          final date = widget.dates[index];
          
          return Container(
            height: widget.hourHeight * (widget.endHour - widget.startHour),
            width: _dayWidth,
            child: widget.dateEventsBuilder(
              date: date,
              height: widget.hourHeight * (widget.endHour - widget.startHour),
              heightPerMinute: widget.heightPerMinute,
              width: _dayWidth,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLiveTimeIndicator() {
    final now = DateTime.now();
    if (now.hour < widget.startHour || now.hour >= widget.endHour) {
      return SizedBox.shrink();
    }

    final dayIndex = widget.dates.indexWhere((date) => 
        date.year == now.year && date.month == now.month && date.day == now.day);
    
    if (dayIndex == -1) {
      return SizedBox.shrink();
    }

    final minutesSinceStart = (now.hour - widget.startHour) * 60 + now.minute;
    final topOffset = minutesSinceStart * widget.heightPerMinute;
    final leftOffset = widget.timeLineWidth + (dayIndex * _dayWidth);

    return Positioned(
      left: leftOffset,
      top: topOffset,
      child: LiveTimeIndicator(
        liveTimeIndicatorSettings: widget.liveTimeIndicatorSettings,
        width: _dayWidth,
        timeLineWidth: 0,
      ),
    );
  }
}