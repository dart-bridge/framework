import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/view.dart';
import 'dart:async';

Template mockTemplate = new Template('<head></head><body></body>');

class DocumentBuilderTest implements TestCase {
  DocumentBuilder builder;

  setUp() {
    builder = new DocumentBuilder(new MockTemplateRepository());
  }

  tearDown() {}

  @test
  it_builds_a_document_from_a_template() async {
    String document = await builder.fromTemplate(mockTemplate);
    expect(document, equals('<!DOCTYPE html><html><head></head><body></body></html>'));
  }

  @test
  it_builds_a_document_from_a_template_templateName() async {
    String document = await builder.fromTemplateName('templateName');
    expect(document, equals('<!DOCTYPE html><html><head></head><body></body></html>'));
  }
}

class MockTemplateRepository implements TemplateRepository {
  Future<Template> find(String templateName) async {
    return mockTemplate;
  }
}
