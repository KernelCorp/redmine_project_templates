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
      alias_method_chain :create, :template
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

       end

       def settings_with_select_templates
         @templates = Project.where(:is_template => true)
         settings_without_select_templates
       end

       def create_with_template
         if params[:project][:template_id].blank?
            create_without_template
         else
           @issue_custom_fields = IssueCustomField.sorted.all
           @trackers = Tracker.sorted.all
           begin
           @source_project = Project.find(params[:project][:template_id])


           if request.get?
             @project = Project.copy_from(@source_project)
             @project.identifier = Project.next_identifier if Setting.sequential_project_identifiers?
           else
             Mailer.with_deliveries(params[:notifications] == '1') do
               @project = Project.new  :template_id => params[:project][:template_id], :is_template => false
               @project.safe_attributes = params[:project]
               if validate_parent_id && @project.copy(@source_project, :only => params[:only])
                 @project.set_allowed_parent!(params[:project]['parent_id']) if params[:project].has_key?('parent_id')
                 #subproject copy
                 @source_project.children.each do |subproject|
                   subproject_copy = Project.new(:name => subproject.name,
                                                 :identifier => @project.identifier + '_' + subproject.name  )
                   subproject_copy.copy(subproject, :only => params[:only])
                   subproject_copy.set_allowed_parent! @project.id

                 end
                 @project.users = @source_project.users
                 @project.save!
                 flash[:notice] = l(:notice_successful_create)
                 redirect_to settings_project_path(@project)
               elsif !@project.new_record?
                 # Project was created
                 # But some objects were not copied due to validation failures
                 # (eg. issues from disabled trackers)
                 # TODO: inform about that
                 redirect_to settings_project_path(@project)
               end
             end
           end

           rescue ActiveRecord::RecordNotFound
             # source_project not found
             render_404
           end
         end #if
       end


  end
end

# Add module to Project
ProjectsController.send(:include, ProjectsControllerPatch)