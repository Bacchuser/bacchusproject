Bacchus::Application.routes.draw do
  devise_for :cake_plan_users

  root 'home#main'

  # The tasks ressources have all the main routes for managing a task
  # All the logic are then done in the associate presenters, in order
  # to keep skinny controller.
  resources :tasks,
    :except => [:show, :new, :edit, :create, :update, :destroy],
    :constraints => { :id => /\d.*/ } do

    member do
      get 'admin_event(/:task_id)', :action => :admin_event, :as => :admin_event
      post 'update_subtask/:task_id', :action => :update_subtask, :as => :update_subtask
      get :new_task
    end
  end

  # No use for now. Maybe useless, was to complete the DB schema
  resources :users

  # Main page, to display login/register, and the main dashboard.
  resources :home do
    collection do
      get :new_event
      post :create_event
    end
  end
end
