Bacchus::Application.routes.draw do
  devise_for :cake_plan_users

  # The main controller is home. It's allowd to do two things :
  # 1. Display all the event in list (main page)
  # 2. Create a new event (so form and saving behaviour)
  root 'home#main'

  resources :home do
    collection do
      get :new_event # Form
      post :create_event # Saving
    end
  end

  resources :question

  resources :event, only: [:new, :edit, :create] do
    resources :subtask do
      member do
        post :add_leaf
        post :define_leaf
        post :update_leaf
        delete :remove_leaf
      end
    end
  end

end
