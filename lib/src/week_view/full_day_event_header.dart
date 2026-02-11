import 'package:flutter/material.dart';

import '../components/week_view_components.dart';
import '../event_controller.dart';
import '../modals.dart';
import '../typedefs.dart';

class FullDayEventHeader<T> extends StatefulWidget {
  final double width;
  final double timeLineWidth;
  final HourIndicatorSettings hourIndicatorSettings;
  final String fullDayHeaderTitle;
  final FullDayHeaderTextConfig fullDayHeaderTextConfig;
  final List<DateTime> filteredDates;
  final EventController<T> controller;
  final FullDayEventBuilder<T> fullDayEventBuilder;
  final double weekTitleWidth;
  final ScrollController pageScrollController;

  const FullDayEventHeader({
    Key? key,
    required this.width,
    required this.timeLineWidth,
    required this.hourIndicatorSettings,
    required this.fullDayHeaderTitle,
    required this.fullDayHeaderTextConfig,
    required this.filteredDates,
    required this.controller,
    required this.fullDayEventBuilder,
    required this.weekTitleWidth,
    required this.pageScrollController,
  }) : super(key: key);

  @override
  _FullDayEventHeaderState<T> createState() => _FullDayEventHeaderState<T>();
}

class _FullDayEventHeaderState<T> extends State<FullDayEventHeader<T>> {
  bool isScrolledToTop = false;

  @override
  void initState() {
    super.initState();
    widget.pageScrollController.addListener(_scrollControllerListener);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        setState(() {
          isScrolledToTop = widget.pageScrollController.position.pixels == 0;
        });
      }
    });
  }

  @override
  void dispose() {
    widget.pageScrollController.removeListener(_scrollControllerListener);
    super.dispose();
  }

  void _scrollControllerListener() {
    if (!mounted) return;
    final isPositionZero = widget.pageScrollController.position.pixels == 0;
    if (isPositionZero != isScrolledToTop) {
      setState(() {
        isScrolledToTop = isPositionZero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: Colors.black.withOpacity(0.1),
              width: 1,
            ),
          ),
          boxShadow: [
            if (!isScrolledToTop)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 1), // changes position of shadow
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: widget.timeLineWidth + widget.hourIndicatorSettings.offset,
              child: widget.fullDayHeaderTitle.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 2,
                        horizontal: 1,
                      ),
                      child: Text(
                        widget.fullDayHeaderTitle,
                        textAlign: widget.fullDayHeaderTextConfig.textAlign,
                        maxLines: widget.fullDayHeaderTextConfig.maxLines,
                        overflow: widget.fullDayHeaderTextConfig.textOverflow,
                      ),
                    )
                  : SizedBox.shrink(),
            ),
            ...List.generate(
              widget.filteredDates.length,
              (index) {
                final fullDayEventList = widget.controller
                    .getFullDayEvent(widget.filteredDates[index]);
                // Always call the builder - allows custom implementations
                // to fetch events from external sources (e.g., Riverpod/Firestore)
                return Container(
                  width: widget.weekTitleWidth,
                  child: widget.fullDayEventBuilder.call(
                    fullDayEventList,
                    widget.filteredDates[index],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
