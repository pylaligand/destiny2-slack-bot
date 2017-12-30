// Copyright (c) 2017 P.Y. Laligand

import 'dart:async';

import 'package:heroku_slack_bot/heroku_slack_bot.dart';

import '../bot_config.dart';
import '../gaming_platform.dart';
import '../query_parameters.dart' as param;
import 'options.dart' as option;

/// A command handler showing details about in-game clans.
class ClanHandler extends SlackCommandHandler {
  final Logger _log = new Logger('ClanHandler');

  @override
  Future<Response> handle(Request request) async {
    final params = request.context;
    final String userName = params[SLACK_USERNAME];
    final String text = params[SLACK_TEXT];
    _log.info('Clan details requested by $userName');

    if (option.isHelp(text)) {
      _log.info('@$userName needs help');
      return createTextResponse('View clan details', private: true);
    }

    final String platform = text;
    if (!isValidGamingPlatform(platform)) {
      return createTextResponse('Sorry, I do not know the requested platform!');
    }
    final BotConfig config = params[param.CONFIG];
    if (!config.clans.containsKey(platform)) {
      return createTextResponse(
          'Sorry, the clan for this platform does not exist!');
    }
    _log.info('Sending details for $platform');
    final clan = config.clans[platform];
    return createTextResponse(
        'Apply on <${clan.url}|bungie.net> and ping <@${clan.leader}>');
  }
}
