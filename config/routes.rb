Blocks::Application.routes.draw do
  
  devise_scope :user do
  
    constraints subdomain: /^((?!www).)*$/ do
      devise_for :users, controllers: {
        sessions: "sessions"
      }
      
      authenticated :user do
        resources :websites
        resources :memberships, path: :members
        resources :pages
        
        resources :themes do
          resources :documents
        end
      end
      
      get "/:permalink" => "pages#show", as: :public_page
      get "/" => "pages#show"
    end
    
    resources :themes, only: [:index, :show]
    resources :websites, only: [:create]
    root "websites#new"

  end
end
