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
  /// Сон и кормления одного дня могут быть раскрыты одновременно.
  final _expandedByDay = <DateTime, Set<_HistoryDayFilter>>{};
  final _filterAnimations = <DateTime, Map<_HistoryDayFilter, AnimationController>>{};
  final _filterRevealAnimations = <DateTime, Map<_HistoryDayFilter, Animation<double>>>{};
  /// Запись остаётся на экране до конца анимации схлопывания.
  final _deletingEntries = <AbstractEntry>{};
  final _entryDeleteAnimations = <DateTime, AnimationController>{};
  /// День остаётся в списке до конца анимации скрытия, если удалена последняя запись.
  final _retainedDays = <DateTime>{};
  final _dayHideAnimations = <DateTime, AnimationController>{};
  final _summaryHideAnimations = <DateTime, Map<_HistoryDayFilter, AnimationController>>{};

  HistoryController get _hc => widget._hc;

  /// Дни из данных + удерживаемые для анимации исчезновения.
  List<DateTime> get _visibleDays {
    final days = {..._hc.groupedEntries.keys, ..._retainedDays};
    return days.toList()..sort((a, b) => b.compareTo(a));
  }

  @override
  void dispose() {
    for (final dayAnimations in _filterAnimations.values) {
      for (final controller in dayAnimations.values) {
        controller.dispose();
      }
    }
    for (final controller in _entryDeleteAnimations.values) {
      controller.dispose();
    }
    for (final controller in _dayHideAnimations.values) {
      controller.dispose();
    }
    for (final dayAnimations in _summaryHideAnimations.values) {
      for (final controller in dayAnimations.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  AnimationController _trackedController(
    Map<DateTime, AnimationController> storage,
    DateTime key, {
    double initialValue = 1,
  }) {
    return storage.putIfAbsent(key, () {
      final controller = AnimationController(
        vsync: this,
        duration: KB_RELATED_ANIMATION_DURATION,
        reverseDuration: KB_RELATED_ANIMATION_DURATION,
        value: initialValue,
      );
      controller.addListener(() {
        if (mounted) setState(() {});
      });
      return controller;
    });
  }

  AnimationController _trackedFilterController(
    Map<DateTime, Map<_HistoryDayFilter, AnimationController>> storage,
    DateTime day,
    _HistoryDayFilter filter, {
    double initialValue = 1,
  }) {
    return storage.putIfAbsent(day, () => {}).putIfAbsent(filter, () {
      final controller = AnimationController(
        vsync: this,
        duration: KB_RELATED_ANIMATION_DURATION,
        reverseDuration: KB_RELATED_ANIMATION_DURATION,
        value: initialValue,
      );
      controller.addListener(() {
        if (mounted) setState(() {});
      });
      return controller;
    });
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

  AnimationController _deleteAnimationFor(AbstractEntry entry) =>
      _trackedController(_entryDeleteAnimations, entry.created);

  AnimationController _dayHideAnimationFor(DateTime day) => _trackedController(_dayHideAnimations, day);

  AnimationController _summaryHideAnimationFor(DateTime day, _HistoryDayFilter filter) =>
      _trackedFilterController(_summaryHideAnimations, day, filter);

  Future<bool> _animateDelete(AbstractEntry entry) async {
    final day = entry.end.date;
    final summaryBefore = _hc.daySummaryFor(day);
    final summaryAfter = _hc.daySummaryAfterRemoving(day, entry);
    final isLastEntryOfDay = (_hc.groupedEntries[day]?.length ?? 0) == 1;

    // 1. запись → 2. карточка сводки (если пропадёт) → 3. весь день (если последняя запись) → удаление из БД.
    setState(() => _deletingEntries.add(entry));
    await _deleteAnimationFor(entry).reverse();
    if (!mounted) return false;

    if (summaryBefore.showSleepCard && !summaryAfter.showSleepCard) {
      await _summaryHideAnimationFor(day, _HistoryDayFilter.sleep).reverse();
    }
    if (!mounted) return false;

    if (summaryBefore.showFeedCard && !summaryAfter.showFeedCard) {
      await _summaryHideAnimationFor(day, _HistoryDayFilter.feed).reverse();
    }
    if (!mounted) return false;

    if (isLastEntryOfDay) {
      setState(() => _retainedDays.add(day));
      await _dayHideAnimationFor(day).reverse();
    }
    if (!mounted) return false;

    await _hc.deleteEntry(entry);

    if (!mounted) return false;
    setState(() {
      _deletingEntries.remove(entry);
      _retainedDays.remove(day);
      _entryDeleteAnimations.remove(entry.created)?.dispose();
      _syncExpandedFilters(day, summaryAfter);
    });
    return true;
  }

  void _syncExpandedFilters(DateTime day, DaySummary summary) {
    // После удаления последней записи типа — убрать раскрытие и освободить контроллеры.
    if (!summary.showSleepCard) {
      _expandedByDay[day]?.remove(_HistoryDayFilter.sleep);
      _filterAnimations[day]?[_HistoryDayFilter.sleep]?.dispose();
      _filterAnimations[day]?.remove(_HistoryDayFilter.sleep);
      _filterRevealAnimations[day]?.remove(_HistoryDayFilter.sleep);
      _summaryHideAnimations[day]?[_HistoryDayFilter.sleep]?.dispose();
      _summaryHideAnimations[day]?.remove(_HistoryDayFilter.sleep);
    }
    if (!summary.showFeedCard) {
      _expandedByDay[day]?.remove(_HistoryDayFilter.feed);
      _filterAnimations[day]?[_HistoryDayFilter.feed]?.dispose();
      _filterAnimations[day]?.remove(_HistoryDayFilter.feed);
      _filterRevealAnimations[day]?.remove(_HistoryDayFilter.feed);
      _summaryHideAnimations[day]?[_HistoryDayFilter.feed]?.dispose();
      _summaryHideAnimations[day]?.remove(_HistoryDayFilter.feed);
    }
    if (_expandedByDay[day]?.isEmpty ?? false) _expandedByDay.remove(day);
    if (_filterAnimations[day]?.isEmpty ?? false) _filterAnimations.remove(day);
    if (_filterRevealAnimations[day]?.isEmpty ?? false) _filterRevealAnimations.remove(day);
    if (_summaryHideAnimations[day]?.isEmpty ?? false) _summaryHideAnimations.remove(day);
    _dayHideAnimations.remove(day)?.dispose();
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
      // Сначала вставить виджеты в дерево, затем запустить анимацию раскрытия.
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
    // Показывать записи и во время анимации закрытия (value > 0).
    return (_filterAnimations[date.date]?[filter]?.value ?? 0) > 0;
  }

  _HistoryDayFilter _filterForEntry(AbstractEntry entry) =>
      entry is Sleep ? _HistoryDayFilter.sleep : _HistoryDayFilter.feed;

  bool _showsEntry(DateTime date, AbstractEntry entry) {
    // Удаляемая запись видна, даже если фильтр уже снят.
    if (_deletingEntries.contains(entry)) return true;
    return _showsFilterEntries(date, _filterForEntry(entry));
  }

  /// Сжатие по heightFactor — как при закрытии карточки сводки.
  Widget _collapseOnAnimation({
    required Animation<double> animation,
    required Widget child,
  }) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, animatedChild) => Align(
          alignment: Alignment.topCenter,
          heightFactor: animation.value.clamp(0.0, 1.0),
          child: animatedChild,
        ),
        child: child,
      ),
    );
  }

  Widget _animatedEntryTile(DateTime date, AbstractEntry entry, BuildContext context) {
    final isDeleting = _deletingEntries.contains(entry);
    final animation = isDeleting ? _deleteAnimationFor(entry) : _revealAnimation(date, _filterForEntry(entry));

    return _collapseOnAnimation(
      animation: animation,
      child: _entryTile(entry, context),
    );
  }

  Widget _animatedSummaryCard(DateTime date, _HistoryDayFilter filter, Widget card) {
    return _collapseOnAnimation(
      animation: _summaryHideAnimationFor(date, filter),
      child: card,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rows,
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
                if (summary.showSleepCard)
                  SizedBox(
                    width: cardWidth,
                    child: _animatedSummaryCard(date, _HistoryDayFilter.sleep, _sleepSummaryCard(context, date, summary)),
                  ),
                if (summary.showSleepCard && summary.showFeedCard) const SizedBox(width: P2),
                if (summary.showFeedCard)
                  SizedBox(
                    width: cardWidth,
                    child: _animatedSummaryCard(date, _HistoryDayFilter.feed, _feedSummaryCard(context, date, summary)),
                  ),
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
      child: _HistoryEntrySlidable(
        entry: entry,
        onDelete: () => _animateDelete(entry),
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

    final content = ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _dayDateTitle(date, isFirst: isFirst),
        _daySummaryCards(context, date),
        ...entryTiles,
      ],
    );

    return _collapseOnAnimation(
      animation: _dayHideAnimationFor(date.date),
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MTPage(
        navBar: MTNavBar(pageTitle: loc.history_title),
        body: _hc.hasEntries
            ? ListView.builder(
                itemCount: _visibleDays.length,
                itemBuilder: (_, index) {
                  final date = _visibleDays[index];
                  final group = _hc.groupedEntries[date] ?? const <AbstractEntry>[];
                  return _dayEntries(date, group, context, isFirst: index == 0);
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

/// Свайп-удаление: квадратная [MTCard] с корзиной. Высоту карточки записи
/// измеряем, чтобы задать сторону кнопки и [ActionPane.extentRatio].
class _HistoryEntrySlidable extends StatefulWidget {
  const _HistoryEntrySlidable({required this.entry, required this.onDelete, required this.child});

  final AbstractEntry entry;
  final Future<bool> Function() onDelete;
  final Widget child;

  @override
  State<_HistoryEntrySlidable> createState() => _HistoryEntrySlidableState();
}

class _HistoryEntrySlidableState extends State<_HistoryEntrySlidable> {
  final _childKey = GlobalKey();
  double? _childHeight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_measure);
  }

  @override
  void didUpdateWidget(covariant _HistoryEntrySlidable oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback(_measure);
  }

  void _measure([_]) {
    if (!mounted) return;
    final height = _childKey.currentContext?.size?.height;
    if (height != null && height != _childHeight) {
      setState(() => _childHeight = height);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = _childHeight;
        final extentRatio = side == null ? 0.3 : ((P2 + side) / constraints.maxWidth).clamp(0.12, 0.5);

        return Slidable(
          key: ObjectKey(widget.entry),
          endActionPane: ActionPane(
            extentRatio: extentRatio,
            motion: const ScrollMotion(),
            dismissible: DismissiblePane(
              onDismissed: () {},
              confirmDismiss: () async {
                await widget.onDelete();
                return false;
              },
            ),
            children: [
              CustomSlidableAction(
                backgroundColor: Colors.transparent,
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(P3),
                onPressed: (_) => widget.onDelete(),
                child: LayoutBuilder(
                  builder: (context, actionConstraints) {
                    final dimension = actionConstraints.maxHeight;
                    return Padding(
                      padding: const EdgeInsets.only(left: P2),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox.square(
                          dimension: dimension,
                          child: MTCard(
                            radius: P3,
                            elevation: buttonElevation,
                            color: dangerColor,
                            child: const Center(child: DeleteIcon(color: whiteColor, size: P6)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          child: KeyedSubtree(key: _childKey, child: widget.child),
        );
      },
    );
  }
}
