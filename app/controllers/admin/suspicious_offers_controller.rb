class Admin::SuspiciousOffersController < ApplicationController

  before_filter :admin_only
  before_filter :prepare_offers

  def index
  end

  def update
    @offer = Offer.find params[:id]
    @category = Category.find params[:category_id]

    if @offer && @category

      if @offer.update_attributes(category_id: @category.id)
        expire_fragment /categories.*#{@category.id}.*action.*index.*controller.*offers.*city.*#{@offer.city.name}.*\.json/
        expire_fragment /.*action.*index.*controller.*offers.*city.*#{@offer.city.name}.*\.html/
        render :json => { :status => :success }
      end

    end
  end

  private

  def admin_only
    redirect_to root_path unless current_user && current_user.admin?
  end

  def prepare_offers
    suspicious_attribute = case params[:section]
                           when nil then :category_id
                           when 'provided_id' then :provided_id
                           when 'ends_at' then :ends_at
                           end
    @offers = Offer.where(suspicious_attribute => nil)
  end

end
