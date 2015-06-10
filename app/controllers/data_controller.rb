class DataController < ApplicationController
  before_action :set_project, only: [:cycle_times, :wip, :epic_cycle_times]
  before_action :set_filter, only: [:cycle_times, :wip, :epic_cycle_times]

  def cycle_times
    query = @project.issues.includes(:issues)
    query = query.where(issue_type: 'Epic') if params[:issue_type] == 'Epic'
    query = query.where.not(issue_type: 'Epic') if params[:issue_type] == 'Story'

    issues = query.
        select{ |issue| issue.cycle_time && @filter.allow_issue(issue) }.
        sort_by{ |issue| issue.completed }

    trend_builder = Stats::TrendBuilder.new.
        pluck{ |issue| issue.cycle_time }.
        map do |issue, mean, stddev|
          { issue: issue, cycle_time: issue.cycle_time, mean: mean, stddev: stddev }
        end

    trend = trend_builder.analyze(issues)


    respond_to do |format|
      format.json { render json: trend.to_json(:include => :issues) }
    end
  end

  def wip
    history = @project.complete_wip_history.
        select{ |date, _| @filter.allow_date(date) }

    trend_builder = Stats::TrendBuilder.new.
        pluck{ |item| item[1].length }.
        map do |item, mean, stddev|
          [item[0], { wip: item[1].length, epics: item[1], mean: mean, stddev: stddev }]
        end

    trend = trend_builder.analyze(history.to_a)

    respond_to do |format|
      format.json { render json: trend.to_h.to_json }
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