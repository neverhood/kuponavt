require 'spec_helper'

describe UsersController do

  before(:each) do
    @user = Factory.build(:user)
    @invalid_user = Factory.build(:invalid_user)
  end

  describe 'Sign up' do

    it 'should be able to create a user account with valid attributes' do
      visit new_user_registration_path

      fill_in 'Email', :with => @user.email
      fill_in 'Password', :with => 'please'
      fill_in 'Password confirmation', :with => 'please'

      click_button 'Sign up'

      page.should have_content I18n.t('devise.registrations.signed_up')
      current_path.should == '/'
    end

    it 'should not create a user with invalid attributes and show the errors' do
      visit new_user_registration_path

      fill_in 'Email', :with => 'Not an email'
      fill_in 'Password', :with => 'please'
      fill_in 'Password confirmation', :with => 'please'

      click_button 'Sign up'

      page.should have_content 'error'
      current_path.should == '/users'
    end

  end

  describe 'Authentication' do

    it 'should be able to authenticate the user' do
      @user.save
      visit new_user_session_path

      fill_in 'Email', :with => @user.email
      fill_in 'Password', :with => 'please'

      click_button 'Sign in'

      page.should have_content I18n.t('devise.sessions.signed_in')
      current_path.should == '/'
    end

    it 'should not authenticate user with invalid credantials and show the errors' do
      visit new_user_session_path

      fill_in 'Email', :with => @invalid_user.email
      fill_in 'Password', :with => 'please'

      click_button 'Sign in'

      page.should have_content I18n.t('devise.failure.invalid')
      current_path.should == '/users/sign_in'
    end
  end


end
