class ResbTradePointsController < ApplicationController
  before_action :require_admin
  before_action :find_resb_trade_point, only: [:edit, :update]
  layout 'admin'
  self.main_menu = false

  def index
    @trade_points = ResbTradePoint.preload(:department).where(deleted: false)
  end

  def edit
    render layout: false
  end

  def update
    @trade_point.update_attributes(department_id: (params[:trade_point] || {})[:department_id])
  end

  private

  def find_resb_trade_point
    @trade_point = ResbTradePoint.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end