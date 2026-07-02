import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../L1_domain/entities/abstract_entry.dart';
import '../../../L1_domain/entities/feed.dart';
import '../../../L1_domain/entities/sleep.dart';
import '../../../L1_domain/utils/dates.dart';
import '../../components/card.dart';
import '../../components/colors.dart';
import '../../components/constants.dart';
import '../../components/icons.dart';
import '../../components/images.dart';
import '../../components/list_tile.dart';
import '../../components/page.dart';
import '../../components/text.dart';
import '../../components/toolbar.dart';
import '../../navigation/route.dart';
import '../../presenters/date.dart';
import '../../presenters/duration.dart';
import '../../presenters/entry.dart';
import '../../presenters/feed.dart';
import '../../presenters/sleep.dart';
import '../app/services.dart';
import 'day_summary.dart';
import 'edit_feed_dialog.dart';
import 'edit_sleep_dialog.dart';
import 'history_controller.dart';

enum _HistoryDayFilter { sleep, feed }

class HistoryRoute extends MTRoute {
  static const staticBaseName = 'history';

  HistoryRoute({super.parent})
    : super(path: staticBaseName, baseName: staticBaseName, builder: (_, state) => _HistoryView(state.extra as HistoryController));
}

class _HistoryView extends StatefulWidget {
  const _HistoryView(this._hc);
  final HistoryController _hc;

  @override
  State<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<_HistoryView> with TickerProviderStateMixin {
  final _expandedByDay = <DateTime, Set<_HistoryDayFilter>>{};
  final _filterAnimations = <DateTime, Map<_HistoryDayFilter, AnimationController>>{};
  final _filterRevealAnimations = <DateTime, Map<_HistoryDayFilter, Animation<double>>>{};

  HistoryController get _hc => widget._hc;

  @override
  void dispose() {
    for (final dayAnimations in _filterAnimations.values) {
      for (final controller in dayAnimations.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  AnimationController _animationFor(DateTime date, _HistoryDayFilter filter) {
    final day = date.date;
    return _filterAnimations.putIfAbsent(day, () => {}).putIfAbsent(filter, () {
      final controller = AnimationController(
        vsync: this,
        duration: KB_RELATED_ANIMATION_DURATION,
        reverseDuration: KB_RELATED_ANIMATION_DURATION,
      );
      controller.addListener(() {
        if (mounted) setState(() {});
      });
      controller.addStatusListener((status) {
        if (status == AnimationStatus.dismissed && mounted) setState(() {});
      });
      return controller;
    });
  }

  Animation<double> _revealAnimation(DateTime date, _HistoryDayFilter filter) {
    final day = date.date;
    final controller = _animationFor(date, filter);
    return _filterRevealAnimations.putIfAbsent(day, () => {}).putIfAbsent(
      filter,
      () => CurvedAnimation(parent: controller, curve: Curves.easeInOut, reverseCurve: Curves.easeInOut),
    );
  }

  Future<bool> _delete(AbstractEntry entry) async {
    await _hc.deleteEntry(entry);
    return false;
  }

  void _toggleDayFilter(DateTime date, _HistoryDayFilter filter) {
    final day = date.date;
    final animation = _animationFor(date, filter);
    if (_isFilterExpanded(date, filter)) {
      setState(() {
        _expandedByDay[day]?.remove(filter);
        if (_expandedByDay[day]?.isEmpty ?? false) _expandedByDay.remove(day);
      });
      animation.reverse();
    } else {
      setState(() {
        _expandedByDay.putIfAbsent(day, () => {}).add(filter);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        animation.forward(from: 0);
      });
    }
  }

  bool _isFilterExpanded(DateTime date, _HistoryDayFilter filter) => _expandedByDay[date.date]?.contains(filter) ?? false;

  bool _isSelected(DateTime date, _HistoryDayFilter filter) => _isFilterExpanded(date, filter);

  bool _showsFilterEntries(DateTime date, _HistoryDayFilter filter) {
    if (_isFilterExpanded(date, filter)) return true;
    return (_filterAnimations[date.date]?[filter]?.value ?? 0) > 0;
  }

  _HistoryDayFilter _filterForEntry(AbstractEntry entry) =>
      entry is Sleep ? _HistoryDayFilter.sleep : _HistoryDayFilter.feed;

  bool _showsEntry(DateTime date, AbstractEntry entry) =>
      _showsFilterEntries(date, _filterForEntry(entry));

  Widget _animatedEntryTile(DateTime date, AbstractEntry entry, BuildContext context) {
    final animation = _revealAnimation(date, _filterForEntry(entry));

    return ClipRect(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) => Align(
          alignment: Alignment.topCenter,
          heightFactor: animation.value.clamp(0.0, 1.0),
          child: child,
        ),
        child: _entryTile(entry, context),
      ),
    );
  }

  Widget _summaryCard({
    required BuildContext context,
    required List<Widget> rows,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MTCard(
        radius: P3,
        elevation: buttonElevation,
        padding: const EdgeInsets.all(P2),
        borderSide: selected ? BorderSide(color: mainColor.resolve(context), width: 3) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: rows,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: P),
              child: Center(
                child: AnimatedRotation(
                  turns: selected ? 0.5 : 0,
                  duration: KB_RELATED_ANIMATION_DURATION,
                  curve: Curves.easeInOut,
                  child: MTSvgIcon('chevron_down', size: P5, color: selected ? mainColor : null),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String iconName, String text, {bool isFirst = false}) {
    return Padding(
      padding: EdgeInsets.only(top: isFirst ? 0 : P),
      child: Row(
        children: [
          MTSvgIcon(iconName, size: P5),
          const SizedBox(width: P),
          Flexible(child: SmallText.medium(text)),
        ],
      ),
    );
  }

  Widget _sleepSummaryCard(BuildContext context, DateTime date, DaySummary summary) {
    return _summaryCard(
      context: context,
      selected: _isSelected(date, _HistoryDayFilter.sleep),
      onTap: () => _toggleDayFilter(date, _HistoryDayFilter.sleep),
      rows: [
        _summaryRow('eye_closed', summary.sleepDuration.strInHoursAndMinutes, isFirst: true),
        _summaryRow('eye_open', summary.awakeDuration.strInHoursAndMinutes),
      ],
    );
  }

  Widget _feedSummaryCard(BuildContext context, DateTime date, DaySummary summary) {
    final rows = <Widget>[];
    if (summary.showBreastRow) {
      rows.add(_summaryRow('breast', summary.breastDuration.strInHoursAndMinutes, isFirst: rows.isEmpty));
    }
    if (summary.showBottleRow) {
      rows.add(_summaryRow('bottle_empty', '${summary.bottleCountMl}\u00A0${loc.milliliters}', isFirst: rows.isEmpty));
    }

    return _summaryCard(
      context: context,
      selected: _isSelected(date, _HistoryDayFilter.feed),
      onTap: () => _toggleDayFilter(date, _HistoryDayFilter.feed),
      rows: rows,
    );
  }

  Widget _daySummaryCards(BuildContext context, DateTime date) {
    final summary = _hc.daySummaryFor(date);
    if (!summary.showSleepCard && !summary.showFeedCard) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(P3, 0, P3, P2),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = (constraints.maxWidth - P2) / 2;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (summary.showSleepCard) SizedBox(width: cardWidth, child: _sleepSummaryCard(context, date, summary)),
                if (summary.showSleepCard && summary.showFeedCard) const SizedBox(width: P2),
                if (summary.showFeedCard) SizedBox(width: cardWidth, child: _feedSummaryCard(context, date, summary)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _entryTimeTrailing(String text) {
    final newlineIndex = text.indexOf('\n');
    if (newlineIndex < 0) return SmallText(text, align: TextAlign.right);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        SmallText(text.substring(0, newlineIndex), color: f3Color, align: TextAlign.right),
        SmallText(text.substring(newlineIndex + 1), align: TextAlign.right),
      ],
    );
  }

  Widget _entryTile(AbstractEntry entry, BuildContext context) {
    final isStillSleep = entry is Sleep && entry.isStillSleeping;

    return Padding(
      padding: const EdgeInsets.fromLTRB(P3, 0, P3, P2),
      child: Slidable(
        key: ObjectKey(entry),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          dismissible: DismissiblePane(onDismissed: () {}, confirmDismiss: () async => await _delete(entry)),
          children: [
            CustomSlidableAction(
              onPressed: (_) async => await _delete(entry),
              backgroundColor: dangerColor.resolve(context),
              child: const DeleteIcon(color: whiteColor, size: P6),
            ),
          ],
        ),
        child: MTCard(
          radius: P3,
          elevation: buttonElevation,
          child: entry is Feed
              ? MTListTile(
                  padding: const EdgeInsets.symmetric(horizontal: P3, vertical: P2),
                  leading: entry.feedImage(size: P10),
                  titleText: entry.feedTypeName,
                  subtitle: entry.type.isBreast
                      ? (entry.isMoreMinute ? SmallText(entry.historyBreastFeedDuration) : null)
                      : entry.shouldShowCount
                      ? SmallText(entry.feedCount)
                      : null,
                  trailing: _entryTimeTrailing(
                    entry.type.isBreast && entry.isStillFeeding ? entry.historyStillFeedingTimeTitle : entry.historyStartEndTimeTitle,
                  ),
                  bottomDivider: false,
                  onTap: () => EditFeedDialog.show(entry),
                )
              : entry is Sleep
              ? MTListTile(
                  padding: const EdgeInsets.symmetric(horizontal: P3, vertical: P2),
                  leading: entry.sleepImage(size: P10),
                  titleText: entry.isMoreMinute ? loc.history_sleep_title : '',
                  subtitle: SmallText(entry.isMoreMinute ? entry.sleepDuration : ''),
                  trailing: _entryTimeTrailing(isStillSleep ? entry.historyStillSleepTimeTitle : entry.historyStartEndTimeTitle),
                  bottomDivider: false,
                  onTap: () => EditSleepDialog.show(entry),
                )
              : const SizedBox(),
        ),
      ),
    );
  }

  Widget _dayDateTitle(DateTime date, {required bool isFirst}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(P3, isFirst ? P2 : P, P3, P2),
      child: SmallText.medium(date.strMedium, color: f1Color),
    );
  }

  Widget _dayEntries(DateTime date, Iterable<AbstractEntry> group, BuildContext context, {required bool isFirst}) {
    final entries = group.toList();
    final entryTiles = <Widget>[];

    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      if (!_showsEntry(date, entry)) continue;
      entryTiles.add(_animatedEntryTile(date, entry, context));
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _dayDateTitle(date, isFirst: isFirst),
        _daySummaryCards(context, date),
        ...entryTiles,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MTPage(
        navBar: MTNavBar(pageTitle: loc.history_title),
        body: _hc.hasEntries
            ? ListView.builder(
                itemCount: _hc.groupedEntries.keys.length,
                itemBuilder: (_, index) {
                  final date = _hc.groupedEntries.keys.elementAt(index);
                  final group = _hc.groupedEntries[date];
                  return group != null ? _dayEntries(date, group, context, isFirst: index == 0) : const SizedBox();
                },
              )
            : Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MTImage('no_info', height: P10 * 5, width: P10 * 5),
                    H1(loc.history_empty_title, align: TextAlign.center),
                  ],
                ),
              ),
      ),
    );
  }
}
