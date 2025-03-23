// Copyright (c) 2022. Alexandr Moroz

class MTError implements Exception {
  MTError(this.message, {this.description, this.detail});
  final String message;
  final String? description;
  final String? detail;

  @override
  String toString() => 'MTError $message $description $detail';
}

class MTOAuthError extends MTError {
  MTOAuthError(super.message, {super.description, super.detail});
}
