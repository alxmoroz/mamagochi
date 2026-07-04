// Copyright (c) 2024. Alexandr Moroz

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../components/button.dart';
import '../../../components/colors.dart';
import '../../../components/constants.dart';
import '../../../components/icons.dart';
import '../../../components/text.dart';
import '../../../presenters/duration.dart';
import '../../../presenters/sleep.dart';
import '../../app/services.dart';
import '../../history/history_controller.dart';

const _kSleepTimerInterval = Duration(seconds: 10);
const _kFeedingTimerInterval = Duration(seconds: 1);

/// Таймер сна или кормления в правом верхнем углу главного экрана. Показывает один из двух в зависимости от состояния.
class MainHeaderTimer extends StatelessWidget {
  const MainHeaderTimer({super.key, required this.hc, required this.buttonSize, required this.onEditStartSleep, required this.onEditStartBreastFeed});

  final HistoryController hc;
  final double buttonSize;
  final VoidCallback onEditStartSleep;
  final VoidCallback onEditStartBreastFeed;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final child = hc.babyIsSleeping
            ? _SleepTimerButton(hc: hc, buttonSize: buttonSize, onTap: onEditStartSleep)
            : hc.babyIsEating
            ? _FeedingTimerButton(hc: hc, buttonSize: buttonSize, onTap: onEditStartBreastFeed)
            : null;
        if (child == null) return const SizedBox();
        return Positioned(top: 0, right: 0, child: child);
      },
    );
  }
}

Widget _timerButton({required double buttonSize, required Widget trailing, required VoidCallback onTap}) => MTButton(
  minSize: Size(buttonSize, 90),
  constrained: false,
  color: b3Color,
  margin: const EdgeInsets.symmetric(horizontal: P2),
  padding: const EdgeInsets.symmetric(horizontal: P3),
  type: MTButtonType.main,
  middle: SizedBox(
    width: buttonSize - 2 * P3,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const MTSvgIcon('clock', size: 60),
        const SizedBox(width: P2),
        Expanded(child: trailing),
      ],
    ),
  ),
  onTap: onTap,
);

Widget _timerDurationText({required String label, required String duration}) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  mainAxisSize: MainAxisSize.min,
  children: [
    SmallText.medium(label, align: TextAlign.start, color: f2Color),
    H1(duration, align: TextAlign.start, maxLines: 1),
  ],
);

Widget _timerPlainText(String text) => H2(text, align: TextAlign.start, color: f2Color, maxLines: 2);

mixin _PeriodicRefreshMixin<T extends StatefulWidget> on State<T> {
  Timer? _ticker;
  Duration get refreshInterval;
  bool get deferSetStateToNextFrame => true;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(refreshInterval, (_) {
      if (deferSetStateToNextFrame) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });
      } else {
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

class _SleepTimerButton extends StatefulWidget {
  const _SleepTimerButton({required this.hc, required this.buttonSize, required this.onTap});
  final HistoryController hc;
  final double buttonSize;
  final VoidCallback onTap;

  @override
  State<_SleepTimerButton> createState() => _SleepTimerButtonState();
}

class _SleepTimerButtonState extends State<_SleepTimerButton> with _PeriodicRefreshMixin<_SleepTimerButton> {
  @override
  Duration get refreshInterval => _kSleepTimerInterval;

  @override
  Widget build(BuildContext context) {
    final sleepDuration = widget.hc.ongoingSleep?.durationFromStartToNow;
    final sleepDurationStr = sleepDuration?.strInHoursAndMinutes;
    final text = sleepDuration != null && sleepDuration.inMinutes > 1
        ? null
        : widget.hc.ongoingSleep?.sleepJustNowTitle ?? '';
    return _timerButton(
      buttonSize: widget.buttonSize,
      trailing: text != null
          ? _timerPlainText(text)
          : _timerDurationText(label: loc.timer_sleep_label, duration: sleepDurationStr!),
      onTap: widget.onTap,
    );
  }
}

class _FeedingTimerButton extends StatefulWidget {
  const _FeedingTimerButton({required this.hc, required this.buttonSize, required this.onTap});
  final HistoryController hc;
  final double buttonSize;
  final VoidCallback onTap;

  @override
  State<_FeedingTimerButton> createState() => _FeedingTimerButtonState();
}

class _FeedingTimerButtonState extends State<_FeedingTimerButton> with _PeriodicRefreshMixin<_FeedingTimerButton> {
  @override
  Duration get refreshInterval => _kFeedingTimerInterval;

  @override
  bool get deferSetStateToNextFrame => false;

  @override
  Widget build(BuildContext context) {
    final feedDuration = widget.hc.lastOngoingBreastFeed?.durationFromStartToNow;
    final durationStr = feedDuration?.strInHoursMinutesAndSeconds ?? '';
    final displayStr = durationStr.isEmpty ? loc.time_seconds(0) : durationStr;
    return _timerButton(
      buttonSize: widget.buttonSize,
      trailing: _timerDurationText(label: loc.timer_feeding_label, duration: displayStr),
      onTap: widget.onTap,
    );
  }
}
