part of bridge.view;

class MarkdownPreProcessor implements TemplatePreProcessor {
  Future<String> process(String template) async {
    return markdown.markdownToHtml(template == null ? '' : template);
  }
}
