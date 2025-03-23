// Copyright (c) 2022. Alexandr Moroz

import 'package:flutter/cupertino.dart';

extension MimeTypePresenter on String {
  bool get _isAudio => startsWith('audio');
  bool get _isVideo => startsWith('video');
  bool get _isImage => startsWith('image');
  bool get _isPDF => contains('application/pdf');
  bool get _isText => startsWith('text');
  bool get _isZip => contains('zip');

  IconData get iconData {
    return _isAudio
        ? CupertinoIcons.music_note_2
        : _isVideo
            ? CupertinoIcons.play_rectangle
            : _isImage
                ? CupertinoIcons.photo
                : _isPDF
                    ? CupertinoIcons.doc_richtext
                    : _isText
                        ? CupertinoIcons.doc_text
                        : _isZip
                            ? CupertinoIcons.archivebox
                            : CupertinoIcons.doc;
  }
}
