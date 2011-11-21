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
      @offer.city.id.should == @city.id
    end

    it 'should retrieve country object by #country association' do
      @offer.country.id.should == @country.id
    end

    it 'should retrieve category object by #category association' do
      @offer.category.id.should == @category.id
    end

  end

end
