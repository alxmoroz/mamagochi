// Copyright (c) 2026. Xenia Moroz

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../../L1_domain/entities/baby.dart';
import '../../components/background.dart';
import '../../components/button.dart';
import '../../components/colors.dart';
import '../../components/constants.dart';
import '../../components/dialog.dart';
import '../../components/images.dart';
import '../../components/text.dart';
import '../../presenters/baby.dart';
import '../app/services.dart';
import 'animated_birthday_cake.dart';

class BirthdayCongratsDialog extends StatefulWidget {
  const BirthdayCongratsDialog._();

  static bool _isShowing = false;

  static Future<void> showIfNeeded() async {
    final baby = mainController.selectedBabyController?.baby;
    // Показываем только если юбилей именно сегодня.
    // Если пользователь пропустил день (давно не заходил) — экран не показываем и не догоняем.
    if (baby == null || !baby.isMonthlyAnniversaryToday) return;
    if (localSettingsController.wasBirthdayCongratsShownToday(baby.created)) return;
    if (_isShowing) return;

    _isShowing = true;
    try {
      await showMTDialog(
        const BirthdayCongratsDialog._(),
        forceCenter: true,
        barrierColor: const Color(0x00000000),
      );
    } finally {
      _isShowing = false;
    }
  }

  @override
  State<BirthdayCongratsDialog> createState() => _BirthdayCongratsDialogState();
}

class _BirthdayCongratsDialogState extends State<BirthdayCongratsDialog> {
  static const _closeButtonMargin = 40.0;
  static const _cakeSize = 200.0;
  static const _fadeDuration = Duration(milliseconds: 500);

  bool _celebrating = false;
  late final ConfettiController _confettiController;

  Baby get _baby => mainController.selectedBabyController!.baby;

  BabyAge get _age => _baby.fullAge!;

  bool get _isBirthDay => _age.isBirthDay;

  String get _title => _isBirthDay
      ? loc.birthday_congrats_birth_title
      : loc.birthday_congrats_anniversary_title(_age.formatAnniversaryAge());

  String get _body => _isBirthDay ? loc.birthday_congrats_birth_body : loc.birthday_congrats_anniversary_body;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onTapScreen() {
    if (!_celebrating) setState(() => _celebrating = true);
    _confettiController.play();
  }

  Future<void> _onThanks() async {
    await localSettingsController.markBirthdayCongratsShown(_baby.created);
    if (mounted) Navigator.of(context).pop();
  }

  Widget get _giftsBackground => const Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: 194,
        child: MTSvgImage('gifts', height: 194, width: 390),
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: MTBackgroundWrapper(
        background: _giftsBackground,
        SafeArea(
          child: LayoutBuilder(
            builder: (_, constraints) {
              final isLandscape = constraints.maxWidth > constraints.maxHeight;
              final spacing = isLandscape ? P : P2;
              final spacingLarge = isLandscape ? P2 : P3;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _onTapScreen,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(P2),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: _fadeDuration,
                              child: _celebrating
                                  ? H1(_title, align: TextAlign.center, key: const ValueKey('title'))
                                  : H2(
                                      loc.birthday_congrats_tap_me,
                                      color: f2Color,
                                      align: TextAlign.center,
                                      key: const ValueKey('tap'),
                                    ),
                            ),
                            SizedBox(height: spacing),
                            const AnimatedBirthdayCake(size: _cakeSize),
                            SizedBox(height: spacingLarge),
                            AnimatedOpacity(
                              opacity: _celebrating ? 1 : 0,
                              duration: _fadeDuration,
                              child: BaseText(_body, color: f2Color, align: TextAlign.center),
                            ),
                          ],
                        ),
                      ),
                      IgnorePointer(
                        child: ConfettiWidget(
                          confettiController: _confettiController,
                          blastDirectionality: BlastDirectionality.explosive,
                          emissionFrequency: 1,
                          numberOfParticles: 60,
                          maxBlastForce: 40,
                          minBlastForce: 15,
                          gravity: 0.15,
                          colors: const [
                            Color(0xFFFF6E83),
                            Color(0xFF9DC44D),
                            Color(0xFFFFB300),
                            Color(0xFF64AAFF),
                            Color(0xFFD4495D),
                          ],
                        ),
                      ),
                      if (!isLandscape)
                        Positioned(
                          bottom: _closeButtonMargin,
                          left: 0,
                          right: 0,
                          child: AnimatedOpacity(
                            opacity: _celebrating ? 1 : 0,
                            duration: _fadeDuration,
                            child: IgnorePointer(
                              ignoring: !_celebrating,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: MTButton.main(
                                  titleText: loc.birthday_congrats_thanks_action,
                                  onTap: () => _onThanks(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (isLandscape && _celebrating)
                        Positioned(
                          bottom: P2,
                          left: 0,
                          right: 0,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: MTButton.main(
                              titleText: loc.birthday_congrats_thanks_action,
                              onTap: () => _onThanks(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
