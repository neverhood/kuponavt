class Admin::SuspiciousOffersController < ApplicationController

  before_filter :admin_only
  before_filter :prepare_offers
  before_filter :prepare_suspicious_attribute

  def index
  end

  def update
    @offer = Offer.find params[:id]

    if @offer.update_attributes(@suspicious_attribute => params[@suspicious_attribute])
      expire_fragment /offers.*#{@offer.city.name}/
      render :json => { :status => :success }
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

  def prepare_suspicious_attribute
    suspicious_attributes = [:ends_at, :category_id, :provided_id]
    @suspicious_attribute = params.keys.find { |attribute| suspicious_attributes.include?( attribute.to_sym ) }
  end

end
