// Copyright (c) 2017 P.Y. Laligand

import 'dart:convert';
import 'dart:io';

import 'package:json_schema/json_schema.dart';
import 'package:path/path.dart' as path;

main(List<String> args) async {
  if (args.isEmpty) {
    print('Usage: validate_config <path to config>');
    exit(1);
  }
  final schemaFile = path.join(path.dirname(Platform.script.toFilePath()), '..',
      'data', 'config_schema.json');
  final schema = await Schema.createSchemaFromUrl(schemaFile);
  final config = JSON.decode(await new File(args[0]).readAsString());
  bool isValid = schema.validate(config);
  print(isValid
      ? 'Vexcellent, this configuration is correct!'
      : 'What the Hive, this configuration is not valid!');
  exit(isValid ? 1 : 0);
}
