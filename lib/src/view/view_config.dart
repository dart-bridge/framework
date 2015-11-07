part of bridge.view;

class ViewConfig {
  final Config _config;

  ViewConfig(this._config);

  const _templates = 'view.templates';
  const _root = 'root';
  const _cache = 'cache';
  const _cacheDirectory = 'cache_directory';

  Map<String, String> get templates => _config(_templates, {
    _root: templatesRoot,
    _cache: templatesCache,
    _cacheDirectory: templatesCacheDirectory,
  });

  String get templatesRoot =>
      _config('$_templates.$_root', 'lib/templates');
  String get templatesCache =>
      _config('$_templates.$_cache', 'storage/.templates.dart');
  String get templatesCacheDirectory =>
      _config('$_templates.$_cacheDirectory', 'storage/.templates');
}
