class AddPageLayoutToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :page_layout, :string, :default => '', :null => false
  end

  def self.down
    remove_column :pages, :page_layout
  end
end
