// Copyright (c) 2024. Alexandr Moroz

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'circle.dart';
import 'colors.dart';
import 'constants.dart';
import 'painters.dart';

class MTIcon extends StatelessWidget {
  const MTIcon(this.iconData, {super.key, this.color = mainColor, this.size = P4, this.solid = false, this.circled = false});

  final IconData? iconData;
  final Color color;
  final double size;
  final bool solid;
  final bool circled;

  @override
  Widget build(BuildContext context) {
    final rColor = color.resolve(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        if (circled == true)
          MTCircle(
            color: solid == true ? rColor.withAlpha(30) : Colors.transparent,
            size: size,
            // от 1 до 3 пикселей ширина обводки, в зависимости от размера иконки
            border: Border.all(color: rColor, width: min(3, max(1, size / 18))),
          ),
        if (iconData != null) Icon(iconData, color: rColor, size: size - (circled == true ? (sqrt(size * size / 8)) : 0)),
      ],
    );
  }
}

class AnalyticsIcon extends MTIcon {
  const AnalyticsIcon({super.key, super.color, super.size = DEF_TAPPABLE_ICON_SIZE, super.circled}) : super(CupertinoIcons.chart_bar);
}

class AttachmentIcon extends MTIcon {
  const AttachmentIcon({super.key, super.color, super.size = DEF_TAPPABLE_ICON_SIZE, super.circled}) : super(CupertinoIcons.paperclip);
}

class BankCardIcon extends MTIcon {
  const BankCardIcon({super.key, super.color, super.size = DEF_TAPPABLE_ICON_SIZE}) : super(CupertinoIcons.creditcard);
}

class BellIcon extends MTIcon {
  const BellIcon({super.key, super.color, super.size = DEF_TAPPABLE_ICON_SIZE, this.hasUnread = false}) : super(CupertinoIcons.bell);
  final bool hasUnread;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        MTIcon(iconData, color: color, size: size),
        if (hasUnread) MTCircle(size: size * 0.42, color: color),
      ],
    );
  }
}

class CalendarIcon extends MTIcon {
  const CalendarIcon({super.key, super.color, super.size = DEF_TAPPABLE_ICON_SIZE}) : super(CupertinoIcons.calendar);
}

class CaretIcon extends StatelessWidget {
  const CaretIcon({super.key, this.up = false, this.color, required this.size});
  final bool up;
  final Size size;
  final Color? color;

  @override
  Widget build(BuildContext context) => RotatedBox(
    quarterTurns: up ? 0 : 2,
    child: CustomPaint(
      painter: TrianglePainter(color: (color ?? f2Color).resolve(context)),
      child: SizedBox(height: size.height, width: size.width),
    ),
  );
}

class CheckboxIcon extends MTIcon {
  const CheckboxIcon(this.checked, {super.key, super.color, super.size = P4, super.solid})
    : super(checked ? (solid == true ? CupertinoIcons.checkmark_square_fill : CupertinoIcons.checkmark_square) : CupertinoIcons.square);
  final bool checked;
}

class ChevronIcon extends MTIcon {
  const ChevronIcon({super.key, super.color, super.size = P3, this.left = false})
    : super(left ? CupertinoIcons.chevron_left : CupertinoIcons.chevron_right);
  final bool left;
}

class ChevronCircleIcon extends MTIcon {
  const ChevronCircleIcon({super.key, super.color, super.size = DEF_TAPPABLE_ICON_SIZE, required this.left})
    : super(left ? CupertinoIcons.chevron_left_circle : CupertinoIcons.chevron_right_circle);
  final bool left;
}

class ChevronCaretIcon extends StatelessWidget {
  const ChevronCaretIcon({super.key, this.left = false, this.color = mainColor, required this.size});
  final bool left;
  final Size size;
  final Color? color;

  @override
  Widget build(BuildContext context) => RotatedBox(
    quarterTurns: left ? 3 : 1,
    child: CustomPaint(
      painter: TrianglePainter(color: (color ?? f2Color).resolve(context)),
      child: SizedBox(height: size.height, width: size.width),
    ),
  );
}

class CloseIcon extends MTIcon {
  const CloseIcon({super.key, super.color, super.size = P4}) : super(CupertinoIcons.clear);
}

class CopyIcon extends MTIcon {
  const CopyIcon({super.key, super.color, super.size = P4}) : super(CupertinoIcons.doc_on_clipboard);
}

class DeleteIcon extends MTIcon {
  const DeleteIcon({super.key, super.color = dangerColor, super.size = P4, super.circled}) : super(CupertinoIcons.trash);
}

class DescriptionIcon extends MTIcon {
  const DescriptionIcon({super.key, super.color, super.size = DEF_TAPPABLE_ICON_SIZE}) : super(CupertinoIcons.text_justifyleft);
}

class DocumentIcon extends MTIcon {
  const DocumentIcon({super.key, super.color, super.size = DEF_TAPPABLE_ICON_SIZE}) : super(CupertinoIcons.doc_plaintext);
}

class DoneIcon extends MTIcon {
  const DoneIcon(this.done, {super.key, super.color, super.solid, super.size = P4, super.circled = true})
    : super(done ? CupertinoIcons.checkmark : null);
  final bool done;
}

class DropdownIcon extends MTIcon {
  const DropdownIcon({super.key, super.color, super.size}) : super(CupertinoIcons.chevron_up_chevron_down);
}

class EditIcon extends MTIcon {
  const EditIcon({super.key, super.color, super.size}) : super(Icons.edit);
}

class ErrorIcon extends MTIcon {
  const ErrorIcon({super.key, super.color = dangerColor, super.size = P3}) : super(CupertinoIcons.exclamationmark_circle);
}

class EyeIcon extends MTIcon {
  const EyeIcon({super.key, this.open = true, super.color = f2Color, super.size}) : super(open ? CupertinoIcons.eye : CupertinoIcons.eye_slash);
  final bool open;
}

class FeedbackIcon extends MTIcon {
  const FeedbackIcon({super.key, super.color, super.size = DEF_TAPPABLE_ICON_SIZE}) : super(CupertinoIcons.hand_thumbsup);
}

class FilterIcon extends MTIcon {
  const FilterIcon({super.key, super.color, super.size = P3}) : super(CupertinoIcons.line_horizontal_3_decrease);
}

class HomeIcon extends MTIcon {
  const HomeIcon({super.key, super.color, super.size = DEF_TAPPABLE_ICON_SIZE}) : super(CupertinoIcons.house_alt);
}

class InfoIcon extends MTIcon {
  const InfoIcon({super.key, super.color = mainColor, super.size = P5}) : super(CupertinoIcons.info);
}

class LinkOutIcon extends MTIcon {
  const LinkOutIcon({super.key, super.color, super.size = P3}) : super(CupertinoIcons.arrow_up_right);
}

class ListIcon extends MTIcon {
  const ListIcon({super.key, super.color, super.size, super.circled}) : super(CupertinoIcons.list_dash);
}

class MailIcon extends MTIcon {
  const MailIcon({super.key, super.color, super.size = DEF_TAPPABLE_ICON_SIZE, super.circled}) : super(CupertinoIcons.envelope);
}

class MenuIcon extends MTIcon {
  const MenuIcon({super.key, super.color, super.size, super.circled}) : super(CupertinoIcons.ellipsis_vertical);
}

class MenuHorizontalIcon extends MTIcon {
  const MenuHorizontalIcon({super.key, super.color, super.size, super.circled}) : super(CupertinoIcons.ellipsis);
}

class MoveLeftIcon extends MTIcon {
  const MoveLeftIcon({super.key, super.color, super.size = DEF_TAPPABLE_ICON_SIZE}) : super(CupertinoIcons.arrow_left);
}

class MoveRightIcon extends MTIcon {
  const MoveRightIcon({super.key, super.color, super.size = DEF_TAPPABLE_ICON_SIZE}) : super(CupertinoIcons.arrow_right);
}

class PlusIcon extends MTIcon {
  const PlusIcon({super.key, super.color, super.size = P4, super.circled}) : super(CupertinoIcons.plus);
}

class PrivacyIcon extends MTIcon {
  const PrivacyIcon({super.key, super.color, super.size = DEF_TAPPABLE_ICON_SIZE}) : super(CupertinoIcons.lock_shield);
}

class RepeatIcon extends MTIcon {
  const RepeatIcon({super.key, super.color, super.size = DEF_TAPPABLE_ICON_SIZE}) : super(CupertinoIcons.repeat);
}

class QuestionIcon extends MTIcon {
  const QuestionIcon({super.key, super.color, super.size = DEF_TAPPABLE_ICON_SIZE}) : super(CupertinoIcons.question_circle);
}

class ReleaseNotesIcon extends MTIcon {
  const ReleaseNotesIcon({super.key, super.color, super.size = DEF_TAPPABLE_ICON_SIZE}) : super(CupertinoIcons.time);
}

class SettingsIcon extends MTIcon {
  const SettingsIcon({super.key, super.color, super.circled, super.size = DEF_TAPPABLE_ICON_SIZE}) : super(CupertinoIcons.slider_horizontal_3);
}

class ShareIcon extends MTIcon {
  const ShareIcon({super.key, super.color, super.size}) : super(CupertinoIcons.square_arrow_up);
}

class StarIcon extends MTIcon {
  const StarIcon({super.key, super.color, super.size = DEF_TAPPABLE_ICON_SIZE}) : super(CupertinoIcons.star);
}

class TasksIcon extends MTIcon {
  const TasksIcon({super.key, super.color, super.size = DEF_TAPPABLE_ICON_SIZE}) : super(CupertinoIcons.checkmark, solid: false, circled: true);
}

class WebIcon extends MTIcon {
  const WebIcon({super.key, super.color, super.size = DEF_TAPPABLE_ICON_SIZE}) : super(CupertinoIcons.globe);
}
