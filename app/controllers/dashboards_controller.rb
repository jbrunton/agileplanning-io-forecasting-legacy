class DashboardsController < ApplicationController
  before_action :set_dashboard, only: [:show, :sync]
  before_action :set_domain, only: [:index]

  # GET /dashboards
  # GET /dashboards.json
  def index
    @dashboards = @domain.dashboards
  end

  # GET /dashboards/1
  # GET /dashboards/1.json
  def show
  end

  # POST /dashboards/1/sync
  # POST /dashboards/1/sync.json
  def sync
    job = SyncDashboardJob.new
    job.async.sync_dashboard(@dashboard, params)
    render nothing: true
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_dashboard
    @dashboard = Dashboard.find(params[:id])
  end

  def set_domain
    @domain = Domain.find(params[:domain_id])
  end
end
