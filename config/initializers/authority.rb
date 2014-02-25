# Be sure to restart your server when you modify this file.
Authority.configure do |config|
  # Each controller MUST HAVE a method to get the current user.
  config.user_method = :current_user

  config.controller_action_map = {
    :index   => 'read',
    :show    => 'read',
    :new     => 'create',
    :create  => 'create',
    :edit    => 'update',
    :update  => 'update',
    :destroy => 'delete'
  }

  # Defines the abilities that can have a user over a task
  config.abilities = {
    :create => 'creatable',
    :read   => 'readable',
    :update => 'updatable',
    :delete => 'deletable',
    :pick   => 'pickable',
    :notify => 'notifiable'
  }

  config.logger = Logger.new('log/authority.log')

end