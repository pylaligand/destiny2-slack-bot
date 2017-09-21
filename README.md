# Destiny 2 Slack bot

This bot is built using the [Dart Heroku Slack bot package](pylaligand/heroku-slack-bot).
It best serves Titans.

# Configuration

On top of the environment variables needed by Slack, this bot defines a new
environment variable containing the entire Destiny-specific configuration this
bot requires: `BOT_CONFIG`.

In order to provision this (mandatory) variable, start by creating a JSON file,
e.g. `config.json`, matching [this schema](data/config_schema.json). The
contents of this file should then be written to the environment variable with:
```
# For deployment on Heroku
heroku config:set BOT_CONFIG="$(< path/to/config.json)"

# For local testing
export BOT_CONFIG="$(< path/to/config.json)"
```

In order to validate your configuration file, run:
```
dart tools/validate_config.dart path/to/config.json
```
