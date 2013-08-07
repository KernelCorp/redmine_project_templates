require_dependency 'project'


# Patches Redmine's Project dynamically.
module ProjectPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      attr_accessor :is_template

    end

  end

  module ClassMethods

  end

  module InstanceMethods

  end
end

# Add module to Issue
Project.send(:include, ProjectPatch)