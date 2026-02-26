// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'package:flutter/material.dart';

import '../calendar_constants.dart';
import '../calendar_event_data.dart';
import '../constants.dart';
import '../enumerations.dart';
import '../event_arrangers/event_arrangers.dart';
import '../event_controller.dart';
import '../extensions.dart';
import '../modals.dart';
import '../style/header_style.dart';
import '../typedefs.dart';
import '../n_day_view/n_day_view.dart';

/// A day view widget that displays a single day.
/// This is a wrapper around NDayView with numberOfDays=1.
class DayViewWrapper<T extends Object?> extends StatelessWidget {
  /// A function that returns a [Widget] that determines appearance of each
  /// cell in day calendar.
  final EventTileBuilder<T>? eventTileBuilder;

  /// A function to generate the DateString in the calendar title.
  /// Useful for I18n
  final StringProvider? dateStringBuilder;

  /// A function to generate the TimeString in the timeline.
  /// Useful for I18n
  final StringProvider? timeStringBuilder;

  /// A function that returns a [Widget] that will be displayed left side of
  /// day view.
  ///
  /// If null is provided then no time line will be visible.
  ///
  final DateWidgetBuilder? timeLineBuilder;

  /// Builds day title bar.
  final DateWidgetBuilder? dayTitleBuilder;

  /// Builds custom PressDetector widget
  ///
  /// If null, internal PressDetector will be used to handle onDateLongPress()
  ///
  final DetectorBuilder? dayDetectorBuilder;

  /// Defines how events are arranged in day view.
  /// User can define custom event arranger by implementing [EventArranger]
  /// class and pass object of that class as argument.
  final EventArranger<T>? eventArranger;

  /// This callback will run whenever page will change.
  final CalendarPageChangeCallBack? onPageChange;

  /// Determines the lower boundary user can scroll.
  ///
  /// If not provided [CalendarConstants.epochDate] is default.
  final DateTime? minDay;

  /// Determines upper boundary user can scroll.
  ///
  /// If not provided [CalendarConstants.maxDate] is default.
  final DateTime? maxDay;

  /// Defines initial display day.
  ///
  /// If not provided [DateTime.now] is default date.
  final DateTime? initialDay;

  /// Defines settings for hour indication lines.
  ///
  /// Pass [HourIndicatorSettings.none] to remove Hour lines.
  final HourIndicatorSettings? hourIndicatorSettings;

  /// A funtion that returns a [CustomPainter].
  ///
  /// Use this if you want to paint custom hour lines.
  final CustomHourLinePainter? hourLinePainter;

  /// Defines settings for live time indicator.
  ///
  /// Pass [LiveTimeIndicatorSettings.none] to remove live time indicator.
  final LiveTimeIndicatorSettings? liveTimeIndicatorSettings;

  /// Defines settings for half hour indication lines.
  ///
  /// Pass [HourIndicatorSettings.none] to remove half hour lines.
  final HourIndicatorSettings? halfHourIndicatorSettings;

  /// Defines settings for quarter hour indication lines.
  ///
  /// Pass [HourIndicatorSettings.none] to remove quarter hour lines.
  final HourIndicatorSettings? quarterHourIndicatorSettings;

  /// Defines width of day view.
  final double? width;

  /// Page transition duration used when user try to change page using
  /// [DayView.nextPage] or [DayView.previousPage]
  final Duration pageTransitionDuration;

  /// Page transition curve used when user try to change page using
  /// [DayView.nextPage] or [DayView.previousPage]
  final Curve pageTransitionCurve;

  /// A calendar controller that controls all the events and rebuilds widget
  /// if event(s) are added or removed.
  final EventController<T>? controller;

  /// Display flag for vertical line.
  final bool showVerticalLine;

  /// Defines height occupied by one minute of time span.
  ///
  /// If time span is 60 minutes then area covered by this time span is
  /// 60 * [heightPerMinute].
  ///
  /// If null is provided then 0.7 is default.
  final double heightPerMinute;

  /// This field will be used to set width of timeline.
  final double? timeLineWidth;

  /// This field will be used to set the offset of timeline.
  final double timeLineOffset;

  /// Flag to display live time indicator.
  final bool showLiveTimeLineInAllDays;

  /// Settings for live time indicator.
  final LiveTimeIndicatorSettings? liveTimeIndicatorSettings;

  /// Background color of day view.
  final Color backgroundColor;

  /// Scroll offset of day view page.
  final double? scrollOffset;

  /// This method will be called when user taps on event tile.
  final CellTapCallback<T>? onEventTap;

  /// This method will be called when user long press on event tile.
  final CellTapCallback<T>? onEventLongTap;

  /// This method will be called when user double taps on event tile.
  final CellTapCallback<T>? onEventDoubleTap;

  /// This method will be called when user long press on calendar.
  final DatePressCallback? onDateLongPress;

  /// Called when user taps on day view page.
  ///
  /// This callback will have a date parameter which
  /// will provide the time span on which user has tapped.
  ///
  /// Ex, User Taps on Date page with date 11/01/2022 and time span is 1PM to 2PM.
  /// then DateTime object will be  DateTime(2022,01,11,1,0)
  final DateTapCallback? onDateTap;

  /// Defines size of the slots that provides long press callback on area
  /// where events are not there.
  final MinuteSlotSize minuteSlotSize;

  /// Use this field to disable the calendar scrolling
  final ScrollPhysics? scrollPhysics;

  /// Use this field to disable the page view scrolling behavior
  final ScrollPhysics? pageViewPhysics;

  /// Style for DayView header.
  final HeaderStyle headerStyle;

  /// Option for SafeArea.
  final SafeAreaOption safeAreaOption;

  /// Display full day event builder.
  final FullDayEventBuilder<T>? fullDayEventBuilder;

  /// First hour displayed in the layout, goes from 0 to 24
  final int startHour;

  /// Show half hour indicator
  final bool showHalfHours;

  /// Show quarter hour indicator(15min & 45min).
  final bool showQuarterHours;

  /// It define the starting duration from where day view page will be visible
  /// By default it will be Duration(hours:0)
  final Duration startDuration;

  /// Callback for the Header title
  final HeaderTitleCallback? onHeaderTitleTap;

  /// Emulate vertical line offset from hour line starts.
  final double emulateVerticalOffsetBy;

  /// This field will be used to set end hour for day view
  final int endHour;

  /// Flag to keep scrollOffset of pages on page change
  final bool keepScrollOffset;

  /// Date events builder - builds the actual event widgets for each day
  final DateEventsBuilder<T> dateEventsBuilder;

  /// Scroll view builder - custom scroll view wrapper
  final ScrollViewBuilder scrollViewBuilder;

  /// Day decoration builder - builds decorations for the day view
  final WeekDecorationBuilder dayDecorationBuilder;

  /// Main widget for day view.
  const DayViewWrapper({
    Key? key,
    required this.dateEventsBuilder,
    required this.scrollViewBuilder,
    required this.dayDecorationBuilder,
    this.eventTileBuilder,
    this.dateStringBuilder,
    this.timeStringBuilder,
    this.controller,
    this.showVerticalLine = true,
    this.pageTransitionDuration = const Duration(milliseconds: 300),
    this.pageTransitionCurve = Curves.ease,
    this.width,
    this.minDay,
    this.maxDay,
    this.initialDay,
    this.hourIndicatorSettings,
    this.hourLinePainter,
    this.heightPerMinute = 0.7,
    this.timeLineBuilder,
    this.timeLineWidth,
    this.timeLineOffset = 0,
    this.showLiveTimeLineInAllDays = false,
    this.liveTimeIndicatorSettings,
    this.onPageChange,
    this.dayTitleBuilder,
    this.eventArranger,
    this.backgroundColor = Colors.white,
    this.scrollOffset,
    this.onEventTap,
    this.onEventLongTap,
    this.onDateLongPress,
    this.onDateTap,
    this.minuteSlotSize = MinuteSlotSize.minutes60,
    this.headerStyle = const HeaderStyle(),
    this.fullDayEventBuilder,
    this.safeAreaOption = const SafeAreaOption(),
    this.scrollPhysics,
    this.pageViewPhysics,
    this.dayDetectorBuilder,
    this.showHalfHours = false,
    this.showQuarterHours = false,
    this.halfHourIndicatorSettings,
    this.startHour = 0,
    this.quarterHourIndicatorSettings,
    this.startDuration = const Duration(hours: 0),
    this.onHeaderTitleTap,
    this.emulateVerticalOffsetBy = 0,
    this.onEventDoubleTap,
    this.endHour = Constants.hoursADay,
    this.keepScrollOffset = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NDayView<T>(
      numberOfDays: 1,
      dateEventsBuilder: dateEventsBuilder,
      scrollViewBuilder: scrollViewBuilder,
      nDayDecorationBuilder: dayDecorationBuilder,
      controller: controller,
      eventTileBuilder: eventTileBuilder,
      pageTransitionDuration: pageTransitionDuration,
      pageTransitionCurve: pageTransitionCurve,
      heightPerMinute: heightPerMinute,
      timeLineOffset: timeLineOffset,
      showLiveTimeLineInAllDays: showLiveTimeLineInAllDays,
      showVerticalLines: showVerticalLine,
      width: width,
      minDay: minDay,
      maxDay: maxDay,
      initialDay: initialDay,
      hourIndicatorSettings: hourIndicatorSettings,
      hourLinePainter: hourLinePainter,
      halfHourIndicatorSettings: halfHourIndicatorSettings,
      quarterHourIndicatorSettings: quarterHourIndicatorSettings,
      timeLineBuilder: timeLineBuilder,
      timeLineWidth: timeLineWidth,
      liveTimeIndicatorSettings: liveTimeIndicatorSettings,
      onPageChange: onPageChange,
      pageHeaderBuilder: null, // Will use default
      eventArranger: eventArranger,
      dayTitleHeight: 50,
      dayTitleBuilder: dayTitleBuilder,
      weekNumberBuilder: null, // Will use default
      backgroundColor: backgroundColor,
      scrollOffset: scrollOffset ?? 0.0,
      onEventTap: onEventTap,
      onEventLongTap: onEventLongTap,
      onDateLongPress: onDateLongPress,
      onDateTap: onDateTap,
      minuteSlotSize: minuteSlotSize,
      dayDetectorBuilder: dayDetectorBuilder,
      headerStringBuilder: dateStringBuilder,
      timeLineStringBuilder: timeStringBuilder,
      dayStringBuilder: null, // Will use default
      dayDateStringBuilder: null, // Will use default
      headerStyle: headerStyle,
      safeAreaOption: safeAreaOption,
      fullDayEventBuilder: fullDayEventBuilder,
      startHour: startHour,
      onHeaderTitleTap: onHeaderTitleTap,
      showHalfHours: showHalfHours,
      showQuarterHours: showQuarterHours,
      emulateVerticalOffsetBy: emulateVerticalOffsetBy,
      showDayTitleAtBottom: false,
      pageViewPhysics: pageViewPhysics,
      onEventDoubleTap: onEventDoubleTap,
      endHour: endHour,
      fullDayHeaderTitle: '',
      fullDayHeaderTextConfig: null,
      keepScrollOffset: keepScrollOffset,
    );
  }
}