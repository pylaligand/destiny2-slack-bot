// Copyright (c) 2017 P.Y. Laligand

import 'package:dartson/dartson.dart';

/// Stores the bot's configuration.
@Entity()
class BotConfig {
  @Property()
  String apiKey;

  @Property()
  Map<String, Clan> clans = {};
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
