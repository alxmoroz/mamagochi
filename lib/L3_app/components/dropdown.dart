// Copyright (c) 2022. Alexandr Moroz

import 'package:flutter/material.dart';

import '../../L1_domain/entities/base_entity.dart';
import 'colors.dart';
import 'constants.dart';
import 'icons.dart';
import 'text.dart';
import 'text_field.dart';

class MTDropdown<T extends RPersistable> extends StatelessWidget {
  const MTDropdown({
    super.key,
    required this.label,
    this.helper,
    this.onChanged,
    this.value,
    this.ddItems,
    this.items,
    this.margin,
  }) : assert((ddItems == null && items != null) || (ddItems != null && items == null));

  final Function(int?)? onChanged;
  final int? value;
  final List<T>? items;
  final List<DropdownMenuItem<int>>? ddItems;
  final String label;
  final String? helper;
  final EdgeInsets? margin;

  List<DropdownMenuItem<int>> get _ddItems =>
      ddItems ??
      [
        for (final item in items!)
          DropdownMenuItem<int>(
            value: item.id,
            child: BaseText('$item'),
          ),
      ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      height: P10,
      alignment: Alignment.centerLeft,
      child: DropdownButtonFormField<int>(
        dropdownColor: b3Color.resolve(context),
        focusColor: b3Color.resolve(context),
        isDense: true,
        decoration: tfDecoration(context, label: label, helper: helper, readOnly: true),
        icon: const DropdownIcon(),
        items: _ddItems,
        isExpanded: true,
        value: value,
        onChanged: onChanged,
        borderRadius: BorderRadius.circular(DEF_BORDER_RADIUS),
      ),
    );
  }
}
