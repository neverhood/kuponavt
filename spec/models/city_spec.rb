require 'spec_helper'

describe City do

  before(:each) do
    @country = Factory(:country)
    @city = Factory(:city, :country_id => @country.id)
    @category = Factory(:category)
    @offer = Factory(:offer, :category_id => @category.id, :city_id => @city.id, :country_id => @country.id)
  end

  describe 'Validations' do

    it 'should recognize a valid city' do
      @city.should be_valid
    end

    it 'should recognize an invalid city' do
      Factory.build(:city).should be_invalid
    end

  end

  describe 'Methods' do

    it 'should return `name` attribute when #to_param is called' do
      @city.to_param.should == @city.name
    end

    it 'should return a default object when #default is called' do
      City.default.should_not be_nil
    end

    it 'should return a collection of offers grouped by categories when #by_categories is called on #offers association' do
      @city.offers.by_categories([@category.id]).count.should_not be_zero
    end

  end




end
