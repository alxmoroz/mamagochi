// Copyright (c) 2026. Xenia Moroz

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../L1_domain/entities/app_local_settings.dart';
import '../../components/constants.dart';
import '../../components/hint_bubble.dart';
import '../app/services.dart';
import '../history/history_controller.dart';

/// Слой, который при первом появлении кнопки «Закончил кушать» показывает над боттом-баром подсказку-пузырёк с барьером (Overlay). Позиция по MediaQuery и BOTTOM_BAR_ZONE_HEIGHT.
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

    final screenSize = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final bubbleWidth = min(SCR_XS_WIDTH, screenSize.width - 2 * P2);
    const bubbleApproxHeight = 160.0;
    // Нижний отступ страницы как в main_view: SafeArea(minimum: P5), т.е. max(padding.bottom, P5)
    final effectiveBottomInset = max(padding.bottom, P5);
    final bottomZoneHeight = BOTTOM_BAR_ZONE_HEIGHT + effectiveBottomInset;
    final top = (screenSize.height - bottomZoneHeight - bubbleApproxHeight - P2 + HINT_BUBBLE_SHIFT_DOWN).clamp(P3, screenSize.height - bubbleApproxHeight - P3);
    final left = ((screenSize.width - bubbleWidth) / 2).clamp(P2, screenSize.width - bubbleWidth - P2);
    final buttonWidth = min(180.0, min(screenSize.width, screenSize.height) / 2 - P3);
    // Центр треугольника от левого края пузырька = 1.5*кнопка + P2; сдвиг от текущего центра (bubbleWidth/2):
    final tailOffset = (1.5 * buttonWidth + P2) - bubbleWidth / 2;

    late OverlayEntry entry;
    void dismiss() {
      entry.remove();
      localSettingsController.markBreastFeedHintShown();
    }

    entry = OverlayEntry(
      builder: (ctx) => Stack(
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
      ),
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
