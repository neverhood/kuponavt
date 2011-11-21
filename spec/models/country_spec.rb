require 'spec_helper'

describe Country do

  before(:each) do
    @country = Factory :country
    @city = Factory :city, :country_id => @country.id
    @category = Factory :category
    @offer = Factory(:offer, :city_id => @city.id, :country_id => @country.id, :category_id => @category.id)
  end

  describe 'Associations' do

    it 'should be able to retrieve a list of cities by #cities association' do
      @country.cities.count.should == 1
    end

    it 'should be able to retrieve a list of offers by #offers association' do
      @country.offers.count.should > 0
    end

  end

end
