# Read about factories at http://github.com/thoughtbot/factory_girl
Factory.define(:category) do |category|
  category.name 'Hello, World'
end

Factory.define(:nested_category, :class => Category) do |category|
  @parent_category = Factory(:category)

  category.name 'I`m contained in "Hello, World" category'
  category.parent_category_id @parent_category.id
end
