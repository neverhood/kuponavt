require 'spec_helper'

describe "OffersMainPages" do

  self.use_transactional_fixtures = false

  before(:each) do
    @country = Factory :country
    @city = Factory :city, :country_id => @country.id
    @category = Factory(:category)
  end

  after(:each) do
    @category.destroy
    @country.destroy
  end

  it 'passes a standard workflow', :js => true do
    visit offers_path(:city => @city)
    offers_cleaner = -> { page.evaluate_script('document.getElementById("all-offers").innerHTML = ""') } # Clear rendered offers first
    offer_detector = -> { page.has_css?("#offer-#{@category.nested_categories.first.offers.first.id}") }

    lala = have_css('.all-tags', :count => Category.nested_categories.count)
    binding.pry

    page.should have_css('.all-tags', :count => Category.nested_categories.count)

    offers_cleaner.call
    click_link 'all-offers-check'
    offer_detector.call.should === true

    offers_cleaner.call
    click_link 'all-offers-clear'
    offer_detector.call.should === true

    offers_cleaner.call
    page.find('.all-tags').click
    offer_detector.call.should === true

  end

end
