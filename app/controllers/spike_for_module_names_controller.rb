class SpikeForModuleNamesController < ApplicationController
	def get_enabled_modules_names_for_project
		if params[:id].blank?
			render :json => { :nothing => "to return" }
		end
		project = Project.find(params[:id])
		render :json => { :modules_names => project.enabled_module_names, :trackers => project.tracker_ids }
	rescue
		render :json => { :nothing => "to return"}
	end
end
