// Copyright (c) 2024. Alexandr Moroz

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../components/button.dart';
import '../../../components/colors.dart';
import '../../../components/constants.dart';
import '../../../components/images.dart';
import '../../../components/text.dart';
import '../../app/services.dart';
import '../../history/history_controller.dart';
import '../../../presenters/duration.dart';
import '../../../presenters/sleep.dart';

/// Таймер сна или кормления в правом верхнем углу главного экрана. Показывает один из двух в зависимости от состояния.
class MainHeaderTimer extends StatelessWidget {
  const MainHeaderTimer({
    super.key,
    required this.hc,
    required this.buttonSize,
    required this.onEditStartSleep,
    required this.onEditStartBreastFeed,
  });

  final HistoryController hc;
  final double buttonSize;
  final VoidCallback onEditStartSleep;
  final VoidCallback onEditStartBreastFeed;

  @override
  Widget build(BuildContext context) {
    final child = hc.babyIsSleeping
        ? _SleepTimerButton(hc: hc, buttonSize: buttonSize, onTap: onEditStartSleep)
        : hc.babyIsEating
            ? _FeedingTimerButton(hc: hc, buttonSize: buttonSize, onTap: onEditStartBreastFeed)
            : null;
    if (child == null) return const SizedBox();
    return Align(alignment: Alignment.topRight, child: child);
  }
}

Widget _timerButton({required double buttonSize, required Widget trailing, required VoidCallback onTap}) =>
    MTButton(
      minSize: Size(buttonSize, 90),
      constrained: false,
      color: b3Color,
      margin: const EdgeInsets.symmetric(horizontal: P2),
      type: MTButtonType.main,
      leading: const MTImage('time', height: 60),
      trailing: trailing,
      onTap: onTap,
    );

class _SleepTimerButton extends StatelessWidget {
  const _SleepTimerButton({required this.hc, required this.buttonSize, required this.onTap});
  final HistoryController hc;
  final double buttonSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sleepDuration = hc.lastSleep?.durationFromStartToNow;
    final sleepDurationStr = sleepDuration?.strInHoursAndMinutes;
    final text = sleepDuration != null && sleepDuration.inMinutes > 1
        ? loc.how_much_sleep(sleepDurationStr!)
        : hc.lastSleep?.sleepJustNowTitle ?? '';
    return _timerButton(
      buttonSize: buttonSize,
      trailing: H2(text, maxLines: 2, color: f2Color),
      onTap: onTap,
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

class _FeedingTimerButtonState extends State<_FeedingTimerButton> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedDuration = widget.hc.lastOngoingBreastFeed?.durationFromStartToNow;
    final durationStr = feedDuration?.strInHoursMinutesAndSeconds ?? '';
    final displayStr = durationStr.isEmpty ? loc.time_seconds(0) : durationStr;
    return _timerButton(
      buttonSize: widget.buttonSize,
      trailing: H2(loc.how_much_feeding(displayStr), maxLines: 2, color: f2Color),
      onTap: widget.onTap,
    );
  }
}
