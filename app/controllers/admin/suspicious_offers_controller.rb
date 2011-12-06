class Admin::SuspiciousOffersController < ApplicationController

  before_filter :admin_only

  def index
    @offers = Offer.where(:category_id => nil)
  end

  def update
    @offer = Offer.find params[:id]
    @category = Category.find params[:category_id]

    render :json => { :status => :success } if @offer.update_attributes(category_id: @category.id) if @offer && @category
  end

  private

  def admin_only
    redirect_to root_path unless current_user && current_user.admin?
  end

end
