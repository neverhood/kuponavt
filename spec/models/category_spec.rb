require 'spec_helper'

describe Category do

  before(:each) do
    @category = Factory :category
    @nested_category = Factory :category, :name => 'nested', :parent_category_id => @category.id
  end

  describe 'Validations' do

    it 'should recognize a valid category' do
      @category.should be_valid
    end

    it 'should recognize an invalid category' do
      Factory.build(:category, :name => '').should be_invalid
    end

  end

  describe 'Instance Methods' do

    it 'should return nested categories list when #nested_categories method is called' do
      @category.nested_categories.count.should == 1
    end

    it 'should return "true" when #parent? method is called on parent category' do
      (@category.parent?).should === true
    end

    it 'should return "false" when #parent? method is called on nested category' do
      @nested_category.parent?.should === false
    end

  end


end
