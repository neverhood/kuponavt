require 'spec_helper'

describe Kupongid do

  before(:each) do
    @country = Factory(:country)
    @city = Factory(:city, :country_id => @country.id)
    @category = Factory(:category)
    @offer = Factory(:offer, :category_id => @category.id, :city_id => @city.id, :country_id => @country.id)
  end

  describe 'Associations' do

    it 'should retrieve city object by #city association' do
      @offer.city.should == @city
    end

    it 'should retrieve country object by #country association' do
      @offer.country.should == @country
    end

    it 'should retrieve category object by #category association' do
      @offer.category.should == @category
    end

  end

end
