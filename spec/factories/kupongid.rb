# Read about factories at http://github.com/thoughtbot/factory_girl
Factory.define(:offer, :class => Kupongid) do |offer|
  offer.kupongid_id 1
  offer.url 'http://hello-world.com'
end

