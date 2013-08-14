class AddBelongsToTemplate < ActiveRecord::Migration
  def self.up
    add_column :projects, :template_id, :integer
  end

  def self.down
    remove_column :projects, :template_id
  end
end