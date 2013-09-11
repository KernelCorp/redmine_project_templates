class SpikeForModuleNamesController < ApplicationController
	def get_enabled_modules_names_for_project
		if params[:id].blank?
			render :json => { :nothing => "to return" }
		end
		enabled_modules_names = Project.find(params[:id]).enabled_modules.map do |m| m.name end
		render :json => { :modules_names => enabled_modules_names }
	rescue
		render :json => { :nothing => "to return"}
	end
end
