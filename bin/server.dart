// Copyright (c) 2017 P.Y. Laligand

import 'package:heroku_slack_bot/heroku_slack_bot.dart';

import '../lib/commands/online_handler.dart';

class Config extends ServerConfig {
  @override
  String get name => 'Destiny2SlackBot';

  @override
  Map<String, SlackCommandHandler> loadCommands(Map<String, String> env) => {
        'online': new OnlineHandler(),
      };

  @override
  List<String> get stallingMessages => [
        'Kindly delete yourself',
      ];
}

main() async {
  await runServer(new Config());
}
