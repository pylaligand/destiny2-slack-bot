// Copyright (c) 2017 P.Y. Laligand

import 'dart:async';

import 'package:heroku_slack_bot/heroku_slack_bot.dart';
import 'package:timezone/timezone.dart';

import '../bot_config.dart';
import '../clients/the_hundred_client.dart';
import '../game_format.dart';
import '../gaming_platform.dart';
import '../query_parameters.dart' as param;
import 'options.dart' as option;

enum _Platform { xbox, pc, playstation, all }

const _COLORS = const ['#4285f4', '#f4b400', '#0f9d58', '#db4437'];

/// Lists LFG games from the100.io.
class LfgHandler extends SlackCommandHandler {
  final Logger _log = new Logger('LfgHandler');

  @override
  Future<Response> handle(Request request) async {
    final params = request.context;
    final SlackClient slackClient = params[SLACK_CLIENT];
    final String text = params[SLACK_TEXT];
    final String userName = params[SLACK_USERNAME];
    _log.info('LFG listings requested by $userName');

    final BotConfig config = params[param.CONFIG];
    final TheHundredService serviceConfig = config.services.the100;
    if (serviceConfig == null) {
      return createTextResponse('Sorry, LFG game listings are not supported!');
    }
    final TheHundredClient theHundredClient =
        new TheHundredClient(serviceConfig.authToken, serviceConfig.groupId);

    if (option.isHelp(text)) {
      _log.info('@$userName needs help');
      return createTextResponse('View upcoming gaming sessions', private: true);
    }

    final optionList = text.split(new RegExp(r'\s+'));
    final shouldFilter = optionList.last == 'filter';
    final platform = optionList.first;
    _log.info('@$userName looking up games on platform $platform');
    final games =
        _filterByPlatform(await theHundredClient.getAllGames(), platform);
    _log.info('${games.length} game(s)');
    games.forEach(_log.info);
    if (games.isEmpty) {
      return createErrorAttachment(
          'No game scheduled, wanna <${theHundredClient.gameCreationUrl}|create one>?');
    }

    final userId = params[SLACK_USER_ID];
    final timezone = await slackClient.getUserTimezone(userId);
    final location =
        timezone != null ? getLocation(timezone) : theHundredClient.location;
    final now = new TZDateTime.now(location);
    final attachments = new Iterable.generate(games.length)
        .map((index) => _generateAttachment(games, index, now, shouldFilter))
        .toList();
    return createAttachmentsResponse(attachments);
  }

  /// Filters games by platform based on user input.
  List<Game> _filterByPlatform(List<Game> games, String option) {
    final filterGames = (GamingPlatform gamingPlatform) {
      _log.info('Focusing on $gamingPlatform');
      return games.where((game) => game.platform == gamingPlatform).toList();
    };
    switch (stringToGamingPlatform(option)) {
      case GamingPlatform.xbox:
        return filterGames(GamingPlatform.xbox);
      case GamingPlatform.pc:
        return filterGames(GamingPlatform.pc);
      case GamingPlatform.playstation:
        return filterGames(GamingPlatform.playstation);
      default:
        return games;
    }
  }

  /// Generates an attachment representing a game.
  Map _generateAttachment(
          List<Game> games, int index, TZDateTime now, bool shouldFilter) =>
      generateGameAttachment(
        games[index],
        now,
        color: _COLORS[index % _COLORS.length],
        withActions: shouldFilter,
        summary: shouldFilter,
      );
}
