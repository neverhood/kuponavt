class Admin::BotController < ApplicationController

  layout 'application'

  before_filter :admin_only
  before_filter :prepare_category, :only => :index

  def index
    @entries ||= BotStatistics.order('created_at DESC').page( params[:page] )
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
    if params[:category]
      BotStatistics.where(category_id: params[:category]).delete_all
    else
      BotStatistics.delete_all
    end
    render :json => { :status => :success }
  end

  private

  def admin_only
    redirect_to root_path unless current_user && current_user.admin?
  end

  def prepare_category
    if params[:category]
      @entries = BotStatistics.order('created_at DESC').
        where(category_id: params[:category]).
        page( params[:page] )
    end
  end

end
