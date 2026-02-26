// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import '../calendar_constants.dart';
import '../calendar_controller_provider.dart';
import '../calendar_event_data.dart';
import '../components/common_components.dart';
import '../components/week_view_components.dart';
import '../components/day_view_components.dart';
import '../components/event_scroll_notifier.dart';
import '../components/safe_area_wrapper.dart';
import '../constants.dart';
import '../enumerations.dart';
import '../event_arrangers/event_arrangers.dart';
import '../event_controller.dart';
import '../extensions.dart';
import '../modals.dart';
import '../painters.dart';
import '../style/header_style.dart';
import '../typedefs.dart';
import '_internal_n_day_view_page.dart';

/// [Widget] to display N consecutive days view (1 to N days).
class NDayView<T extends Object?> extends StatefulWidget {
  /// Number of consecutive days to display.
  final int numberOfDays;

  /// Builder to build tile for events.
  final EventTileBuilder<T>? eventTileBuilder;

  /// Builder for timeline.
  final DateWidgetBuilder? timeLineBuilder;

  /// Header builder for page header.
  final WeekPageHeaderBuilder? pageHeaderBuilder;

  /// Builds custom PressDetector widget
  ///
  /// If null, internal PressDetector will be used to handle onDateLongPress()
  ///
  final DetectorBuilder? dayDetectorBuilder;

  /// This function will generate dateString in the calendar header.
  /// Useful for I18n
  final StringProvider? headerStringBuilder;

  /// This function will generate the TimeString in the timeline.
  /// Useful for I18n
  final StringProvider? timeLineStringBuilder;

  /// This function will generate DayString in the day title.
  /// Useful for I18n
  final String Function(int)? dayStringBuilder;

  /// This function will generate DayDateString in the day title.
  /// Useful for I18n
  final String Function(int)? dayDateStringBuilder;

  /// Arrange events.
  final EventArranger<T>? eventArranger;

  /// Called whenever user changes page (swipes left or right).
  final CalendarPageChangeCallBack? onPageChange;

  /// Minimum day to display in n-day view.
  final DateTime? minDay;

  /// Maximum day to display in n-day view.
  final DateTime? maxDay;

  /// Initial day to display in n-day view.
  final DateTime? initialDay;

  /// Settings for hour indicator settings.
  final HourIndicatorSettings? hourIndicatorSettings;

  /// A function that returns a [CustomPainter].
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
  /// [NDayViewState.nextPage] or [NDayViewState.previousPage]
  final Duration pageTransitionDuration;

  /// Page transition curve used when user try to change page using
  /// [NDayViewState.nextPage] or [NDayViewState.previousPage]
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

  /// Width of n-day view.
  final double? width;

  /// Builder for day title.
  final DateWidgetBuilder? dayTitleBuilder;

  /// Builder for week number.
  final WeekNumberBuilder? weekNumberBuilder;

  /// Background color of n-day view
  final Color backgroundColor;

  /// Scroll offset of n-day view page.
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

  /// Defines size of the slots that provides long press callback on area
  /// where events are not there.
  final MinuteSlotSize minuteSlotSize;

  /// Style for NDayView header.
  final HeaderStyle headerStyle;

  /// Option for SafeArea.
  final SafeAreaOption safeAreaOption;

  /// Display full day event builder.
  final FullDayEventBuilder<T>? fullDayEventBuilder;

  /// First hour displayed in the layout, goes from 0 to 24
  final int startHour;

  /// This field will be used to set end hour for n-day view
  final int endHour;

  ///Show half hour indicator
  final bool showHalfHours;

  ///Show quarter hour indicator
  final bool showQuarterHours;

  ///Emulates offset of vertical line from hour line starts.
  final double emulateVerticalOffsetBy;

  /// Callback for the Header title
  final HeaderTitleCallback? onHeaderTitleTap;

  /// If true this will show day title at bottom position.
  final bool showDayTitleAtBottom;

  /// Defines scroll physics for a page of a n-day view.
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

  /// N-day decoration builder - builds decorations for the n-day view
  final WeekDecorationBuilder nDayDecorationBuilder;

  /// Main widget for n-day view.
  const NDayView({
    Key? key,
    required this.numberOfDays,
    required this.dateEventsBuilder,
    required this.scrollViewBuilder,
    required this.nDayDecorationBuilder,
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
    this.pageHeaderBuilder,
    this.eventArranger,
    this.dayTitleHeight = 50,
    this.dayTitleBuilder,
    this.weekNumberBuilder,
    this.backgroundColor = Colors.white,
    this.scrollOffset = 0.0,
    this.onEventTap,
    this.onEventLongTap,
    this.onDateLongPress,
    this.onDateTap,
    this.minuteSlotSize = MinuteSlotSize.minutes60,
    this.dayDetectorBuilder,
    this.headerStringBuilder,
    this.timeLineStringBuilder,
    this.dayStringBuilder,
    this.dayDateStringBuilder,
    this.headerStyle = const HeaderStyle(),
    this.safeAreaOption = const SafeAreaOption(),
    this.fullDayEventBuilder,
    this.startHour = 0,
    this.onHeaderTitleTap,
    this.showHalfHours = false,
    this.showQuarterHours = false,
    this.emulateVerticalOffsetBy = 0,
    this.showDayTitleAtBottom = false,
    this.pageViewPhysics,
    this.onEventDoubleTap,
    this.endHour = Constants.hoursADay,
    this.fullDayHeaderTitle = '',
    this.fullDayHeaderTextConfig,
    this.keepScrollOffset = false,
  })  : assert(numberOfDays > 0, "numberOfDays must be greater than 0"),
        assert(numberOfDays <= 30, "numberOfDays must be 30 or less for performance"),
        assert(!(onHeaderTitleTap != null && pageHeaderBuilder != null),
            "can't use [onHeaderTitleTap] & [pageHeaderBuilder] simultaneously"),
        assert((timeLineOffset) >= 0,
            "timeLineOffset must be greater than or equal to 0"),
        assert(width == null || width > 0,
            "Calendar width must be greater than 0."),
        assert(timeLineWidth == null || timeLineWidth > 0,
            "Time line width must be greater than 0."),
        assert(
            heightPerMinute > 0, "Height per minute must be greater than 0."),
        assert(
          dayDetectorBuilder == null || onDateLongPress == null,
          """If you use [dayDetectorBuilder] 
          do not provide [onDateLongPress]""",
        ),
        assert(
          startHour <= 0 || startHour != endHour,
          "startHour must be greater than 0 or startHour should not equal to endHour",
        ),
        assert(
          endHour <= Constants.hoursADay || endHour < startHour,
          "End hour must be less than 24 or startHour must be less than endHour",
        ),
        super(key: key);

  /// Height of day title.
  final double dayTitleHeight;

  @override
  NDayViewState<T> createState() => NDayViewState<T>();
}

class NDayViewState<T extends Object?> extends State<NDayView<T>> {
  late double _width;
  late double _height;
  late double _timeLineWidth;
  late double _hourHeight;
  late double _lastScrollOffset;
  late DateTime _currentStartDate;
  late DateTime _currentEndDate;
  late DateTime _maxDate;
  late DateTime _minDate;
  late DateTime _currentPage;
  late int _totalPages;
  late int _currentIndex;

  late PageController _pageController;
  late ScrollController _scrollController;
  late EventController<T>? _controller;
  late VoidCallback _reloadCallback;

  late EventArranger<T> _eventArranger;

  late HourIndicatorSettings _hourIndicatorSettings;
  late HourIndicatorSettings _halfHourIndicatorSettings;
  late HourIndicatorSettings _quarterHourIndicatorSettings;
  late LiveTimeIndicatorSettings _liveTimeIndicatorSettings;

  late DateWidgetBuilder _timeLineBuilder;
  late EventTileBuilder<T> _eventTileBuilder;
  late WeekPageHeaderBuilder _pageHeaderBuilder;
  late DateWidgetBuilder _dayTitleBuilder;
  late WeekNumberBuilder _weekNumberBuilder;
  late DetectorBuilder _dayDetectorBuilder;
  late FullDayEventBuilder<T> _fullDayEventBuilder;
  late CustomHourLinePainter _hourLinePainter;

  late String _fullDayHeaderTitle;
  late FullDayHeaderTextConfig _fullDayHeaderTextConfig;

  late int _startHour;
  late int _endHour;

  Timer? _timer;
  late EventScrollNotifier _scrollConfiguration;

  final Map<ValueKey, Widget> _pageCache = {};

  @override
  void initState() {
    super.initState();
    _lastScrollOffset = widget.scrollOffset;

    _scrollController =
        ScrollController(initialScrollOffset: widget.scrollOffset);

    _startHour = widget.startHour;
    _endHour = widget.endHour;

    _reloadCallback = _reload;

    _setDateRange();

    _currentPage = (widget.initialDay ?? DateTime.now()).withoutTime;

    _regulateCurrentDate();

    _calculateHeights();

    _pageController = PageController(initialPage: _currentIndex);
    _eventArranger = widget.eventArranger ?? SideEventArranger<T>();

    _assignBuilders();
    _fullDayHeaderTitle = widget.fullDayHeaderTitle;
    _fullDayHeaderTextConfig =
        widget.fullDayHeaderTextConfig ?? FullDayHeaderTextConfig();

    _scrollConfiguration = EventScrollNotifier();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newController = widget.controller ??
        CalendarControllerProvider.of<T>(context).controller;

    if (_controller != newController) {
      _controller = newController;

      _controller!
        // Removes existing callback.
        ..removeListener(_reloadCallback)

        // Reloads the view if there is any change in controller or
        // user adds new events.
        ..addListener(_reloadCallback);
    }
  }

  @override
  void didUpdateWidget(NDayView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller.
    final newController = widget.controller ??
        CalendarControllerProvider.of<T>(context).controller;

    if (newController != _controller) {
      _controller?.removeListener(_reloadCallback);
      _controller = newController;
      _controller?.addListener(_reloadCallback);
    }

    // Update date range.
    if (widget.minDay != oldWidget.minDay ||
        widget.maxDay != oldWidget.maxDay ||
        widget.numberOfDays != oldWidget.numberOfDays) {
      _setDateRange();
      _regulateCurrentDate();

      _pageController.jumpToPage(_currentIndex);
    }

    _eventArranger = widget.eventArranger ?? SideEventArranger<T>();

    // Update heights.
    _calculateHeights();

    // Update builders and callbacks
    _assignBuilders();
  }

  @override
  void dispose() {
    _controller?.removeListener(_reloadCallback);
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeAreaWrapper(
      option: widget.safeAreaOption,
      child: LayoutBuilder(builder: (context, constraint) {
        _width = widget.width ?? constraint.maxWidth;
        _updateViewDimensions();
        return SizedBox(
          width: _width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _pageHeaderBuilder(_currentStartDate, _currentEndDate),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChange,
                  physics: widget.pageViewPhysics,
                  itemBuilder: (_, index) {
                    final dates = _getDateRangeForPage(index);
                    final isCurrentPage = index == _currentIndex;
                    final key = ValueKey(
                        '${_width}_${_hourHeight.toString()}_${dates[0].toString()}');
                    
                    if (!_pageCache.containsKey(key)) {
                      _pageCache.remove(key);
                      _pageCache[key] = ValueListenableBuilder(
                          valueListenable: _scrollConfiguration,
                          builder: (_, __, ___) {
                            final pageScrollController = ScrollController(
                                initialScrollOffset: _lastScrollOffset);
                            if (isCurrentPage) {
                              _currentPageScrollController = pageScrollController;
                            }

                            return InternalNDayViewPage<T>(
                              key: ValueKey(_hourHeight.toString() +
                                  dates[0].toString()),
                              height: _height,
                              width: _width,
                              dateEventsBuilder: widget.dateEventsBuilder,
                              scrollViewBuilder: widget.scrollViewBuilder,
                              nDayDecorationBuilder: widget.nDayDecorationBuilder,
                              dayTitleWidth: _dayTitleWidth,
                              dayTitleHeight: widget.dayTitleHeight,
                              dayBuilder: _dayTitleBuilder,
                              weekNumberBuilder: _weekNumberBuilder,
                              dayDetectorBuilder: _dayDetectorBuilder,
                              liveTimeIndicatorSettings: _liveTimeIndicatorSettings,
                              timeLineBuilder: _timeLineBuilder,
                              onTileTap: widget.onEventTap,
                              onTileLongTap: widget.onEventLongTap,
                              onDateLongPress: widget.onDateLongPress,
                              onDateTap: widget.onDateTap,
                              onTileDoubleTap: widget.onEventDoubleTap,
                              eventTileBuilder: _eventTileBuilder,
                              heightPerMinute: widget.heightPerMinute,
                              hourIndicatorSettings: _hourIndicatorSettings,
                              hourLinePainter: _hourLinePainter,
                              halfHourIndicatorSettings: _halfHourIndicatorSettings,
                              quarterHourIndicatorSettings: _quarterHourIndicatorSettings,
                              dates: dates,
                              showLiveLine: widget.showLiveTimeLineInAllDays ||
                                  _showLiveTimeIndicator(dates),
                              timeLineOffset: widget.timeLineOffset,
                              timeLineWidth: _timeLineWidth,
                              verticalLineOffset: 0,
                              showVerticalLine: widget.showVerticalLines,
                              controller: _controller!,
                              hourHeight: _hourHeight,
                              nDayViewScrollController: _scrollController,
                              pageScrollController: pageScrollController,
                              eventArranger: _eventArranger,
                              minuteSlotSize: widget.minuteSlotSize,
                              scrollConfiguration: _scrollConfiguration,
                              fullDayEventBuilder: _fullDayEventBuilder,
                              startHour: _startHour,
                              showHalfHours: widget.showHalfHours,
                              showQuarterHours: widget.showQuarterHours,
                              emulateVerticalOffsetBy: widget.emulateVerticalOffsetBy,
                              showWeekDayAtBottom: widget.showDayTitleAtBottom,
                              endHour: _endHour,
                              fullDayHeaderTitle: _fullDayHeaderTitle,
                              fullDayHeaderTextConfig: _fullDayHeaderTextConfig,
                              lastScrollOffset: _lastScrollOffset,
                              scrollListener: _scrollPageListener,
                              keepScrollOffset: widget.keepScrollOffset,
                            );
                          });
                    }
                    
                    // trim entries in cache to 5 max
                    if (_pageCache.length > 5) {
                      _pageCache.remove(_pageCache.keys.first);
                    }

                    return _pageCache[key]!;
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  late double _dayTitleWidth;
  late ScrollController? _currentPageScrollController;

  /// Generates list of dates for given page [index].
  List<DateTime> _getDateRangeForPage(int index) {
    final startDate = _minDate.add(Duration(days: index * widget.numberOfDays));
    return List.generate(widget.numberOfDays, (i) => 
        startDate.add(Duration(days: i)));
  }

  /// Returns true if live time indicator should be displayed.
  bool _showLiveTimeIndicator(List<DateTime> dates) {
    final now = DateTime.now();
    return dates.any((date) => 
        date.year == now.year && 
        date.month == now.month && 
        date.day == now.day);
  }

  /// Reloads page.
  void _reload() {
    if (mounted) {
      setState(() {});
    }
  }

  void _updateViewDimensions() {
    _timeLineWidth = widget.timeLineWidth ?? _width * 0.13;

    _liveTimeIndicatorSettings = widget.liveTimeIndicatorSettings ??
        LiveTimeIndicatorSettings(
          color: Constants.defaultLiveTimeIndicatorColor,
          height: widget.heightPerMinute,
        );

    assert(_liveTimeIndicatorSettings.height < _hourHeight,
        "liveTimeIndicator height must be less than minuteHeight * 60");

    _hourIndicatorSettings = widget.hourIndicatorSettings ??
        HourIndicatorSettings(
          height: widget.heightPerMinute,
          color: Constants.defaultBorderColor,
          offset: 5,
        );

    assert(_hourIndicatorSettings.height < _hourHeight,
        "hourIndicator height must be less than minuteHeight * 60");

    _dayTitleWidth =
        (_width - _timeLineWidth - _hourIndicatorSettings.offset) /
            widget.numberOfDays;
  }

  void _calculateHeights() {
    _hourHeight = widget.heightPerMinute * 60;
    _height = _hourHeight * (_endHour - _startHour);
  }

  void _assignBuilders() {
    _timeLineBuilder = widget.timeLineBuilder ?? _defaultTimeLineBuilder;
    _eventTileBuilder = widget.eventTileBuilder ?? _defaultEventTileBuilder;
    _pageHeaderBuilder = widget.pageHeaderBuilder ?? _defaultPageHeaderBuilder;
    _dayTitleBuilder = widget.dayTitleBuilder ?? _defaultDayTitleBuilder;
    _weekNumberBuilder = widget.weekNumberBuilder ?? _defaultWeekNumberBuilder;
    _dayDetectorBuilder = widget.dayDetectorBuilder ?? _defaultPressDetectorBuilder;
    _fullDayEventBuilder = widget.fullDayEventBuilder ?? _defaultFullDayEventBuilder;
    _hourLinePainter = widget.hourLinePainter ?? _defaultHourLinePainter;

    _halfHourIndicatorSettings = widget.halfHourIndicatorSettings ??
        HourIndicatorSettings(
          color: Constants.defaultBorderColor,
          height: widget.heightPerMinute,
          offset: 5,
          dashWidth: 4,
          dashSpaceWidth: 4,
          lineStyle: LineStyle.dashed,
        );

    _quarterHourIndicatorSettings = widget.quarterHourIndicatorSettings ??
        HourIndicatorSettings(
          color: Constants.defaultBorderColor,
          height: widget.heightPerMinute,
          offset: 5,
          dashWidth: 4,
          dashSpaceWidth: 4,
          lineStyle: LineStyle.dashed,
        );
  }

  void _setDateRange() {
    _minDate = (widget.minDay ?? CalendarConstants.epochDate).withoutTime;
    _maxDate = (widget.maxDay ?? CalendarConstants.maxDate).withoutTime;

    assert(
      _minDate.isBefore(_maxDate),
      "Minimum date must be less than maximum date.\n"
      "Provided minimum date: $_minDate, maximum date: $_maxDate",
    );

    _totalPages = ((_maxDate.difference(_minDate).inDays + 1) / widget.numberOfDays).ceil();
  }

  void _regulateCurrentDate() {
    if (_currentPage.isBefore(_minDate)) {
      _currentPage = _minDate;
    } else if (_currentPage.isAfter(_maxDate)) {
      _currentPage = _maxDate;
    }

    _currentIndex = (_currentPage.difference(_minDate).inDays / widget.numberOfDays).floor();
    _currentStartDate = _minDate.add(Duration(days: _currentIndex * widget.numberOfDays));
    _currentEndDate = _currentStartDate.add(Duration(days: widget.numberOfDays - 1));
  }

  void _onPageChange(int index) {
    _currentIndex = index;
    _currentStartDate = _minDate.add(Duration(days: index * widget.numberOfDays));
    _currentEndDate = _currentStartDate.add(Duration(days: widget.numberOfDays - 1));
    _currentPage = _currentStartDate;

    widget.onPageChange?.call(_currentStartDate, _currentIndex);
  }

  void _scrollPageListener() {
    if (widget.keepScrollOffset) {
      _lastScrollOffset = _currentPageScrollController?.offset ?? 0.0;
    }
  }

  /// Jumps to page containing the provided [date].
  void jumpToDate(DateTime date) {
    if (date.isBefore(_minDate) || date.isAfter(_maxDate)) return;

    final index = (date.difference(_minDate).inDays / widget.numberOfDays).floor();
    _pageController.jumpToPage(index);
  }

  /// Animate to page containing the provided [date].
  void animateToDate(DateTime date) {
    if (date.isBefore(_minDate) || date.isAfter(_maxDate)) return;

    final index = (date.difference(_minDate).inDays / widget.numberOfDays).floor();
    _pageController.animateToPage(
      index,
      duration: widget.pageTransitionDuration,
      curve: widget.pageTransitionCurve,
    );
  }

  /// Jumps to next page.
  void nextPage() {
    _pageController.nextPage(
      duration: widget.pageTransitionDuration,
      curve: widget.pageTransitionCurve,
    );
  }

  /// Jumps to previous page.
  void previousPage() {
    _pageController.previousPage(
      duration: widget.pageTransitionDuration,
      curve: widget.pageTransitionCurve,
    );
  }

  /// Default builders and painters
  Widget _defaultTimeLineBuilder(DateTime date) {
    return DefaultTimeLineMark(
      date: date,
      timeStringBuilder: widget.timeLineStringBuilder,
    );
  }

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

  Widget _defaultPageHeaderBuilder(DateTime startDate, DateTime endDate) {
    return WeekPageHeader(
      startDate: startDate,
      endDate: endDate,
      onNextDay: nextPage,
      onPreviousDay: previousPage,
      onTitleTapped: () async {
        if (widget.onHeaderTitleTap != null) {
          widget.onHeaderTitleTap!(startDate);
        } else {
          final selectedDate = await showDatePicker(
            context: context,
            initialDate: startDate,
            firstDate: _minDate,
            lastDate: _maxDate,
          );

          if (selectedDate == null) return;
          jumpToDate(selectedDate);
        }
      },
      headerStringBuilder: widget.headerStringBuilder,
      headerStyle: widget.headerStyle,
    );
  }

  Widget _defaultDayTitleBuilder(DateTime date) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.dayStringBuilder?.call(date.weekday - 1) ??
              Constants.weekTitles[date.weekday - 1]),
          Text(widget.dayDateStringBuilder?.call(date.day) ??
              date.day.toString()),
        ],
      ),
    );
  }

  Widget _defaultWeekNumberBuilder(DateTime date) {
    final daysToAdd = DateTime.thursday - date.weekday;
    final thursday = daysToAdd > 0
        ? date.add(Duration(days: daysToAdd))
        : date.subtract(Duration(days: daysToAdd.abs()));
    final weekNumber =
        (date.difference(DateTime(thursday.year)).inDays / 7).floor() + 1;
    return Center(
      child: Text("$weekNumber"),
    );
  }

  Widget _defaultPressDetectorBuilder({
    required DateTime date,
    required double height,
    required double width,
    required double heightPerMinute,
    required MinuteSlotSize minuteSlotSize,
  }) {
    return DefaultPressDetector(
      date: date,
      height: height,
      width: width,
      heightPerMinute: heightPerMinute,
      minuteSlotSize: minuteSlotSize,
      onDateTap: widget.onDateTap,
      onDateLongPress: widget.onDateLongPress,
      startHour: _startHour,
    );
  }

  Widget _defaultFullDayEventBuilder(
      List<CalendarEventData<T>> events, DateTime date) {
    return FullDayEventView<T>(
      events: events,
      onEventTap: widget.onEventTap,
    );
  }

  CustomHourLinePainter get _defaultHourLinePainter {
    return (
      Color lineColor,
      double lineHeight,
      double offset,
      double minuteHeight,
      bool showVerticalLine,
      double verticalLineOffset,
      LineStyle lineStyle,
      double dashWidth,
      double dashSpaceWidth,
      double emulateVerticalOffsetBy,
      int startHour,
      int endHour,
    ) {
      return HourLinePainter(
        lineColor: lineColor,
        lineHeight: lineHeight,
        offset: offset,
        minuteHeight: minuteHeight,
        verticalLineOffset: verticalLineOffset,
        showVerticalLine: showVerticalLine,
        lineStyle: lineStyle,
        dashWidth: dashWidth,
        dashSpaceWidth: dashSpaceWidth,
        emulateVerticalOffsetBy: emulateVerticalOffsetBy,
        startHour: startHour,
        endHour: endHour,
      );
    };
  }
}