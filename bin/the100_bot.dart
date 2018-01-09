// Copyright (c) 2018 P.Y. Laligand

import 'package:heroku_slack_bot/heroku_slack_bot.dart';
import 'package:logging/logging.dart';
import 'package:timezone/standalone.dart';

import '../lib/bot_config.dart';
import '../lib/environment.dart' as env;
import '../lib/clients/the_hundred_client.dart';

class TheHundredTask extends BackgroundTask {
  final Logger _log = new Logger('TheHundredTask');

  @override
  List<String> get environmentVariables => env.ALL;

  @override
  execute() async {
    final configJson = environment[env.BOT_CONFIG];
    final BotConfig config = loadBotConfig(configJson);
    final TheHundredService serviceConfig = config.services.the100;
    if (serviceConfig == null) {
      _log.info('the100.io integration not set up, aborting.');
      return;
    }

    final TheHundredClient client =
        new TheHundredClient(serviceConfig.authToken, serviceConfig.groupId);
    final int nPending = await client.getPendingUsers();
    _log.info('Found $nPending user(s).');
    if (nPending == 0) {
      return;
    }

    final admin = serviceConfig.admin;
    _log.info('Notifying $admin');
    slackBotClient.sendMessage(
      'Heads up: $nPending user(s) awaiting approval on <${client.adminUrl}|the100.io>.',
      admin,
    );
  }
}

main(List<String> args) async {
  // Disable Dartson's annoying logs.
  hierarchicalLoggingEnabled = true;
  new Logger('dartson')..level = Level.OFF;

  await initializeTimeZone();

  await new TheHundredTask().run();
}
