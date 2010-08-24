class PageTranslation < ActiveRecord::Base
  belongs_to :page
  attr_accessible :page, :locale,
                  :title, :parts, :meta_keywords, :custom_title, :browser_title

  has_many :parts,
           :class_name => "PagePart",
           :order => "position ASC",
           :inverse_of => :page_translation

  accepts_nested_attributes_for :parts,
                                :allow_destroy => true
end
