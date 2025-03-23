// Copyright (c) 2024. Alexandr Moroz

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'platform.dart';

const _STAGE_PROD = 'prod';
String get _stage => dotenv.maybeGet('STAGE') ?? _STAGE_PROD;
bool get _isProd => _stage == _STAGE_PROD;
String get apiKey => dotenv.maybeGet('API_KEY') ?? '';

Uri get apiUri => Uri.parse(dotenv.maybeGet('API_HOST') ?? 'https://mamagochi.ru').replace(path: 'api');

Uri get _frontendUri => (isWeb ? Uri.base : apiUri).replace(path: '');
Uri get appleOauthRedirectUri => apiUri.replace(path: '');
Uri get yandexOauthRedirectUri => _frontendUri.replace(path: 'yandex_oauth');

String get visibleApiHost => _isProd ? '' : apiUri.host;
