# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

#get "/module_names/for_project/:id", :to => "projects#get_enabled_modules_names_for_project", :as => "get_module_names"
get "/module_names/for_project/:id", :to => "spike_for_module_names#get_enabled_modules_names_for_project", :as => "get_module_names"
