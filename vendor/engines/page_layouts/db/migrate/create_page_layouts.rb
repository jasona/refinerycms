class CreatePageLayouts < ActiveRecord::Migration

  def self.up
    create_table :page_layouts do |t|
      t.string  :title
      t.text    :description
      t.text    :parts

      t.string  :preview_image_uid

      t.integer :position

      t.timestamps
    end

    add_index :page_layouts, :id

    load(Rails.root.join('db', 'seeds', 'page_layouts.rb'))
  end

  def self.down
    UserPlugin.destroy_all({:name => "page_layouts"})

    Page.delete_all({:link_url => "/page_layouts"})

    drop_table :page_layouts
  end

end
