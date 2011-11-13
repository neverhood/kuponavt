require 'requests/requests_helper'

describe "Offers" do

  it "should get the offers page and validate the content" do

    visit root_path

    page.should have_content('Kuponavt')

  end

end
