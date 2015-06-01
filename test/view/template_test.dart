import 'package:testcase/testcase.dart';
export 'package:testcase/init.dart';
import 'package:bridge/view.dart';

class TemplateTest implements TestCase {

  Template template;

  setUp() {
    template = new Template('''
    <head>headContents</head>
    <body>bodyContents</body>
    <template>templateContents</template>
    ''');
  }

  tearDown() {}

  @test
  it_can_find_the_body_tag_of_markup() async {
    expect(await template.bodyMarkup, equals('bodyContents'));
  }

  @test
  it_can_find_the_head_tag_of_markup() async {
    expect(await template.headMarkup, equals('headContents'));
  }

  @test
  it_can_find_the_template_tag_of_markup() async {
    expect(await template.templateMarkup, equals('templateContents'));
  }

  @test
  it_takes_a_callback_function_that_requests_another_template() async {
    template.markup = '<head>merged-{{> tmpl}}</head>';
    var callbackRequest, callbackCount = 0;
    template.templateProvider((String request) {
      callbackRequest = request;
      callbackCount++;
      return new Template('<head>content</head>');
    });
    expect(await template.headMarkup, equals('merged-content'));
    expect(callbackRequest, equals('tmpl'));
    expect(callbackCount, equals(1));
  }

  @test
  it_can_inject_data_into_the_template() async {
    template.markup = '<head>{{key1}}</head><body>{{key2}}</body>';
    template.data.addAll({
      'key1': 'value1',
      'key2': 'value2',
    });
    expect(await template.bodyMarkup, equals('value2'));
    expect(await template.headMarkup, equals('value1'));
  }
}
