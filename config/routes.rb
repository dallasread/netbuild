require "sidekiq/web"

Netbuild::Application.routes.draw do

  devise_for :users,
    path: "accounts", 
    controllers: {
      sessions: "sessions",
      registrations: "registrations"
    }

  constraints subdomain: "www" do
    resources :websites
    resources :themes, only: [:index, :show]
    resources :addons
    post "/webhooks/stripe" => "stripe#webhook", as: :stripe
    get "/webhooks/stripe" => "stripe#webhook" # TESTING
    get "/oauth/callback/stripe" => "stripe#callback"
    
    authenticated :user, lambda { |u| u.super_admin? } do
      mount Sidekiq::Web => "/sidekiq"
    end
  end
  
  constraints subdomain: /.*?/ do
    get "/feed" => "websites#feed", as: :feed, defaults: { format: :atom }
    
    authenticated do
      resources :blocks, only: [:show, :create]
      
      constraints "1" == "2" do
        scope "/manage" do
          resources :memberships, path: :people
          resources :invoices
          resources :pages
          get "/media/tags" => "media#tags"
          resources :media
          resources :messages, only: [:show, :create]
          resources :themes do
            resources :documents
          end
          
          get "/billing" => "invoices#index", as: :billing
          patch "/save" => "websites#update", as: :save
          get "/save", to: redirect { "/manage/theme" }
          get "/:feature" => "websites#edit", as: :manage
        end
      end
      
      get "/manage", to: redirect { "/manage/theme" }
    end
    
    resources :themes, only: :show
    
    constraints year: /\d.+/, month: /\d.+/ do
      get "/:year/:month/:post" => "pages#show"
      get "/:permalink/:year/:month/:post" => "pages#show"
      get "/:permalink/:year/:month" => "pages#show"
      get "/:permalink/:year" => "pages#show"
    end
    
    post "/submission" => "pages#submit", as: :submit
    get "/:a(/:b(/:c))" => "pages#show", as: :public_page
  end
  
  root to: "pages#show"
  
end
