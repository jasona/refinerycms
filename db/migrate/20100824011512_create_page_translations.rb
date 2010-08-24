class CreatePageTranslations < ActiveRecord::Migration
  def self.page_attribute page, name
    page.instance_eval { read_attribute name }
  end

  def self.up
    create_table :page_translations do |t|
      t.integer :page_id
      t.string  :locale
      t.string  :title
      t.string  :meta_keywords
      t.text    :meta_description
      t.string  :custom_title
      t.string  :browser_title

      t.timestamps
    end

    add_column :page_parts, :page_translation_id, :integer

    add_index :page_translations, [:page_id, :locale]
    add_index :page_translations, :title


    Page.all.each do |page|
      translation = page.translations.create :locale           => I18n.default_locale.to_s,
                                             :title            => page_attribute(page, :title),
                                             :meta_keywords    => page_attribute(page, :meta_keywords),
                                             :meta_description => page_attribute(page, :meta_description),
                                             :custom_title     => page_attribute(page, :custom_title),
                                             :browser_title    => page_attribute(page, :browser_title)

      PagePart.find_by_page_id(page.id).each do |part|
        part.update_attributes! :page_translation => translation
      end
    end

    remove_column :pages, :title
    remove_column :pages, :meta_keywords
    remove_column :pages, :meta_description
    remove_column :pages, :custom_title
    remove_column :pages, :browser_title
    remove_column :page_parts, :page_id

    remove_column :page_parts
  end

  def self.down
    add_column :pages, :title,            :string
    add_column :pages, :meta_keywords,    :text
    add_column :pages, :meta_description, :text
    add_column :pages, :custom_title,     :string
    add_column :pages, :browser_title,    :string
#add_column :page_parts, :page_id, :integer

    Page.all.each do |page|
      t = page.translations.default
      page.title            = t.title
      page.meta_keywords    = t.meta_keywords
      page.meta_description = t.meta_description
      page.custom_title     = t.custom_title
      page.browser_title    = t.browser_title
      page.save!

#      t.parts.each do |part|
#        part.update_attributes! :page_id => page.id
#      end

      page.translations.destroy_all
    end

    drop_table :page_translations

  end
end
