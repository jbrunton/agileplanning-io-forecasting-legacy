class ReportsController < ApplicationController
  before_action :set_dashboard, :set_filter

  def index
  end

  def control_chart
  end

  def forecast
    backlog = BacklogBuilder.new(@dashboard, params[:issue_type]).build
    @upcoming = backlog[:upcoming]
    @in_progress = backlog[:in_progress]
    params[:forecast_type] = 'backlog' if params[:forecast_type].nil?

    if request.request_method == 'POST'
      @wip_scale_factor = params[:wip_scale_factor].to_f unless params[:wip_scale_factor].empty?
      @simulator = MonteCarloSimulator.new(@dashboard, @filter, params[:issue_type])
      if params[:forecast_type] == 'backlog'
        forecast_backlog
      else
        forecast_lead_times
      end
    end
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_dashboard
    @dashboard = Dashboard.find(params[:dashboard_id]) if params[:dashboard_id]
  end

  def set_filter
    @filter = ::Filters::DateFilter.new(params[:filter] || "")
  end

  def forecast_backlog
    opts = { :sizes => { 'S' => 0, 'M' => 0, 'L' => 0, '?' => 0 } }
    opts[:wip_scale_factor] =  @wip_scale_factor unless @wip_scale_factor.nil?
    rank = 0
    @forecasts = @upcoming.map do |epic|
      if (epic.size)
        opts[:sizes][epic.size] = opts[:sizes][epic.size] + 1
      else
        opts[:sizes]['?'] = opts[:sizes]['?'] + 1
      end
      rank = rank + 1
      opts[:rank] = rank
      opts[:size] = epic.size
      { epic: epic, opts: opts.clone, forecast: @simulator.play(opts) }
    end
    @start_date = params[:start_date].empty? ? DateTime.now.to_date : DateTime.parse(params[:start_date]).to_date
  end

  def forecast_lead_times
    opts = {
        :sizes => {
            'S' => params[:small].to_i,
            'M' => params[:medium].to_i,
            'L' => params[:large].to_i,
            '?' => params[:unknown].to_i
        },
        :wip_scale_factor => @wip_scale_factor
    }
    total = opts[:sizes].values.reduce(:+)
    opts[:rank] = total # to ensure that we don't divide by WIP when total < WIP
    @lead_times = @simulator.play(opts)
    @start_date = DateTime.parse(params[:start_date]).to_date unless params[:start_date].empty?
  end
end