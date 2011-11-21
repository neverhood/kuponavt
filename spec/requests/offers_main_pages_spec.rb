require 'spec_helper'

describe "OffersMainPages" do

  self.use_transactional_fixtures = false

  before(:each) do
    @country = Factory :country
    @city = Factory :city, :country_id => @country.id
    @category = Factory(:category)
    @offers = Category.nested_categories.map(&:offers).flatten
  end

  after(:each) do
    @category.destroy
    @country.destroy
  end

  it 'passes a standard workflow', :js => true do
    visit offers_path(:city => @city)
    offers_cleaner = -> { page.evaluate_script('document.getElementById("all-offers").innerHTML = ""') } # Clear rendered offers first

    page.should match_exactly(Category.parent_categories.count, '.all-tags')
    page.should match_exactly(25, '.offer')
    Category.nested_categories.each do |category|
      page.has_css?("input##{category.id}").should === true
    end

    ['#all-offers-check', '#all-offers-clear'].each do |selector|
      offers_cleaner.call
      find(selector).click
      page.should match_exactly(25, '.offer')
    end

    ["input##{@offers.first.category_id}", ".all-tags##{@offers.first.category.parent_category_id}"].each do |selector|
      offers_cleaner.call
      find(selector).click
      page.has_css?("#offer-#{@offers.first.id}").should === true
    end

  end

end
