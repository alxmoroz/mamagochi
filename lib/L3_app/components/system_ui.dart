// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter/services.dart';

import '../../L2_data/services/platform.dart';

/// Utility class for managing system UI overlays and edge-to-edge display
class SystemUIHelper {
  /// Enable edge-to-edge display (Android only)
  static void enableEdgeToEdge() {
    if (!isAndroid) return;
    
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  }
}