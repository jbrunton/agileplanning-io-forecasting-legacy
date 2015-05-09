class ReportsController < ApplicationController
  before_action :set_project, :set_filter

  def cycle_times
  end

  def forecast
    if request.request_method == 'POST'
      opts = {}
      opts.merge!({'S' => params[:small_count].to_i}) if params[:small_count].to_i > 0
      opts.merge!({'M' => params[:medium_count].to_i}) if params[:medium_count].to_i > 0
      opts.merge!({'L' => params[:large_count].to_i}) if params[:large_count].to_i > 0
      @forecast = MonteCarloSimulator.new(@project).play(opts)
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