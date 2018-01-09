// Copyright (c) 2017 P.Y. Laligand

import 'package:heroku_slack_bot/heroku_slack_bot.dart';

import '../bot_config.dart';
import '../query_parameters.dart' as param;

/// Injects the bot configuration into the query pipeline.
class ConfigProvider {
  static Middleware get(String configJson) {
    final config = loadBotConfig(configJson);
    return (Handler handler) =>
        (Request request) => handler(request.change(context: {
              param.CONFIG: config,
            }));
  }
}
