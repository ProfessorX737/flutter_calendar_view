import 'package:flutter/widgets.dart';

/// InheritedWidget that provides the current week view layout dimensions.
///
/// This allows the [InternalWeekViewPage] to read width-related values
/// without them being part of the page's widget constructor or cache key.
/// When the parent width changes (e.g. during side panel resize), only the
/// InheritedWidget updates — the cached page widgets stay in the cache and
/// their subtree rebuilds via the inherited dependency, not via cache miss.
class WeekViewDimensions extends InheritedWidget {
  /// Total width of the week view.
  final double width;

  /// Width of each day column.
  final double weekTitleWidth;

  /// Width of the time line on the left.
  final double timeLineWidth;

  /// Offset from the hour indicator settings.
  final double hourIndicatorOffset;

  const WeekViewDimensions({
    Key? key,
    required this.width,
    required this.weekTitleWidth,
    required this.timeLineWidth,
    required this.hourIndicatorOffset,
    required Widget child,
  }) : super(key: key, child: child);

  static WeekViewDimensions of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<WeekViewDimensions>();
    assert(result != null, 'No WeekViewDimensions found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(WeekViewDimensions oldWidget) {
    return width != oldWidget.width ||
        weekTitleWidth != oldWidget.weekTitleWidth ||
        timeLineWidth != oldWidget.timeLineWidth ||
        hourIndicatorOffset != oldWidget.hourIndicatorOffset;
  }
}
