require 'redmine'

# Patches to the Redmine core.  Will not work in development mode
require_dependency 'project_patch'
require_dependency 'projects_controller_patch'

Redmine::Plugin.register :redmine_project_templates do
  name 'Project Templates plugin'
  author 'Kernel Web Studio'
  description 'This is a plugin for Redmine'
  version '0.5.1'
  url 'https://github.com/KernelCorp/redmine_project_templates.git'
  author_url 'http://kerweb.ru'


  menu :top_menu, :templates, { :controller => 'projects', :action => 'index', :is_template => 'true' },
      :caption => :templates
end
