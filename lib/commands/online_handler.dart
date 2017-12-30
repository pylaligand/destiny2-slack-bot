// Copyright (c) 2017 P.Y. Laligand

import 'dart:async';

import 'package:destiny2_api/api.dart';
import 'package:heroku_slack_bot/heroku_slack_bot.dart';

import '../bot_config.dart';
import '../gaming_platform.dart';
import '../query_parameters.dart' as param;
import 'options.dart' as option;

/// A command handler showing which clan members are currently online.
class OnlineHandler extends SlackCommandHandler {
  final Logger _log = new Logger('OnlineHandler');

  @override
  Future<Response> handle(Request request) async {
    final params = request.context;
    final String userName = params[SLACK_USERNAME];
    final String text = params[SLACK_TEXT];
    _log.info('Online members requested by $userName');

    if (option.isHelp(text)) {
      _log.info('@$userName needs help');
      return createTextResponse('View online members', private: true);
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
    final members =
        await _getOnlineMembers(config.bungieApiKey, config.clans[platform].id);
    members.sort();
    _log.info('Found ${members.length} member(s) currently online');
    return createTextResponse('```${members.join('\n')}```');
  }

  Future<List<String>> _getOnlineMembers(String apiKey, int clanId) async {
    final client = new GroupV2Api(new ApiClient());
    client.apiClient.addDefaultHeader('X-API-Key', apiKey);
    final List<String> result = [];
    for (int currentPage = 1;; currentPage++) {
      final response =
          (await client.groupV2GetMembersOfGroup(currentPage, clanId)).response;
      response.results.forEach((GroupsV2GroupMember member) {
        if (member.isOnline) {
          result.add(member.destinyUserInfo.displayName);
        }
      });
      if (!response.hasMore) {
        break;
      }
    }
    client.apiClient.client.close();
    return result;
  }
}
