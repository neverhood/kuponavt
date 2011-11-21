require 'requests/requests_helper'

describe "Offers" do

  before(:each) do
    @country = Factory(:country)
    @city = Factory(:city, :country_id => @country.id)
  end

  it "should get the offers page and validate the content" do

    visit offers_path(:city => @city)
    page.has_css?('#all-offers').should === true

  end

end
