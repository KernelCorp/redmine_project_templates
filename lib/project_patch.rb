require_dependency 'project'


# Patches Redmine's Project dynamically.
module ProjectPatch
  def self.included(base) # :nodoc:
     # Same as typing in the class
    base.class_eval do
      attr_accessor :is_template
    end

  end

end

# Add module to Issue
Project.send(:include, ProjectPatch)