# Read about factories at http://github.com/thoughtbot/factory_girl
Factory.define(:nested_category, :class => Category) do |category|
  category.sequence(:name) { |n| "Category-#{n}" }
  category.after_create do |c|
    (5 + rand(5)).times { Factory(:offer, :category_id => c.id, :city_id => City.default.id) }
  end
end

Factory.define(:category) do |category|
  category.sequence(:name) { |n| "Parent-Category#{n}" }
  category.after_create { |c| (1 + rand(3)).times { Factory(:nested_category, :parent_category_id => c.id) } }
end

Factory.define(:standalone_category, :class => Category) do |category|
  category.name 'Hello, World'
end

Factory.define(:category_with_nested_category, :class => Category) do |category|
  category.sequence(:name) { |n| "Hello, World#{n}" }
  category.after_create do |c|
    Factory(:standalone_category, :parent_category_id => c.id)
  end
end
