// ignore_for_file: avoid_print

import 'dart:io';

import 'package:args/args.dart';

import 'src/templates.dart';

final _argParser = ArgParser()
  ..addFlag('help', negatable: false)
  ..addMultiOption(
    'templates',
    allowed: ['reactive_forms', 'bloc', 'riverpod', 'riverpod_mutation'],
    help: 'List of templates from which to generate support files',
  )
  ..addOption('output', mandatory: true, help: 'The path to the output folder');

void main(List<String> args) {
  final ArgResults argResults;
  final List<String> templates;
  final String? output;
  try {
    try {
      argResults = _argParser.parse(args);
      templates = argResults.multiOption('templates');
      output = argResults.option('output');
    } on ArgumentError catch (error) {
      throw ArgParserException(error.message);
    }
    if (argResults.flag('help')) {
      print('');
      print(_usageTitle);
      print(_argParser.usage);
      return;
    }

    _run(templates: templates, output: output!);
  } on ArgParserException catch (exception) {
    print('');
    print(exception.message);
    print('');
    print(_usageTitle);
    print(_argParser.usage);
  }
}

void _run({required List<String> templates, required String output}) {
  if (templates.isEmpty) {
    throw ArgParserException('Define at least one template by --templates=<template>.');
  }

  final outputDirectory = Directory(output);
  if (!outputDirectory.existsSync()) outputDirectory.createSync(recursive: true);

  for (final template in templates) {
    final (name, content) = switch (template) {
      'reactive_forms' => Templates.reactiveFormsSources,
      'bloc' => Templates.blocSource,
      'riverpod' => Templates.riverpodSourceConsumer,
      'riverpod_mutation' => Templates.riverpodMutation,
      _ => throw UnimplementedError(),
    };

    final outputFile = File('${outputDirectory.path}/$name');
    outputFile.writeAsStringSync(content);
  }
}

const String _usageTitle =
    'Usage: dart run rivertion --templates=reactive_forms,riverpod --output=lib/generated/rivertion';
