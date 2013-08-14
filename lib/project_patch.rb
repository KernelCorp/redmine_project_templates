require_dependency 'project'


# Patches Redmine's Project dynamically.
module ProjectPatch
  def self.included(base) # :nodoc:
     # Same as typing in the class
    base.class_eval do
      attr_accessible :is_template
      attr_accessible :start_date
      belongs_to    :template, class_name: 'Project'
      has_many :projects, class_name: 'Project',
               foreign_key: 'template_id'
    end

  end

end

# Add module to Issue
Project.send(:include, ProjectPatch)