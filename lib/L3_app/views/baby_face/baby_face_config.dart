import '../../../L1_domain/entities/baby.dart';
import 'baby_face_assets.dart';
import 'baby_face_mode.dart';

class BabyFaceConfig {
  const BabyFaceConfig({required this.layers});

  final List<String> layers;

  factory BabyFaceConfig.forBaby(Baby baby, BabyFaceMode mode) {
    return BabyFaceConfig(
      layers: [
        BabyFaceAssets.base,
        _eyes(mode),
        _mouth(baby, mode),
        _hair(baby),
        if (mode == BabyFaceMode.sleep) BabyFaceAssets.sleepZzz,
      ],
    );
  }

  static String _hair(Baby baby) => baby.isBoy ? BabyFaceAssets.hairBoy : BabyFaceAssets.hairGirl;

  static String _eyes(BabyFaceMode mode) => switch (mode) {
    BabyFaceMode.awake => BabyFaceAssets.eyesBlueOpen,
    BabyFaceMode.sleep => BabyFaceAssets.eyesClosed,
    BabyFaceMode.feedingLeft => BabyFaceAssets.eyesBlueOpenLeft,
    BabyFaceMode.feedingRight => BabyFaceAssets.eyesBlueOpenRight,
  };

  static String _mouth(Baby baby, BabyFaceMode mode) => switch (mode) {
    BabyFaceMode.feedingLeft || BabyFaceMode.feedingRight => BabyFaceAssets.mouthWithTongue,
    BabyFaceMode.sleep => _pacifier(baby),
    BabyFaceMode.awake => baby.isOlderNineMonths ? BabyFaceAssets.mouthWithTeeth : _pacifier(baby),
  };

  static String _pacifier(Baby baby) => baby.isBoy ? BabyFaceAssets.mouthPacifierBlue : BabyFaceAssets.mouthPacifierRed;
}
