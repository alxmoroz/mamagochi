import 'package:flutter_test/flutter_test.dart';
import 'package:mamagochi/L1_domain/entities/baby.dart';
import 'package:mamagochi/L1_domain/utils/dates.dart';
import 'package:mamagochi/L3_app/views/baby_face/baby_face_assets.dart';
import 'package:mamagochi/L3_app/views/baby_face/baby_face_config.dart';
import 'package:mamagochi/L3_app/views/baby_face/baby_face_mode.dart';

void main() {
  final youngDob = now.subtract(const Duration(days: 30));
  final oldDob = now.subtract(const Duration(days: 400));

  Baby boyYoung() => Baby(created: now, isBoy: true, dateOfBirth: youngDob);
  Baby girlYoung() => Baby(created: now, isBoy: false, dateOfBirth: youngDob);
  Baby boyOld() => Baby(created: now, isBoy: true, dateOfBirth: oldDob);
  Baby girlOld() => Baby(created: now, isBoy: false, dateOfBirth: oldDob);

  List<String> layers(Baby baby, BabyFaceMode mode) => BabyFaceConfig.forBaby(baby, mode).layers;

  test('awake boy young — blue pacifier', () {
    expect(
      layers(boyYoung(), BabyFaceMode.awake),
      [
        BabyFaceAssets.base,
        BabyFaceAssets.eyesBlueOpen,
        BabyFaceAssets.mouthPacifierBlue,
        BabyFaceAssets.hairBoy,
      ],
    );
  });

  test('awake girl young — red pacifier', () {
    expect(
      layers(girlYoung(), BabyFaceMode.awake),
      [
        BabyFaceAssets.base,
        BabyFaceAssets.eyesBlueOpen,
        BabyFaceAssets.mouthPacifierRed,
        BabyFaceAssets.hairGirl,
      ],
    );
  });

  test('awake boy old — teeth', () {
    expect(
      layers(boyOld(), BabyFaceMode.awake),
      [
        BabyFaceAssets.base,
        BabyFaceAssets.eyesBlueOpen,
        BabyFaceAssets.mouthWithTeeth,
        BabyFaceAssets.hairBoy,
      ],
    );
  });

  test('awake girl old — teeth', () {
    expect(
      layers(girlOld(), BabyFaceMode.awake),
      [
        BabyFaceAssets.base,
        BabyFaceAssets.eyesBlueOpen,
        BabyFaceAssets.mouthWithTeeth,
        BabyFaceAssets.hairGirl,
      ],
    );
  });

  test('sleep boy — closed eyes, blue pacifier, zzz', () {
    expect(
      layers(boyYoung(), BabyFaceMode.sleep),
      [
        BabyFaceAssets.base,
        BabyFaceAssets.eyesClosed,
        BabyFaceAssets.mouthPacifierBlue,
        BabyFaceAssets.hairBoy,
        BabyFaceAssets.sleepZzz,
      ],
    );
  });

  test('sleep girl — closed eyes, red pacifier, zzz', () {
    expect(
      layers(girlYoung(), BabyFaceMode.sleep),
      [
        BabyFaceAssets.base,
        BabyFaceAssets.eyesClosed,
        BabyFaceAssets.mouthPacifierRed,
        BabyFaceAssets.hairGirl,
        BabyFaceAssets.sleepZzz,
      ],
    );
  });

  test('feeding left boy — tongue, gaze left', () {
    expect(
      layers(boyYoung(), BabyFaceMode.feedingLeft),
      [
        BabyFaceAssets.base,
        BabyFaceAssets.eyesBlueOpenLeft,
        BabyFaceAssets.mouthWithTongue,
        BabyFaceAssets.hairBoy,
      ],
    );
  });

  test('feeding left girl — tongue, gaze left', () {
    expect(
      layers(girlYoung(), BabyFaceMode.feedingLeft),
      [
        BabyFaceAssets.base,
        BabyFaceAssets.eyesBlueOpenLeft,
        BabyFaceAssets.mouthWithTongue,
        BabyFaceAssets.hairGirl,
      ],
    );
  });

  test('feeding right boy — tongue, gaze right', () {
    expect(
      layers(boyYoung(), BabyFaceMode.feedingRight),
      [
        BabyFaceAssets.base,
        BabyFaceAssets.eyesBlueOpenRight,
        BabyFaceAssets.mouthWithTongue,
        BabyFaceAssets.hairBoy,
      ],
    );
  });

  test('feeding right girl — tongue, gaze right', () {
    expect(
      layers(girlYoung(), BabyFaceMode.feedingRight),
      [
        BabyFaceAssets.base,
        BabyFaceAssets.eyesBlueOpenRight,
        BabyFaceAssets.mouthWithTongue,
        BabyFaceAssets.hairGirl,
      ],
    );
  });
}
