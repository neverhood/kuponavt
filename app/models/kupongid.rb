class Kupongid < ActiveRecord::Base

  set_table_name :kupongid

  belongs_to :country
  belongs_to :city

end
