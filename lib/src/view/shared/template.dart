part of bridge.view;

class Template {

  String markup = '';

  Template([String this.markup]);

  String get headMarkup {

    Match match = new RegExp(r'<head>([^]*)</head>').firstMatch(markup);

    if (match == null) return '';

    return match[1];
  }

  String get bodyMarkup {

    Match match = new RegExp(r'<body>([^]*)</body>').firstMatch(markup);

    if (match == null) return '';

    return match[1];
  }

  String get templateMarkup {

    Match match = new RegExp(r'<template>([^]*)</template>').firstMatch(markup);

    if (match == null) return '';

    return match[1];
  }
}