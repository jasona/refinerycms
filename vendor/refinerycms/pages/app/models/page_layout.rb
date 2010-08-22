class PageLayout
  attr_reader :name, :parts
  #TODO: Cache YAML file reading
  class << self
    def all
      config_file = Rails.root.join 'config', 'page_layouts.yml'
      return [] unless File.exists? config_file

      config = YAML::load File.read(config_file)
      layouts = PageLayout::Collection.new
      config.keys.each do |name|
        layouts << PageLayout.new(name, config[name]['parts'])
      end

      layouts
    end

    def find_by_name name
      all.find_by_name name
    end
  end

  def partial
    Dir.glob(Rails.root.join('page_layouts', "#{@name}*").to_s).first.to_s
  end

protected
  def initialize name, parts
    @name = name
    @parts = parts
  end
end

class PageLayout::Collection < Array
  def find_by_name name
    self.each do |layout|
      return layout if layout.name == name
    end

    nil
  end
end
