import 'package:flutter/material.dart';

import '../../../../L1_domain/entities/baby.dart';
import '../../../components/button.dart';
import '../../../components/colors.dart';
import '../../../components/constants.dart';
import '../../../components/dialog.dart';
import '../../../components/images.dart';
import '../../../components/text.dart';
import '../../../presenters/baby.dart';
import '../../app/services.dart';

class BabyProfileDialog extends StatelessWidget {
  const BabyProfileDialog._();

  static Future<void> show() async => await showMTDialog(const BabyProfileDialog._(), forceCenter: true);

  Baby get _baby => mainController.selectedBabyController!.baby;

  static const _closeButtonMargin = 40.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (_, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          final spacing = isLandscape ? P : P2;
          final spacingLarge = isLandscape ? P2 : P3;

          return GestureDetector(
            onTap: Navigator.of(context).pop,
            child: Container(
              color: Colors.transparent,
              width: constraints.maxWidth,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  /// Контент диалога
                  Container(
                    padding: const EdgeInsets.all(P2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// Имя малыша
                        if (_baby.named) H1(_baby.name!, color: f2Color, align: TextAlign.center),
                        if (_baby.named) SizedBox(height: spacing),

                        /// Дата рождения
                        if (_baby.formattedDateOfBirth != null) BaseText(_baby.formattedDateOfBirth!, color: f2Color, align: TextAlign.center),
                        if (_baby.formattedDateOfBirth != null && !isLandscape) SizedBox(height: spacingLarge),

                        /// Картинка малыша
                        _baby.image(size: 200),
                        if (!isLandscape) SizedBox(height: spacingLarge),

                        /// Возраст малыша
                        _buildAgeDisplay(spacing),
                      ],
                    ),
                  ),

                  /// Кнопка закрытия (только в вертикальном режиме)
                  if (!isLandscape)
                    Positioned(
                      bottom: _closeButtonMargin,
                      left: 0,
                      right: 0,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: MTButton(
                          minSize: const Size.square(100),
                          color: b3Color,
                          type: MTButtonType.main,
                          middle: const MTImage('close', height: 50),
                          onTap: Navigator.of(context).pop,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAgeDisplay(double spacing) {
    final fullAge = _baby.fullAge;
    if (fullAge == null) return const SizedBox();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Форматированный возраст (презентер сам разберётся со всеми случаями)
        H2(fullAge.format(), color: f2Color, align: TextAlign.center),

        // Показываем недели только если уже родился
        if (fullAge.daysUntilBirth == null && _baby.ageInWeeks != null) ...[
          SizedBox(height: spacing),
          BaseText(loc.weeks_count_accusative(_baby.ageInWeeks!), color: f2Color, align: TextAlign.center),
        ],
      ],
    );
  }
}
