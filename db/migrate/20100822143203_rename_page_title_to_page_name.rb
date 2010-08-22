class RenamePageTitleToPageName < ActiveRecord::Migration
  def self.up
    rename_column :page_parts, :title, :name
  end

  def self.down
    rename_column :page_parts, :name, :title
  end
end
