class PageLayout < ActiveRecord::Base
  validates_presence_of   :title
  validates_uniqueness_of :title

  image_accessor :preview_image

  before_save :serialize_parts

  def parts
    @parts ||= deserialize_parts
  end

  def parts= value
    @parts = value
  end

  def partial
    "page_layouts/#{partial_name}"
  end

protected
  def serialize_parts
    write_attribute(:parts, JSON.dump(self.parts.serialize))
  end

  def deserialize_parts
    attribute = read_attribute(:parts)
    if attribute.blank?
      PageLayoutParts.new({})
    else
      begin
        PageLayoutParts.new(JSON.load(attribute))
      rescue JSON::ParserError
        PageLayoutParts.new({})
      end
    end
  end
end

class PageLayoutParts < ActiveSupport::OrderedHash
  def initialize parts
    super()
    parts.each do |name, title|
      self[name] = PageLayoutPart.new(name, title)
    end
  end

  def add name, title
    self[name] = PageLayoutPart.new(name, title)
  end

  def serialize
    hash = ActiveSupport::OrderedHash.new
    self.each { |name, part| hash[part.name] = part.title }
    hash
  end
end

class PageLayoutPart
  attr_accessor :name, :title

  def initialize name, title
    @name  = name
    @title = title
  end
end
