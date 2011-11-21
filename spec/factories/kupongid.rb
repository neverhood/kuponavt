# Read about factories at http://github.com/thoughtbot/factory_girl
Factory.define(:offer, :class => Kupongid) do |offer|
  offer.sequence(:kupongid_id) { |n| n }
  offer.sequence(:url) { |n| "http://hello-world#{n}.com" }
end

