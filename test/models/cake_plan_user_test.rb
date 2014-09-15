require 'test_helper'

class CakePlanUserTest < ActiveSupport::TestCase

  test "Should not save user without email" do
    user = CakePlanUser.new
    assert_not user.save
  end

  test "Should not save user with invalid email - 1" do
    user = cake_plan_users(:normal_user)
    user.email = "mon_email_invalide"
    assert_not user.save
  end

  test "Should not save user with invalid email - 2" do
    user = cake_plan_users(:normal_user)
    user.email = "pas not plus valide@mail.com"
    assert_not user.save
  end

  test "Should not save user with no password" do
    user = cake_plan_users(:normal_user)
    user.password = ""
    user.password_confirmation = ""
    assert_not user.save
  end

  test "Should not save user with invalid password" do
    user = cake_plan_users(:normal_user)
    user.password = "123"
    user.password_confirmation = "123"
    assert_not user.save
  end

  test "Should not save user with invalid confirmation password" do
    user = cake_plan_users(:normal_user)
    user.password_confirmation = "veD?FuBr3s"
    assert_not user.save
  end

  test "Connect user normal_user" do
    CakePlanUser.stubs(:authenticate).returns false
    user = cake_plan_users(:normal_user)
    post :sign_in, :user => {:user_name => 'foo', :password =>'bar'}
    assert_equals flash[:error] , "Authentication failed"
  end


end
