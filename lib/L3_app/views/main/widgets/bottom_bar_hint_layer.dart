// Copyright (c) 2026. Xenia Moroz

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../../L1_domain/entities/app_local_settings.dart';
import '../../../components/adaptive.dart';
import '../../../components/constants.dart';
import '../../../components/hint_bubble.dart';
import '../../app/services.dart';
import '../../history/history_controller.dart';

/// К какой кнопке боттом-бара указывает хвостик пузырька.
enum BottomBarHintAnchor {
  /// Левая кнопка: «Сон» / «Проснулся».
  left,

  /// Правая кнопка: «Кормление» / «Закончил кушать».
  right,
}

/// Параметры одной подсказки над боттом-баром.
class BottomBarHintSpec {
  const BottomBarHintSpec({
    required this.shouldShow,
    required this.onDismiss,
    required this.title,
    required this.message,
    required this.anchor,
  });

  final bool Function(HistoryController? hc) shouldShow;
  final Future<void> Function() onDismiss;
  final String title;
  final String message;
  final BottomBarHintAnchor anchor;
}

/// Готовые конфигурации подсказок главного экрана.
abstract final class BottomBarHints {
  static bool _notDismissed(String code) =>
      localSettingsController.settings.getString(code) != 'true';

  static BottomBarHintSpec get sleep => BottomBarHintSpec(
        shouldShow: (hc) =>
            hc != null &&
            hc.babyIsSleeping &&
            !hc.hasCompletedSleepEntries &&
            _notDismissed(ALSStringCode.SLEEP_HINT_DISMISSED),
        onDismiss: localSettingsController.markSleepHintShown,
        title: loc.sleep_hint_title,
        message: loc.sleep_hint_body,
        anchor: BottomBarHintAnchor.left,
      );

  static BottomBarHintSpec get breastFeed => BottomBarHintSpec(
        shouldShow: (hc) =>
            hc != null && hc.babyIsEating && _notDismissed(ALSStringCode.BREAST_FEED_HINT_DISMISSED),
        onDismiss: localSettingsController.markBreastFeedHintShown,
        title: loc.breast_feed_hint_title,
        message: loc.breast_feed_hint_body,
        anchor: BottomBarHintAnchor.right,
      );
}

/// Обе подсказки главного экрана (сон и кормление). Каждая живёт своим Overlay.
class MainBottomBarHintLayers extends StatelessWidget {
  const MainBottomBarHintLayers({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BottomBarHintLayer(spec: BottomBarHints.sleep),
        BottomBarHintLayer(spec: BottomBarHints.breastFeed),
      ],
    );
  }
}

/// Пузырёк-подсказка над боттом-баром с затемняющим барьером (Overlay).
class BottomBarHintLayer extends StatefulWidget {
  const BottomBarHintLayer({super.key, required this.spec});

  final BottomBarHintSpec spec;

  @override
  State<BottomBarHintLayer> createState() => _BottomBarHintLayerState();
}

class _HintLayout {
  const _HintLayout({required this.left, required this.tailOffset});
  final double left;
  final double tailOffset;
}

class _BottomBarHintLayerState extends State<BottomBarHintLayer> {
  bool _overlayInserted = false;

  BottomBarHintSpec get _spec => widget.spec;

  _HintLayout _hintPosition({
    required BottomBarHintAnchor anchor,
    required Size screenSize,
    required EdgeInsets padding,
    required bool useLandscapeLayout,
    required double bubbleWidth,
  }) {
    final buttonSide = bottomBarButtonSize(screenSize);

    if (useLandscapeLayout) {
      return switch (anchor) {
        BottomBarHintAnchor.left => _HintLayout(
          left: padding.left + P2,
          tailOffset: (buttonSide - bubbleWidth) / 2,
        ),
        BottomBarHintAnchor.right => _HintLayout(
          left: max(padding.left, screenSize.width - padding.right - P2 - bubbleWidth),
          tailOffset: (bubbleWidth - buttonSide) / 2,
        ),
      };
    }

    final bubbleLeft = ((screenSize.width - bubbleWidth) / 2).clamp(P2, screenSize.width - bubbleWidth - P2);
    final tailToRightButton = (1.5 * buttonSide + P2) - bubbleWidth / 2;

    return _HintLayout(
      left: bubbleLeft,
      tailOffset: switch (anchor) {
        BottomBarHintAnchor.right => tailToRightButton,
        BottomBarHintAnchor.left => -tailToRightButton,
      },
    );
  }

  void _insertOverlay(BuildContext context) {
    if (_overlayInserted) return;
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    late OverlayEntry entry;
    void dismiss() {
      entry.remove();
      _spec.onDismiss();
    }

    entry = OverlayEntry(
      builder: (ctx) {
        final screenSize = MediaQuery.sizeOf(ctx);
        final padding = MediaQuery.paddingOf(ctx);
        final isLandscape = MediaQuery.orientationOf(ctx) == Orientation.landscape;
        final useLandscapeLayout = isLandscape || (isBigScreen(ctx) && !isLandscape);
        final bottomTotal = bottomBarTotalHeight(screenSize, padding, isLandscape);
        final bubbleWidth = min(
          isLandscape ? SCR_S_WIDTH : SCR_XS_WIDTH,
          screenSize.width - 2 * P2,
        );
        final top = (screenSize.height - bottomTotal - HINT_BUBBLE_APPROX_HEIGHT - P2 + HINT_BUBBLE_SHIFT_DOWN)
            .clamp(P3, screenSize.height - HINT_BUBBLE_APPROX_HEIGHT - P3);
        final position = _hintPosition(
          anchor: _spec.anchor,
          screenSize: screenSize,
          padding: padding,
          useLandscapeLayout: useLandscapeLayout,
          bubbleWidth: bubbleWidth,
        );

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
                title: _spec.title,
                message: _spec.message,
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
        if (!_spec.shouldShow(hc)) return const SizedBox.shrink();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          _insertOverlay(context);
        });
        return const SizedBox.shrink();
      },
    );
  }
}
