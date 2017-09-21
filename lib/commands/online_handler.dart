// Copyright (c) 2017 P.Y. Laligand

import 'dart:async';

import 'package:heroku_slack_bot/heroku_slack_bot.dart';

class OnlineHandler extends SlackCommandHandler {
  final Logger _log = new Logger('OnlineHandler');

  @override
  Future<Response> handle(Request request) async {
    final params = request.context;
    final String userName = params[SLACK_USERNAME];
    _log.info('Online members requested by $userName');
    return createTextResponse('sup?');
  }
}
