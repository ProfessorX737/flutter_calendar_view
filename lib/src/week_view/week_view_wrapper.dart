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

/// [Widget] to display week view.
/// This is a wrapper around NDayView with numberOfDays=7.
class WeekViewWrapper<T extends Object?> extends StatelessWidget {
  /// Builder to build tile for events.
  final EventTileBuilder<T>? eventTileBuilder;

  /// Builder for timeline.
  final DateWidgetBuilder? timeLineBuilder;

  /// Header builder for week page header.
  final WeekPageHeaderBuilder? weekPageHeaderBuilder;

  /// Builds custom PressDetector widget
  ///
  /// If null, internal PressDetector will be used to handle onDateLongPress()
  ///
  final DetectorBuilder? weekDetectorBuilder;

  /// This function will generate dateString int the calendar header.
  /// Useful for I18n
  final StringProvider? headerStringBuilder;

  /// This function will generate the TimeString in the timeline.
  /// Useful for I18n
  final StringProvider? timeLineStringBuilder;

  /// This function will generate WeekDayString in the weekday.
  /// Useful for I18n
  final String Function(int)? weekDayStringBuilder;

  /// This function will generate WeekDayDateString in the weekday.
  /// Useful for I18n
  final String Function(int)? weekDayDateStringBuilder;

  /// Arrange events.
  final EventArranger<T>? eventArranger;

  /// Called whenever user changes week.
  final CalendarPageChangeCallBack? onPageChange;

  /// Minimum day to display in week view.
  ///
  /// In calendar first date of the week that contains this data will be
  /// minimum date.
  ///
  /// ex, If minDay is 16th March, 2022 then week containing this date will have
  /// dates from 14th to 20th (Monday to Sunday). adn 14th date will
  /// be the actual minimum date.
  final DateTime? minDay;

  /// Maximum day to display in week view.
  ///
  /// In calendar last date of the week that contains this data will be
  /// maximum date.
  ///
  /// ex, If maxDay is 16th March, 2022 then week containing this date will have
  /// dates from 14th to 20th (Monday to Sunday). adn 20th date will
  /// be the actual maximum date.
  final DateTime? maxDay;

  /// Initial week to display in week view.
  final DateTime? initialDay;

  /// Settings for hour indicator settings.
  final HourIndicatorSettings? hourIndicatorSettings;

  /// A funtion that returns a [CustomPainter].
  ///
  /// Use this if you want to paint custom hour lines.
  final CustomHourLinePainter? hourLinePainter;

  /// Settings for half hour indicator settings.
  final HourIndicatorSettings? halfHourIndicatorSettings;

  /// Settings for quarter hour indicator settings.
  final HourIndicatorSettings? quarterHourIndicatorSettings;

  /// Settings for live time indicator.
  final LiveTimeIndicatorSettings? liveTimeIndicatorSettings;

  /// Flag to display live time indicator in all visible days.
  final bool showLiveTimeLineInAllDays;

  /// Display vertical lines to separate days.
  final bool showVerticalLines;

  /// Page transition duration used when user try to change page using
  /// [WeekView.nextPage] or [WeekView.previousPage]
  final Duration pageTransitionDuration;

  /// Page transition curve used when user try to change page using
  /// [WeekView.nextPage] or [WeekView.previousPage]
  final Curve pageTransitionCurve;

  /// A calendar controller that controls all the events and rebuilds widget
  /// if event(s) are added or removed.
  final EventController<T>? controller;

  /// Defines height occupied by one minute of time span.
  ///
  /// If height per minute is 0.7 then 60 minutes will occupy 42 height.
  final double heightPerMinute;

  /// Offset for time line
  final double timeLineOffset;

  /// Width of timeline
  final double? timeLineWidth;

  /// Flag to display live time indicator.
  /// If true then indicator will be displayed else not.
  final bool showLiveLine;

  /// Settings for live time indicator.
  final LiveTimeIndicatorSettings? liveTimeIndicatorSettings;

  /// Width of week view.
  final double? width;

  /// Builder for week day title.
  final DateWidgetBuilder? weekDayBuilder;

  /// Builder for week number.
  final WeekNumberBuilder? weekNumberBuilder;

  /// Background color of week view
  final Color backgroundColor;

  /// Scroll offset of week view page.
  final double scrollOffset;

  /// Called when user taps on event tile.
  final CellTapCallback<T>? onEventTap;

  /// Called when user long press on event tile.
  final CellTapCallback<T>? onEventLongTap;

  /// Called when user double taps on event tile.
  final CellTapCallback<T>? onEventDoubleTap;

  /// Called when user long press on calendar.
  final DatePressCallback? onDateLongPress;

  /// Called when user taps on day view page.
  ///
  /// This callback will have a date parameter which
  /// will provide the time span on which user has tapped.
  ///
  /// Ex, User Taps on Date page with date 11/01/2022 and time span is 1PM to 2PM.
  /// then DateTime object will be  DateTime(2022,01,11,1,0)
  final DateTapCallback? onDateTap;

  /// List of weekdays to display. This will be ignored if [showWeekends] is false
  /// and [weekDays] contains [WeekDays.saturday] or [WeekDays.sunday].
  ///
  /// If not provided, [WeekDays.values] is the default value.
  ///
  /// Rearranging the list will rearrange the week view.
  /// ex, if you want to show week view from Thursday to Wednesday, you can set
  /// weekDays as [WeekDays.thursday, WeekDays.friday, WeekDays.saturday,
  /// WeekDays.sunday, WeekDays.monday, WeekDays.tuesday, WeekDays.wednesday].
  final List<WeekDays> weekDays;

  /// If false will hide the weekends from week view
  /// even if weekends are added in [weekDays].
  ///
  /// ex, if [showWeekends] is false and [weekDays] are monday, tuesday,
  /// saturday and sunday, it will display only monday and tuesday.
  final bool showWeekends;

  /// Defines the starting day of the week view.
  ///
  /// Default value is [WeekDays.monday].
  final WeekDays startDay;

  /// Defines size of the slots that provides long press callback on area
  /// where events are not there.
  final MinuteSlotSize minuteSlotSize;

  /// Style for WeekView header.
  final HeaderStyle headerStyle;

  /// Option for SafeArea.
  final SafeAreaOption safeAreaOption;

  /// Display full day event builder.
  final FullDayEventBuilder<T>? fullDayEventBuilder;

  /// First hour displayed in the layout, goes from 0 to 24
  final int startHour;

  /// This field will be used to set end hour for week view
  final int endHour;

  ///Show half hour indicator
  final bool showHalfHours;

  ///Show quarter hour indicator
  final bool showQuarterHours;

  ///Emulates offset of vertical line from hour line starts.
  final double emulateVerticalOffsetBy;

  /// Callback for the Header title
  final HeaderTitleCallback? onHeaderTitleTap;

  /// If true this will show week day at bottom position.
  final bool showWeekDayAtBottom;

  /// Defines scroll physics for a page of a week view.
  ///
  /// This can be used to disable the horizontal scroll of a page.
  final ScrollPhysics? pageViewPhysics;

  /// Title of the full day events row
  final String fullDayHeaderTitle;

  /// Defines full day events header text config
  final FullDayHeaderTextConfig? fullDayHeaderTextConfig;

  /// Flag to keep scrollOffset of pages on page change
  final bool keepScrollOffset;

  /// Date events builder - builds the actual event widgets for each day
  final DateEventsBuilder<T> dateEventsBuilder;

  /// Scroll view builder - custom scroll view wrapper
  final ScrollViewBuilder scrollViewBuilder;

  /// Week decoration builder - builds decorations for the week view
  final WeekDecorationBuilder weekDecorationBuilder;

  /// Main widget for week view.
  const WeekViewWrapper({
    Key? key,
    required this.dateEventsBuilder,
    required this.scrollViewBuilder,
    required this.weekDecorationBuilder,
    this.controller,
    this.eventTileBuilder,
    this.pageTransitionDuration = const Duration(milliseconds: 300),
    this.pageTransitionCurve = Curves.ease,
    this.heightPerMinute = 1,
    this.timeLineOffset = 0,
    this.showLiveTimeLineInAllDays = false,
    this.showVerticalLines = true,
    this.width,
    this.minDay,
    this.maxDay,
    this.initialDay,
    this.hourIndicatorSettings,
    this.hourLinePainter,
    this.halfHourIndicatorSettings,
    this.quarterHourIndicatorSettings,
    this.timeLineBuilder,
    this.timeLineWidth,
    this.liveTimeIndicatorSettings,
    this.onPageChange,
    this.weekPageHeaderBuilder,
    this.eventArranger,
    this.weekTitleHeight = 50,
    this.weekDayBuilder,
    this.weekNumberBuilder,
    this.backgroundColor = Colors.white,
    this.scrollOffset = 0.0,
    this.onEventTap,
    this.onEventLongTap,
    this.onDateLongPress,
    this.onDateTap,
    this.weekDays = WeekDays.values,
    this.showWeekends = true,
    this.startDay = WeekDays.monday,
    this.minuteSlotSize = MinuteSlotSize.minutes60,
    this.weekDetectorBuilder,
    this.headerStringBuilder,
    this.timeLineStringBuilder,
    this.weekDayStringBuilder,
    this.weekDayDateStringBuilder,
    this.headerStyle = const HeaderStyle(),
    this.safeAreaOption = const SafeAreaOption(),
    this.fullDayEventBuilder,
    this.startHour = 0,
    this.onHeaderTitleTap,
    this.showHalfHours = false,
    this.showQuarterHours = false,
    this.emulateVerticalOffsetBy = 0,
    this.showWeekDayAtBottom = false,
    this.pageViewPhysics,
    this.onEventDoubleTap,
    this.endHour = Constants.hoursADay,
    this.fullDayHeaderTitle = '',
    this.fullDayHeaderTextConfig,
    this.keepScrollOffset = false,
  }) : super(key: key);

  /// Height of week title.
  final double weekTitleHeight;

  /// Calculate actual number of days based on weekDays and showWeekends
  int get _actualNumberOfDays {
    if (!showWeekends) {
      final filteredDays = weekDays.where((day) => 
          day != WeekDays.saturday && day != WeekDays.sunday).toList();
      return filteredDays.isEmpty ? 7 : filteredDays.length;
    }
    return weekDays.length;
  }

  @override
  Widget build(BuildContext context) {
    return NDayView<T>(
      numberOfDays: _actualNumberOfDays,
      dateEventsBuilder: dateEventsBuilder,
      scrollViewBuilder: scrollViewBuilder,
      nDayDecorationBuilder: weekDecorationBuilder,
      controller: controller,
      eventTileBuilder: eventTileBuilder,
      pageTransitionDuration: pageTransitionDuration,
      pageTransitionCurve: pageTransitionCurve,
      heightPerMinute: heightPerMinute,
      timeLineOffset: timeLineOffset,
      showLiveTimeLineInAllDays: showLiveTimeLineInAllDays,
      showVerticalLines: showVerticalLines,
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
      pageHeaderBuilder: weekPageHeaderBuilder,
      eventArranger: eventArranger,
      dayTitleHeight: weekTitleHeight,
      dayTitleBuilder: weekDayBuilder,
      weekNumberBuilder: weekNumberBuilder,
      backgroundColor: backgroundColor,
      scrollOffset: scrollOffset,
      onEventTap: onEventTap,
      onEventLongTap: onEventLongTap,
      onDateLongPress: onDateLongPress,
      onDateTap: onDateTap,
      minuteSlotSize: minuteSlotSize,
      dayDetectorBuilder: weekDetectorBuilder,
      headerStringBuilder: headerStringBuilder,
      timeLineStringBuilder: timeLineStringBuilder,
      dayStringBuilder: weekDayStringBuilder,
      dayDateStringBuilder: weekDayDateStringBuilder,
      headerStyle: headerStyle,
      safeAreaOption: safeAreaOption,
      fullDayEventBuilder: fullDayEventBuilder,
      startHour: startHour,
      onHeaderTitleTap: onHeaderTitleTap,
      showHalfHours: showHalfHours,
      showQuarterHours: showQuarterHours,
      emulateVerticalOffsetBy: emulateVerticalOffsetBy,
      showDayTitleAtBottom: showWeekDayAtBottom,
      pageViewPhysics: pageViewPhysics,
      onEventDoubleTap: onEventDoubleTap,
      endHour: endHour,
      fullDayHeaderTitle: fullDayHeaderTitle,
      fullDayHeaderTextConfig: fullDayHeaderTextConfig,
      keepScrollOffset: keepScrollOffset,
    );
  }
}