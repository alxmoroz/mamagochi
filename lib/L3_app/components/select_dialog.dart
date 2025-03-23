// Copyright (c) 2023. Alexandr Moroz

import 'package:flutter/cupertino.dart';

import '../../L1_domain/entities/base_entity.dart';
import 'button.dart';
import 'circle.dart';
import 'colors.dart';
import 'constants.dart';
import 'dialog.dart';
import 'icons.dart';
import 'list_tile.dart';
import 'text.dart';
import 'toolbar.dart';

Future<T?> showMTSelectDialog<T extends RPersistable>(
  List<T> items,
  int? selectedId,
  String? pageTitle, {
  String? parentPageTitle,
  Widget? Function(BuildContext, T)? leadingBuilder,
  Widget Function(BuildContext, T)? valueBuilder,
  Widget? Function(BuildContext, T)? subtitleBuilder,
  final double? dividerIndent,
  final VoidCallback? onReset,
}) async =>
    await showMTDialog<T?>(
      _MTSelectDialog<T>(
        items,
        selectedId,
        pageTitle,
        parentPageTitle: parentPageTitle,
        leadingBuilder: leadingBuilder,
        valueBuilder: valueBuilder,
        subtitleBuilder: subtitleBuilder,
        dividerIndent: dividerIndent,
        onReset: onReset,
      ),
    );

class _MTSelectDialog<T extends RPersistable> extends StatelessWidget {
  const _MTSelectDialog(
    this.items,
    this.selectedId,
    this.pageTitle, {
    this.parentPageTitle,
    this.leadingBuilder,
    this.valueBuilder,
    this.subtitleBuilder,
    this.dividerIndent,
    this.onReset,
  });
  final List<T> items;
  final int? selectedId;
  final String? pageTitle;
  final String? parentPageTitle;
  final Widget? Function(BuildContext, T)? leadingBuilder;
  final Widget? Function(BuildContext, T)? valueBuilder;
  final Widget? Function(BuildContext, T)? subtitleBuilder;
  final double? dividerIndent;
  final VoidCallback? onReset;

  int get selectedIndex => items.indexWhere((i) => i.id == selectedId);
  int get itemCount => items.length;

  Widget itemBuilder(BuildContext context, int index) {
    final item = items[index];
    return MTListTile(
      leading: leadingBuilder != null ? leadingBuilder!(context, item) : null,
      middle: valueBuilder != null ? valueBuilder!(context, item) : BaseText('$item', maxLines: 2),
      subtitle: subtitleBuilder != null ? subtitleBuilder!(context, item) : null,
      trailing: selectedIndex == index ? const MTCircle(size: P2, color: mainColor) : null,
      bottomDivider: index < itemCount - 1,
      dividerIndent: dividerIndent,
      onTap: () => Navigator.of(context).pop(item),
    );
  }

  @override
  Widget build(BuildContext context) => MTDialog(
        topBar: MTTopBar(
          pageTitle: pageTitle,
          parentPageTitle: parentPageTitle,
          trailing: onReset != null && selectedId != null
              ? MTButton.icon(
                  const DeleteIcon(),
                  onTap: () {
                    Navigator.of(context).pop();
                    onReset!();
                  },
                  padding: const EdgeInsets.all(P2),
                )
              : null,
        ),
        body: ListView.builder(
          shrinkWrap: true,
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        ),
      );
}
