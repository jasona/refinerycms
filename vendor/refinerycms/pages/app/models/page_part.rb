class PagePart < ActiveRecord::Base

  belongs_to :page

  validates :name, :presence => true
  alias_attribute :content, :body

  def to_param
    "page_part_#{self.name.downcase.gsub(/\W/, '_')}"
  end

  before_save :normalise_text_fields

protected
  def normalise_text_fields
    unless self.body.blank? or self.body =~ /^\</
      self.body = "<p>#{self.body.gsub("\r\n\r\n", "</p><p>").gsub("\r\n", "<br/>")}</p>"
    end
  end

end
