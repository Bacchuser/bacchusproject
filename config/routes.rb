Bacchus::Application.routes.draw do
  devise_for :cake_plan_users

  root 'home#main'

  resources :tasks

  resources :users

  resources :home do
    collection do
      post 'create_event'
    end
  end

end
