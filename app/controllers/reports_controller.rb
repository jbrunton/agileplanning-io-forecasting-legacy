class ReportsController < ApplicationController
  before_action :set_project, :set_filter

  def cycle_times
  end

  def forecast
    @backlog = @project.epics.select{ |epic| epic.epic_status != 'Done' }
    @upcoming = @backlog.select{ |epic| !epic.started }
    @in_progress = @backlog.select{ |epic| epic.started }

    if request.request_method == 'POST'
      opts = { :sizes => { 'S' => 0, 'M' => 0, 'L' => 0, '?' => 0 } }
      opts[:wip_scale_factor] = params[:wip_scale_factor].to_i unless params[:wip_scale_factor].empty?
      @forecasts = @upcoming.map do |epic|
        if (epic.size)
          opts[:sizes][epic.size] = opts[:sizes][epic.size] + 1
        else
          opts[:sizes]['?'] = opts[:sizes]['?'] + 1
        end
        { epic: epic, opts: opts.clone, forecast: MonteCarloSimulator.new(@project, @filter).play(opts) }
      end
      @start_date = params[:start_date].empty? ? DateTime.now.to_date : DateTime.parse(params[:start_date]).to_date
    end
  end

private
  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find(params[:project_id]) if params[:project_id]
  end

  def set_filter
    @filter = DateFilter.new(params[:filter] || "")
  end
end