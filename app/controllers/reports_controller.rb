class ReportsController < ApplicationController
  before_action :set_project, :set_filter

  def cycle_times
  end

  def forecast
    @backlog = @project.epics.select{ |epic| epic.epic_status == 'To Do' }
    @upcoming = @backlog.select{ |epic| !epic.started }
    @in_progress = @backlog.select{ |epic| epic.started }

    if request.request_method == 'POST'
      opts = { 'S' => 0, 'M' => 0, 'L' => 0, '?' => 0 }
      @forecasts = @upcoming.map do |epic|
        if (epic.size)
          opts[epic.size] = opts[epic.size] + 1
        else
          opts['?'] = opts['?'] + 1
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