Refinery::Application.routes.draw do
  resources :page_layouts

  scope(:path => 'refinery', :as => 'admin', :module => 'admin') do
    resources :page_layouts do
      collection do
        post :update_positions
      end
    end
  end
end
