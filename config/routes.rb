Bacchus::Application.routes.draw do
  devise_for :cake_plan_users

  # The main controller is home. It's allowd to do two things :
  # 1. Display all the event in list (main page)
  # 2. Create a new event (so form and saving behaviour)
  root 'home#main'
  resources :home do
  end

  resources :event
  # All the tasks are managed by the task controller.
  # like this, we can create/edit/display all the different
  # task and their particularities.
  # Because at the end, for a controller, it's always the same actions :
  # * Save a task
  # * Display a task
  # * Update a task
  # * Delete a task.
  #
  # So we decide to implement a reflexive method. Like this, all the
  # task now if they have subclass or not, and which one it is.
  # Like this, the controller display the task related with the
  # subclass name (partial _subclassname.hml.slim).
  # And the save/delete/update are done by dynamic linking
  # (we start saving for the subclass, and then the subclass
  # as the contract to go up to share the saving message).
  #
  # TODO
  # [ ] the update_subtask is EVIL
  # [ ] the new_task should be renamed in create_task
  # [ ] delete a subtask is not done
  resources :tasks,
    :except => [:show, :new, :edit, :create, :update, :destroy],
    :constraints => { :id => /\d.*/ } do

    member do
      # We display the event, with eventually a subtask to display.
      get 'admin_event(/:task_id)', :action => :admin_event, :as => :admin_event
      # we update the subtask. Could be save/create/update.
      post 'update_subtask/:task_id', :action => :update_subtask, :as => :update_subtask
      # create a new and empty task, with NO subclass.
      get :new_task
    end
  end
end
