// Copyright (c) 2017 P.Y. Laligand

import 'package:dartson/dartson.dart';

/// Stores the bot's configuration.
@Entity()
class BotConfig {
  @Property()
  String bungieApiKey;

  @Property()
  Services services;

  @Property()
  Map<String, Clan> clans = {};
}

/// Service configurations.
@Entity()
class Services {
  @Property()
  TheHundredService the100;
}

/// Configuration for the100.io.
@Entity()
class TheHundredService {
  @Property()
  String authToken;

  @Property()
  String groupId;
}

/// Description of a clan.
@Entity()
class Clan {
  @Property()
  int id;

  @Property()
  String leader;

  String get url => 'https://www.bungie.net/en/ClanV2?groupid=$id';
}
