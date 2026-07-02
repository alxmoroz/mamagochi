import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../L1_domain/entities/abstract_entry.dart';
import '../../../L1_domain/entities/feed.dart';
import '../../../L1_domain/entities/sleep.dart';
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
import 'edit_feed_dialog.dart';
import 'edit_sleep_dialog.dart';
import 'day_summary.dart';
import 'history_controller.dart';

class HistoryRoute extends MTRoute {
  static const staticBaseName = 'history';

  HistoryRoute({super.parent})
    : super(path: staticBaseName, baseName: staticBaseName, builder: (_, state) => _HistoryView(state.extra as HistoryController));
}

class _HistoryView extends StatelessWidget {
  const _HistoryView(this._hc);
  final HistoryController _hc;

  Future<bool> _delete(AbstractEntry entry) async {
    await _hc.deleteEntry(entry);
    return false;
  }

  Widget _summaryCard({required String title, required List<Widget> rows}) {
    return MTCard(
      radius: P3,
      elevation: buttonElevation,
      padding: const EdgeInsets.symmetric(horizontal: P3, vertical: P2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BaseText.medium(title, color: f3Color, maxLines: 1, align: TextAlign.center),
          ...rows,
          const Spacer(),
        ],
      ),
    );
  }

  Widget _summaryRow(String iconName, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: P),
      child: Row(
        children: [
          MTSvgIcon(iconName, size: P5),
          const SizedBox(width: P),
          Flexible(child: SmallText.medium(text)),
        ],
      ),
    );
  }

  Widget _sleepSummaryCard(DaySummary summary) {
    return _summaryCard(
      title: loc.history_sleep_title,
      rows: [
        _summaryRow('eye_closed', summary.sleepDuration.strInHoursAndMinutes),
        _summaryRow('eye_open', summary.awakeDuration.strInHoursAndMinutes),
      ],
    );
  }

  Widget _feedSummaryCard(DaySummary summary) {
    final rows = <Widget>[];
    if (summary.showBreastRow) {
      rows.add(_summaryRow('breast', summary.breastDuration.strInHoursAndMinutes));
    }
    if (summary.showBottleRow) {
      rows.add(_summaryRow('bottle_empty', '${summary.bottleCountMl}\u00A0${loc.milliliters}'));
    }

    return _summaryCard(title: loc.history_feeds_title, rows: rows);
  }

  Widget _daySummaryCards(DateTime date) {
    final summary = _hc.daySummaryFor(date);
    if (!summary.showSleepCard && !summary.showFeedCard) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(P3, P2, P3, P2),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = (constraints.maxWidth - P2) / 2;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (summary.showSleepCard) SizedBox(width: cardWidth, child: _sleepSummaryCard(summary)),
                if (summary.showSleepCard && summary.showFeedCard) const SizedBox(width: P2),
                if (summary.showFeedCard) SizedBox(width: cardWidth, child: _feedSummaryCard(summary)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _dayEntries(DateTime date, Iterable<AbstractEntry> group, BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        MTListGroupTitle(titleText: date.strMedium),
        _daySummaryCards(date),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: group.length,
          itemBuilder: (_, index) {
            final entry = group.elementAt(index);
            final isStillSleep = entry is Sleep && entry.isStillSleeping;

            return Slidable(
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
              child: entry is Feed
                  ? MTListTile(
                      leading: entry.feedImage(size: P10),
                      titleText: entry.feedTypeName,
                      subtitle: entry.type.isBreast
                          ? (entry.isMoreMinute ? SmallText(entry.historyBreastFeedDuration) : null)
                          : entry.shouldShowCount
                          ? SmallText(entry.feedCount)
                          : null,
                      trailing: SmallText(
                        entry.type.isBreast && entry.isStillFeeding ? entry.historyStillFeedingTimeTitle : entry.historyStartEndTimeTitle,
                        align: TextAlign.right,
                      ),
                      bottomDivider: index < group.length - 1,
                      onTap: () => EditFeedDialog.show(entry),
                    )
                  : entry is Sleep
                  ? MTListTile(
                      leading: entry.sleepImage(size: P10),
                      titleText: entry.isMoreMinute ? loc.history_sleep_title : '',
                      subtitle: SmallText(entry.isMoreMinute ? entry.sleepDuration : ''),
                      trailing: SmallText(isStillSleep ? entry.historyStillSleepTimeTitle : entry.historyStartEndTimeTitle, align: TextAlign.right),
                      bottomDivider: index < group.length - 1,
                      onTap: () => EditSleepDialog.show(entry),
                    )
                  : const SizedBox(),
            );
          },
        ),
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
                  return group != null ? _dayEntries(date, group, context) : const SizedBox();
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
