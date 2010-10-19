module NavigationHelpers
  module Refinery
    module PageLayouts
      def path_to(page_name)
        case page_name
        when /the list of page_layouts/
          admin_page_layouts_path

         when /the new page_layout form/
          new_admin_page_layout_path
        else
          nil
        end
      end
    end
  end
end
