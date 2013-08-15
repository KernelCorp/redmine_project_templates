require 'redmine'

# Patches to the Redmine core.  Will not work in development mode
require_dependency 'project_patch'
require_dependency 'projects_controller_patch'

Redmine::Plugin.register :project_templates do
  name 'Project Templates plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'


  menu :top_menu, :templates, { :controller => 'projects', :action => 'index', :is_template => 'true' },
      :caption => :templates
end
