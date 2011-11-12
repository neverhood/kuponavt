require 'rspec'
require 'capybara/rspec'

def authenticate_as_admin
   visit new_user_session_path

   current_path.should == '/users/sign_in'
   fill_in 'Email', :with => @admin.email
   fill_in 'Password', :with => 'please'
   click_button 'Sign in'
end
