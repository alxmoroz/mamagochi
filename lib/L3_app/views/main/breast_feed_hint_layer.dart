// Copyright (c) 2026. Xenia Moroz

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../L1_domain/entities/app_local_settings.dart';
import '../../components/constants.dart';
import '../../components/hint_bubble.dart';
import '../app/services.dart';
import '../history/history_controller.dart';

/// Слой, который при первом появлении кнопки «Закончил кушать» показывает над ней подсказку-пузырёк с барьером (Overlay).
class BreastFeedHintLayer extends StatefulWidget {
  const BreastFeedHintLayer({super.key, required this.stopFeedButtonKey});

  final GlobalKey stopFeedButtonKey;

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
    final box = widget.stopFeedButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final targetRect = box.localToGlobal(Offset.zero) & box.size;
    final screenSize = MediaQuery.sizeOf(context);
    final bubbleWidth = min(SCR_XS_WIDTH, screenSize.width - 2 * P2);
    const bubbleApproxHeight = 160.0;
    final left = ((screenSize.width - bubbleWidth) / 2).clamp(P2, screenSize.width - bubbleWidth - P2);
    final top = (targetRect.top - bubbleApproxHeight - P2).clamp(P3, screenSize.height - bubbleApproxHeight - P3);
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
