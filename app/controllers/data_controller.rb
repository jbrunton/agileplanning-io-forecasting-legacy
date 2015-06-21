class DataController < ApplicationController
  before_action :set_project, only: [:cycle_times, :wip, :backlog]
  before_action :set_filter, only: [:cycle_times, :wip]

  def cycle_times
    issues = @project.issues.includes(:issues).
        where(issue_type: params[:issue_type]).
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
    history = @project.complete_wip_history(params[:issue_type]).
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

  def backlog
    @backlog = @project.issues.
        select{ |issue| issue.issue_type == params[:issue_type] }.
        select{ |issue| issue.completed.nil? && issue.epic_status != 'Done' }
    @upcoming = @backlog.select{ |issue| !issue.started }
    @in_progress = @backlog.select{ |issue| issue.started }

    respond_to do |format|
      format.json { render json: { in_progress: @in_progress, upcoming: @upcoming } }
    end
  end

private

  def set_project
    @project = Project.find(params[:id])
  end

  def set_filter
    @filter = ::Filters::IssueFilter.new(params[:filter] || "")
  end
end