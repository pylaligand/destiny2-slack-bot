// Copyright (c) 2017 P.Y. Laligand

import 'package:dartson/dartson.dart';

/// Stores the bot's configuration.
@Entity()
class BotConfig {
  @Property()
  String apiKey;

  @Property()
  Map<String, int> clanIds = {};
}
