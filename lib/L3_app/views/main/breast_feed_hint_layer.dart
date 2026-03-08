// Copyright (c) 2026. Xenia Moroz

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../L1_domain/entities/app_local_settings.dart';
import '../../components/adaptive.dart';
import '../../components/constants.dart';
import '../../components/hint_bubble.dart';
import '../app/services.dart';
import '../history/history_controller.dart';

/// Слой, который при первом появлении кнопки «Закончил кушать» показывает над боттом-баром подсказку-пузырёк с барьером (Overlay). Позиция по MediaQuery и bottomBarZoneHeight; в landscape ширина до SCR_S_WIDTH.
class BreastFeedHintLayer extends StatefulWidget {
  const BreastFeedHintLayer({super.key});

  @override
  State<BreastFeedHintLayer> createState() => _BreastFeedHintLayerState();
}

class _BreastFeedHintLayerState extends State<BreastFeedHintLayer> {
  bool _overlayInserted = false;

  bool _shouldShowHint(HistoryController? hc) {
    if (hc == null || !hc.babyIsEating) return false;
    final settings = localSettingsController.settings;
    return settings.getString(ALSStringCode.BREAST_FEED_HINT_DISMISSED) != 'true';
  }

  void _insertOverlay(BuildContext context, HistoryController hc) {
    if (_overlayInserted) return;
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    late OverlayEntry entry;
    void dismiss() {
      entry.remove();
      localSettingsController.markBreastFeedHintShown();
    }

    entry = OverlayEntry(
      builder: (ctx) {
        final screenSize = MediaQuery.sizeOf(ctx);
        final padding = MediaQuery.paddingOf(ctx);
        final isLandscape = MediaQuery.orientationOf(ctx) == Orientation.landscape;
        const bubbleApproxHeight = 160.0;
        // Нижний отступ: в портрете как в main_view SafeArea(minimum: P5); в ландшафте только фактический padding, иначе завышаем зону и подсказка уезжает вверх
        final effectiveBottomInset = isLandscape ? padding.bottom : max(padding.bottom, P5);
        final zoneHeight = bottomBarZoneHeight(screenSize);
        final bottomTotal = effectiveBottomInset + zoneHeight;
        // В landscape разрешаем ширину до SCR_S_WIDTH
        final bubbleWidth = min(
          isLandscape ? SCR_S_WIDTH : SCR_XS_WIDTH,
          screenSize.width - 2 * P2,
        );
        final top = (screenSize.height - bottomTotal - bubbleApproxHeight - P2 + HINT_BUBBLE_SHIFT_DOWN)
            .clamp(P3, screenSize.height - bubbleApproxHeight - P3);
        final buttonSide = bottomBarButtonSize(screenSize);
        final double left;
        final double tailOffset;
        if (isLandscape) {
          // В ландшафте как у правой кнопки бара: контент внутри SafeArea, справа от кнопки SizedBox(P2), т.е. правый край кнопки = width - padding.right - P2
          left = max(padding.left, screenSize.width - padding.right - P2 - bubbleWidth);
          tailOffset = (bubbleWidth - buttonSide) / 2;
        } else {
          left = ((screenSize.width - bubbleWidth) / 2).clamp(P2, screenSize.width - bubbleWidth - P2);
          tailOffset = (1.5 * buttonSide + P2) - bubbleWidth / 2;
        }

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: dismiss,
                child: Container(color: Colors.black.withValues(alpha: 0.3)),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              child: HintBubble(
                title: loc.breast_feed_hint_title,
                message: loc.breast_feed_hint_body,
                onDismiss: dismiss,
                width: bubbleWidth,
                tailOffset: tailOffset,
              ),
            ),
          ],
        );
      },
    );
    overlay.insert(entry);
    setState(() => _overlayInserted = true);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        final hc = mainController.selectedBabyController?.historyController;
        if (!_shouldShowHint(hc)) return const SizedBox.shrink();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          _insertOverlay(context, hc!);
        });
        return const SizedBox.shrink();
      },
    );
  }
}
