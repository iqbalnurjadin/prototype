# encoding: UTF-8
Encoding.default_internal = 'UTF-8'
require 'yaml'
require 'psych'
YAML::ENGINE.yamler = 'psych'

require 'json'
require 'time'
require 'cgi'
require 'fileutils'
require 'ostruct'

require 'mustache'

require 'ruhoh/logger'
require 'ruhoh/utils'
require 'ruhoh/friend'
require 'ruhoh/config'
require 'ruhoh/paths'
require 'ruhoh/urls'
require 'ruhoh/parsers/posts'
require 'ruhoh/parsers/pages'
require 'ruhoh/parsers/routes'
require 'ruhoh/parsers/layouts'
require 'ruhoh/parsers/partials'
require 'ruhoh/parsers/widgets'
require 'ruhoh/parsers/assets'
require 'ruhoh/parsers/site'
require 'ruhoh/db'
require 'ruhoh/templaters/helpers'
require 'ruhoh/templaters/rmustache'
require 'ruhoh/templaters/base'
require 'ruhoh/converters/markdown'
require 'ruhoh/converters/converter'
require 'ruhoh/page'
require 'ruhoh/previewer'
require 'ruhoh/watch'
require 'ruhoh/program'

class Ruhoh
  
  class << self
    attr_accessor :log
    attr_reader :config, :names, :paths, :root, :urls
  end
  
  @log = Ruhoh::Logger.new
  Root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  Names = {
    :assets => 'assets',
    :base_config => 'config.yml',
    :compiled => 'compiled',
    :dashboard_file => 'dash.html',
    :layouts => 'layouts',
    :media => 'media',
    :pages => 'pages',
    :partials => 'partials',
    :plugins => 'plugins',
    :posts => 'posts',
    :scripts => 'scripts',
    :site_data => 'site.yml',
    :stylesheets => 'stylesheets',
    :themes => 'themes',
    :theme_config => 'theme.json',
    :widgets => 'widgets',
    :widget_config => 'config.yml'
  }
  
  # Public: Setup Ruhoh utilities relative to the current application directory.
  # Returns boolean on success/failure
  def self.setup(opts={})
    self.reset
    @log.log_file = opts[:log_file] if opts[:log_file]
    @site_source = opts[:source] if opts[:source]
    
    @root     = Root
    @names    = OpenStruct.new(Names)
    @config   = Ruhoh::Config.generate(@names.base_config)
    @paths    = Ruhoh::Paths.generate(@config, @site_source)
    @urls     = Ruhoh::Urls.generate(@config)

    return false unless(@config && @paths && @urls)
    
    self.setup_plugins unless opts[:enable_plugins] == false
    true
  end
  
  def self.reset
    @site_source = Dir.getwd
  end
  
  def self.setup_plugins
    plugins = Dir[File.join(self.paths.plugins, "**/*.rb")]
    plugins.each {|f| require f } unless plugins.empty?
  end
  
  def self.ensure_setup
    raise 'Ruhoh has not been setup. Please call: Ruhoh.setup' unless Ruhoh.config && Ruhoh.paths
  end  
  
end # Ruhoh