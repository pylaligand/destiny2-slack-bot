// Copyright (c) 2017 P.Y. Laligand

import 'package:heroku_slack_bot/heroku_slack_bot.dart';
import 'package:logging/logging.dart';
import 'package:timezone/standalone.dart';

import '../lib/environment.dart' as env;
import '../lib/commands/clan_handler.dart';
import '../lib/commands/lfg_handler.dart';
import '../lib/commands/online_handler.dart';
import '../lib/commands/roster_handler.dart';
import '../lib/middleware/config_provider.dart';

class Config extends ServerConfig {
  @override
  String get name => 'Destiny2SlackBot';

  @override
  List<String> get environmentVariables => env.ALL;

  @override
  Map<String, SlackCommandHandler> loadCommands(
          Map<String, String> environment) =>
      {
        'clan': new ClanHandler(),
        'lfg': new LfgHandler(),
        'online': new OnlineHandler(),
        'roster': new RosterHandler(),
      };

  @override
  List<Middleware> loadMiddleware(Map<String, String> environment) => [
        ConfigProvider.get(environment[env.BOT_CONFIG]),
      ];

  @override
  List<String> get stallingMessages => [
        'Kindly don\'t delete this query...',
        'Contacting Destiny servers... still...',
        'The Cryptarchs are on it...',
      ];

  @override
  String get errorMessage =>
      'The line between working and not working is so very thin.\n' +
      'It looks like this bot has crossed that line...\n' +
      'Please refer to the Hacker Vanguard!';
}

main() async {
  // Disable Dartson's annoying logs.
  hierarchicalLoggingEnabled = true;
  new Logger('dartson')..level = Level.OFF;

  await initializeTimeZone();

  await runServer(new Config());
}
