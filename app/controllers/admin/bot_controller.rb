class Admin::BotController < ApplicationController

  layout 'admin'

  before_filter :admin_only

  def index
    @entries = BotStatistics.order('created_at DESC').page( params[:page] )
  end

  def undefined
    @entries = BotStatistics.where(category_id: nil).page( params[:page] )
  end

  def show
    @offer = Offer.find( BotStatistics.find(params[:id]).offer_id )
  end

  def destroy
    @offer = Offer.find( BotStatistics.find(params[:id]).offer_id )
    @offer.update_attributes(category_id: nil)
    render :json => { :status => :success }
  end

  def clear
    BotStatistics.delete_all
    render :json => { :status => :success }
  end

  private

  def admin_only
    redirect_to root_path unless current_user && current_user.admin?
  end

end
