class DataController < ApplicationController
  before_action :set_project, only: [:cycle_times, :wip]
  before_action :set_filter, only: [:cycle_times, :wip]

  def cycle_times
    epics = @project.issues.includes(:issues).
        where(issue_type: 'Epic').
        select{ |epic| epic.cycle_time && @filter.allow_issue(epic) }.
        sort_by{ |epic| epic.completed }

    respond_to do |format|
      format.json { render json: epics.to_json(:methods => [:cycle_time, :issues]) }
    end
  end

  def wip
    history = @project.complete_wip_history.
        select{ |date, _| @filter.allow_date(date) }

    respond_to do |format|
      format.json { render json: history.to_json }
    end
  end

private

  def set_project
    @project = Project.find(params[:id])
  end

  def set_filter
    @filter = DateFilter.new(params[:filter] || "")
  end
end