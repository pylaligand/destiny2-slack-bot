// Copyright (c) 2017 P.Y. Laligand

import 'dart:async';

import 'package:heroku_slack_bot/heroku_slack_bot.dart';
import 'package:logging/logging.dart';
import 'package:timezone/standalone.dart';

import '../gaming_platform.dart';

/// A participant in a game.
class Player {
  final String gamertag;
  final bool inReserve;

  const Player(this.gamertag, this.inReserve);
}

/// A gaming session.
class Game {
  final String id;
  final String groupId;
  final String title;
  final String description;
  final String creator;
  final TZDateTime startDate;
  final GamingPlatform platform;

  /// Desired team size.
  final int teamSize;

  /// Current team size.
  /// Might be greater than the size of [players] if unregistered players were
  /// declared.
  final int playerCount;
  final List<Player> players;

  const Game(
      this.id,
      this.groupId,
      this.title,
      this.description,
      this.creator,
      this.startDate,
      this.platform,
      this.teamSize,
      this.playerCount,
      this.players);

  /// Returns the URL of the gaming session.
  String get url => 'https://www.the100.io/gaming_sessions/$id';

  String get platformLabel {
    switch (platform) {
      case GamingPlatform.pc:
        return 'PC';
      case GamingPlatform.xbox:
        return 'XB';
      default:
        return 'PS';
    }
  }

  @override
  String toString() => '$creator | $title | $startDate';

  @override
  bool operator ==(Object other) => other is Game && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Client for the the100.io API.
class TheHundredClient {
  final _log = new Logger('TheHundredClient');
  final String _authToken;
  final String _groupId;
  final Location _location;

  TheHundredClient(this._authToken, this._groupId)
      : _location = getLocation('America/Los_Angeles');

  static const _BASE = 'https://www.the100.io/api/v1';

  /// Returns the URL of the game creation page for the group.
  String get gameCreationUrl =>
      'https://www.the100.io/gaming_sessions/new?group_id=$_groupId';

  /// Returns the URL of the admin interface for the group.
  String get adminUrl => 'https://www.the100.io/groups/$_groupId/edit';

  /// Returns the location used to set the timezone on dates.
  Location get location => _location;

  /// Returns the list of all upcoming games in the group.
  Future<List<Game>> getAllGames() async {
    final url = '$_BASE/groups/$_groupId/gaming_sessions';
    final json = await _getJson(url);
    return json
        .map((game) => new Game(
            game['id'].toString(),
            _groupId,
            game['category'],
            game['name'],
            game['creator_gamertag'],
            TZDateTime.parse(_location, game['start_time']),
            _parsePlatform(game['platform']),
            game['team_size'],
            game['primary_users_count'],
            game['confirmed_sessions']
                .map((player) => new Player(
                    player['user']['gamertag'], player['reserve_spot']))
                .toList()))
        .toList();
  }

  /// Returns the game with the given id, or |null| if none could be found.
  Future<Game> getGame(String id) async => (await getAllGames())
      .firstWhere((game) => game.id == id, orElse: () => null);

  /// Returns the number of pending users in the group.
  Future<int> getPendingUsers() async {
    final url = '$_BASE/groups/$_groupId';
    final json = await _getJson(url);
    final List memberships = json['memberships'];
    return memberships
        .where((user) => !user['approved'] && !user['blocked'])
        .length;
  }

  /// Returns the response to a URL request as parsed JSON, or null if the
  /// request failed.
  Future<dynamic> _getJson(String url) async {
    return getJson(url, _log,
        headers: {'Authorization': 'Token token="$_authToken"'});
  }

  GamingPlatform _parsePlatform(String platform) {
    switch (platform) {
      case 'pc':
        return GamingPlatform.pc;
      case 'ps4':
        return GamingPlatform.playstation;
      default:
        return GamingPlatform.xbox;
    }
  }
}
