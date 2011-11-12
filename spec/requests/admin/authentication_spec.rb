require 'requests/requests_helper'


feature 'Authentication', %q(
  I should be able to authenticate as admin
  And be able to use the admin resources
) do

    self.use_transactional_fixtures = false

    background do
      @admin = Factory(:admin)
    end

    scenario 'Authenticate and try using admin resources' do
      authenticate_as_admin

      page.should have_content(I18n.t('devise.sessions.signed_in'))

      visit admin_root_path
      current_path.should == '/admin'

    end

    after(:each) do
      @admin.destroy
    end


end

