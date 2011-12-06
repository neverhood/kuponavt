class Admin::SuspiciousOffersController < ApplicationController

  before_filter :admin_only

  def index
    @offers = Offer.where(:category_id => nil)
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

end
