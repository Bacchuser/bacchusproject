Bacchus::Application.routes.draw do
  devise_for :cake_plan_users

  root 'home#main'

  resources :tasks, :except => [:show, :new, :edit, :create, :update, :destroy] do
    member do
      get :admin_event
      get :organise
    end
  end

  resources :users

  resources :home do
    collection do
      get :new_event
      post :create_event
    end
  end



end
