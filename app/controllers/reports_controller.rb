class ReportsController < ApplicationController
  before_action :set_dashboard, :set_filter

  def index
  end

  def control_chart
  end

  def forecast
    @backlog = Backlog::Builder.new(@dashboard, params[:issue_type]).build
    params[:forecast_type] = 'backlog' if params[:forecast_type].nil?

    if request.request_method == 'POST'
      @wip_scale_factor = wip_scale_factor
      @simulator = MonteCarloSimulator.new(@dashboard, @filter, params[:issue_type])
      @forecaster = Forecaster.new(@simulator)
      @start_date = start_date

      if params[:forecast_type] == 'backlog'
        @forecasts = @forecaster.forecast_backlog(@backlog, {})
        @start_date ||= DateTime.now.to_date
      else
        @lead_times = @forecaster.forecast_lead_times({
                :sizes => sizes,
                :wip_scale_factor => @wip_scale_factor,
                :start_date => @start_date
            })
      end
    end
  end

private
  def set_dashboard
    @dashboard = Dashboard.find(params[:dashboard_id]) if params[:dashboard_id]
  end

  def set_filter
    @filter = ::Filters::DateFilter.new(params[:filter] || "")
  end

  def sizes
    params[:sizes].map do |size, count|
      [
          /^\d+$/.match(size) ? size.to_i : size,
          count.to_i
      ]
    end.to_h
  end

  def start_date
    DateTime.parse(params[:start_date]).to_date unless params[:start_date].empty?
  end

  def wip_scale_factor
    params[:wip_scale_factor].to_f unless params[:wip_scale_factor].empty?
  end
end
