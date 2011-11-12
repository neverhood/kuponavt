require 'requests/requests_helper'


feature 'Sites', %q(
  Being admin, I should be able to add and remove a new site
) do

  self.use_transactional_fixtures = false

  background do
    @admin = Factory(:admin)
    @site = Factory.build(:site)
    authenticate_as_admin
  end

  scenario 'Create, then edit, save, expect redirect, then delete', :js => true do
    visit admin_root_path

    click_link 'Add Site'

    fill_in 'Title', :with => @site.title
    fill_in 'Address', :with => @site.address
    fill_in 'Data page', :with => @site.data_page
    click_button 'Create Site'

    site_id = Site.first.id

    click_link 'Edit Site'

    current_path.should == "/admin/sites/#{site_id}/edit"
    fill_in 'Description', :with => 'Hello, World'

    click_button 'Update Site'

    page.should have_content(I18n.t('notifications.sites.update'))
    current_path.should == "/admin/sites/#{site_id}"
    find(:xpath, "//div[@class='site-description']").text.should =~ /Hello, World/


    visit admin_root_path
    page.evaluate_script('window.confirm = function() { return true; }')
    find(:xpath, "//tr[@id='#{site_id}']/td[@class='controls']/a[@class='destroy-site']").click

    page.should have_content(I18n.t('notifications.sites.destroy'))
  end

  after(:each) {
    @admin.destroy
  }

end

