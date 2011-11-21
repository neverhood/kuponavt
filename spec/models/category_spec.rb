require 'spec_helper'

describe Category do

  before(:each) do
    @category = Factory(:category_with_nested_category)
  end

  describe 'Validations' do

    it 'should recognize a valid category' do
      @category.should be_valid
    end

    it 'should recognize an invalid category' do
      Factory.build(:category, :name => '').should be_invalid
    end

  end

  describe 'Associations' do

    it 'should not return any offers by calling #offers on parent category' do
      @category.offers.count.should == 0
    end

  end

  describe 'Instance Methods' do

    it 'should return nested categories list when #nested_categories method is called' do
      @category.nested_categories.count.should > 0
    end

    it 'should return "true" when #parent? method is called on parent category' do
      (@category.parent?).should === true
    end

    it 'should return "false" when #parent? method is called on nested category' do
      @category.nested_categories.first.parent?.should === false
    end

  end


end
