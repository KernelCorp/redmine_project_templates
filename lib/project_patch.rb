require_dependency 'project'


# Patches Redmine's Project dynamically.
module ProjectPatch
  def self.included(base) # :nodoc
	  base.send(:include, InstanceMethods)
	  
     # Same as typing in the class
    base.class_eval do
      belongs_to    :template, class_name: 'Project'
      has_many :projects, class_name: 'Project',
               foreign_key: 'template_id'
    end

  end

  module InstanceMethods
    def copy_from_with_deep_copy(project)
      copy = copy_from(project)
      copy.issues = project.issues
      copy.news = project.news
      copy.documents = projects.documents
      copy
    end
  end

end

# Add module to Project
Project.send(:include, ProjectPatch)
Project.safe_attributes 'is_template', 'start_date'

