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

class _HintLayout {
  const _HintLayout({required this.left, required this.tailOffset});
  final double left;
  final double tailOffset;
}

class _BreastFeedHintLayerState extends State<BreastFeedHintLayer> {
  bool _overlayInserted = false;

  bool _shouldShowHint(HistoryController? hc) {
    if (hc == null || !hc.babyIsEating) return false;
    final settings = localSettingsController.settings;
    return settings.getString(ALSStringCode.BREAST_FEED_HINT_DISMISSED) != 'true';
  }

  _HintLayout _hintPosition(
    Size screenSize,
    EdgeInsets padding,
    bool isLandscape,
    double bubbleWidth,
  ) {
    final buttonSide = bottomBarButtonSize(screenSize);
    if (isLandscape) {
      return _HintLayout(
        left: max(padding.left, screenSize.width - padding.right - P2 - bubbleWidth),
        tailOffset: (bubbleWidth - buttonSide) / 2,
      );
    }
    return _HintLayout(
      left: ((screenSize.width - bubbleWidth) / 2).clamp(P2, screenSize.width - bubbleWidth - P2),
      tailOffset: (1.5 * buttonSide + P2) - bubbleWidth / 2,
    );
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
        final bottomTotal = bottomBarTotalHeight(screenSize, padding, isLandscape);
        final bubbleWidth = min(
          isLandscape ? SCR_S_WIDTH : SCR_XS_WIDTH,
          screenSize.width - 2 * P2,
        );
        final top = (screenSize.height - bottomTotal - HINT_BUBBLE_APPROX_HEIGHT - P2 + HINT_BUBBLE_SHIFT_DOWN)
            .clamp(P3, screenSize.height - HINT_BUBBLE_APPROX_HEIGHT - P3);
        final position = _hintPosition(screenSize, padding, isLandscape, bubbleWidth);

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
              left: position.left,
              top: top,
              child: HintBubble(
                title: loc.breast_feed_hint_title,
                message: loc.breast_feed_hint_body,
                onDismiss: dismiss,
                width: bubbleWidth,
                tailOffset: position.tailOffset,
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
