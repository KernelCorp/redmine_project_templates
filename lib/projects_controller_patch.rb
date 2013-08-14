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
         @project
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
           @project = Project.new
           @project.safe_attributes = params[:project]

           if validate_parent_id && @project.save
             @project.set_allowed_parent!(params[:project]['parent_id']) if params[:project].has_key?('parent_id')
             # Add current user as a project member if he is not admin
             unless User.current.admin?
               r = Role.givable.find_by_id(Setting.new_project_user_role_id.to_i) || Role.givable.first
               m = Member.new(:user => User.current, :roles => [r])
               @project.members << m
             end
             respond_to do |format|
               format.html {
                 flash[:notice] = l(:notice_successful_create)
                 if params[:continue]
                   attrs = {:parent_id => @project.parent_id}.reject {|k,v| v.nil?}
                   redirect_to new_project_path(attrs)
                 else
                   redirect_to settings_project_path(@project)
                 end
               }
               format.api  { render :action => 'show', :status => :created, :location => url_for(:controller => 'projects', :action => 'show', :id => @project.id) }
             end
           else
             respond_to do |format|
               format.html { render :action => 'new' }
               format.api  { render_validation_errors(@project) }
             end
           end
         end #if
       end


  end
end

# Add module to Project
ProjectsController.send(:include, ProjectsControllerPatch)