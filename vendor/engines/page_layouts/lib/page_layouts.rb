require 'refinery'

module Refinery
  module PageLayouts
    class Engine < Rails::Engine
      initializer "static assets" do |app|
        app.middleware.insert_after ::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public"
      end

      config.after_initialize do
        Refinery::Plugin.register do |plugin|
          plugin.name = "page_layouts"
          plugin.activity = {:class => PageLayout}
        end

        Refinery::Pages::Tab.register do |tab|
          tab.name = "layout"
          tab.partial = "/admin/pages/layout_tab"
        end
      end

      # to_prepare gets executed each request during debug (so the patches get applied after reloading the classes), or once on production.
      config.to_prepare do
        Page.send(:include, PageClassMethods)
        Page.send(:include, PageInstanceMethods)

        PagePart.send(:include, PagePartClassMethods)
        PagePart.send(:include, PagePartInstanceMethods)

        Admin::PagesController.send(:include, MigratePageMethods)
      end
    end


    module MigratePageMethods
      def self.included(klass)
        klass.class_eval do 
          before_filter :find_page_layouts, :only => [:new_choose_page_layout, :new, :edit]
          after_filter :migrate_layout, :only => [:update]

          def new_choose_page_layout
          end

          def find_page_layouts
            @page_layouts = PageLayout.all
          end

          def new
            layout = PageLayout.find_by_id params[:layout_id]
            if layout.nil?
              flash[:notice] = "You have to select a page layout, in order to add a new page"
              redirect_to new_choose_page_layout_admin_pages_path
            else
              @page = Page.new
              @page.layout = layout
              @page.layout.parts.each_with_index do |layout_part, index|
                name, part = layout_part
                @page.parts << PagePart.new(:name => name, :position => index)
              end
            end
          end

          def migrate_layout
            layout = PageLayout.find params[:layout_id]
            if layout && layout != @page.layout
              @page.migrate_layout_to layout, JSON.parse(params[:mapping])
            end
          end
        end
      end
    end

    module PageClassMethods
      def self.included(klass)
        klass.belongs_to :layout, :class_name => "PageLayout", :foreign_key => :page_layout_id
      end
    end

    module PageInstanceMethods
      def self.included(klass)
        klass.class_eval do
          def migrate_layout_to new_layout, mapping
            transaction do
              old_parts = parts.destroy_all

              self.layout = new_layout

              new_layout.parts.each do |name, part|
                parts.create :name => name
              end

              mapping.each do |from, to|
                new_part = parts.select { |p| p.name == from }.first

                new_body = ""
                to.each do |part|
                  new_body << old_parts.select { |p| p.name == part }.first.body
                end

                new_part.body = new_body
                new_part.save
              end

              save
            end
          end
        end
      end
    end

    module PagePartClassMethods
    end

    module PagePartInstanceMethods
      def self.included(klass)
        klass.class_eval do 
          def title
            page.layout.parts[name].title
          end
        end
      end
    end
  end
end
