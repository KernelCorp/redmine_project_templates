class AddIsTemplateToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :is_template, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :projects, :is_template
  end
end