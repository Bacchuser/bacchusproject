puts "CREATE DEFAULTS"
def new_users
  user = CakePlanUser.create! email: 'hadrien.froger@gmail.com',
                       password: 'bacchus123456789',
                       password_confirmation: 'bacchus123456789'
  puts ">> user :" << user.email << ", pass : bacchus123456789"

  user = CakePlanUser.create! email: 'hadrien@bacchusproject.ch',
                       password: 'bacchus123456789',
                       password_confirmation: 'bacchus123456789'
  puts ">> user :" << user.email << ", pass : bacchus123456789"


end

new_users()