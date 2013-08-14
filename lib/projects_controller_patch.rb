require_dependency 'projects_controller'


# Patches Redmine's Project dynamically.
module ProjectsControllerPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)
    base.class_eval do
      alias_method_chain :index, :template_check
      alias_method_chain :new, :select_templates
      alias_method_chain :settings, :select_templates
    end
  end

  module ClassMethods

  end

  module InstanceMethods
       def index_with_template_check
         respond_to do |format|
           format.html {
             scope = Project
             unless params[:closed]
               scope = scope.active
             end
             @projects = (params[:is_template].nil?)? scope.visible.where(is_template: false).order('lft').all :
                 scope.visible.where(is_template: true).order('lft').all
           }
           format.api  {
             @offset, @limit = api_offset_and_limit
             @project_count = Project.visible.where(is_template: false).count
             @projects = (params[:is_template].nil?)?
                 Project.visible.where(is_template: false).offset(@offset).limit(@limit).order('lft').all :
                 Project.visible.where(is_template: false).offset(@offset).limit(@limit).order('lft').all
           }
           format.atom {
             projects = Project.visible.where(is_template: false).order('created_on DESC').limit(Setting.feeds_limit
                                                                                                 .to_i).all
             render_feed(projects, :title => "#{Setting.app_title}: #{l(:label_project_latest)}")
           }
         end
       end

       def new_with_select_templates
         @templates = Project.where(:is_template => true)
         new_without_select_templates
         @project.is_template = params[:is_template]
         @project
       end

       def settings_with_select_templates
         @templates = Project.where(:is_template => true)
         settings_without_select_templates
       end

        def gettrue
          true
        end
  end
end

# Add module to Issue
ProjectsController.send(:include, ProjectsControllerPatch)