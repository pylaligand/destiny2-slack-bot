// Copyright (c) 2017 P.Y. Laligand

import 'dart:async';

import 'package:destiny2_api/api.dart';
import 'package:heroku_slack_bot/heroku_slack_bot.dart';

import '../bot_config.dart';
import '../gaming_platform.dart';
import '../query_parameters.dart' as param;
import 'options.dart' as option;

/// A command handler showing which clan members are currently online.
class RosterHandler extends SlackCommandHandler {
  final Logger _log = new Logger('RosterHandler');

  @override
  Future<Response> handle(Request request) async {
    final params = request.context;
    final String userName = params[SLACK_USERNAME];
    final String text = params[SLACK_TEXT];
    _log.info('Clan roster requested by $userName');
    if (option.isHelp(text)) {
      _log.info('@$userName needs help');
      return createTextResponse('View clan rosters', private: true);
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
    final apiClient = new ApiClient()
      ..addDefaultHeader('X-API-Key', config.bungieApiKey);
    final members = await _getAllMembers(apiClient, config.clans[platform].id);
    final nPlaying = members.length;
    _log.info('Found $nPlaying member(s) in the clan');
    final nonD2Members = <String>[];
    final inactiveMembers = <String>[];
    final now = new DateTime.now();
    for (GroupsV2GroupMember member in members) {
      final lastPlayed = await _getLastTimePlayed(apiClient, member);
      if (lastPlayed == null) {
        nonD2Members.add(member.destinyUserInfo.displayName);
        continue;
      }
      if (lastPlayed.isBefore(now.subtract(const Duration(days: 30 * 6)))) {
        inactiveMembers.add(member.destinyUserInfo.displayName);
      }
    }
    apiClient.client.close();
    final nNotPlaying = nonD2Members.length;
    final nInactive = inactiveMembers.length;
    _log.info('Found $nNotPlaying non-playing member(s)');
    _log.info('Found $nInactive inactive member(s)');
    nonD2Members.sort();
    inactiveMembers.sort();
    List<String> lines = <String>[];
    lines.add('Found $nPlaying members in the clan.');
    if (nonD2Members.isEmpty && inactiveMembers.isEmpty) {
      lines.add('All $nPlaying members have been active in the last 6 months!');
    } else {
      if (nonD2Members.isNotEmpty) {
        lines.add('$nNotPlaying members haven\'t played D2 yet:');
        lines.add('```');
        lines.addAll(nonD2Members);
        lines.add('```');
      }
      if (inactiveMembers.isNotEmpty) {
        lines.add('$nInactive haven\'t played in the last 6 months:');
        lines.add('```');
        lines.addAll(inactiveMembers);
        lines.add('```');
      }
    }
    return createTextResponse(lines.join('\n'));
  }

  Future<DateTime> _getLastTimePlayed(
      ApiClient apiClient, GroupsV2GroupMember member) async {
    final client = new Destiny2Api(apiClient);
    final response = await client.destiny2GetProfile(
        member.destinyUserInfo.membershipId,
        member.destinyUserInfo.membershipType.value,
        components: [DestinyDestinyComponentType.profiles]);
    if (response.errorCode != ExceptionsPlatformErrorCodes.success) {
      return null;
    }
    return response.response.profile.data.dateLastPlayed;
  }

  Future<List<GroupsV2GroupMember>> _getAllMembers(
      ApiClient apiClient, int clanId) async {
    final client = new GroupV2Api(apiClient);
    final List<GroupsV2GroupMember> result = [];
    for (int currentPage = 1;; currentPage++) {
      final response =
          (await client.groupV2GetMembersOfGroup(currentPage, clanId)).response;
      result.addAll(response.results);
      if (!response.hasMore) {
        break;
      }
    }
    return result;
  }
}
