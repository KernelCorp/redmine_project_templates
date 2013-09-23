require_dependency 'welcome_controller'

module WelcomeControllerPatch

  module ClassMethods

  end

  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)
    base.class_eval do
      alias_method_chain :index, :template_check
    end
  end

  module InstanceMethods
    def index_with_template_check
      @news = News.latest User.current
      @projects = Project.not_template.latest User.current
    end
  end
end
WelcomeController.send(:include, WelcomeControllerPatch)