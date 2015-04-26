class ReportsController < ApplicationController
  def cycle_times
    @project = Project.find(params[:project_id])
  end
end