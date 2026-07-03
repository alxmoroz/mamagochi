abstract final class BabyFaceAssets {
  static const prefix = 'baby_face/';

  static const base = '${prefix}baby_face';
  static const hairBoy = '${prefix}hair_boy';
  static const hairGirl = '${prefix}hair_girl';
  static const eyesBlueOpen = '${prefix}eyes_blue_open';
  static const eyesClosed = '${prefix}eyes_closed';
  static const eyesBlueOpenLeft = '${prefix}eyes_blue_open_left';
  static const eyesBlueOpenRight = '${prefix}eyes_blue_open_right';
  static const mouthPacifierBlue = '${prefix}mouth_pacifier_blue';
  static const mouthPacifierRed = '${prefix}mouth_pacifier_red';
  static const mouthWithTeeth = '${prefix}mouth_with_teeth';
  static const mouthWithTongue = '${prefix}mouth_with_tongue';
  static const sleepZzz = '${prefix}sleep_zzz';

  static String assetPath(String name) => 'assets/images/$name.svg';
}
