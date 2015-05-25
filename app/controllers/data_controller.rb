class DataController < ApplicationController
  before_action :set_project, only: [:cycle_times, :wip, :epic_cycle_times]
  before_action :set_filter, only: [:cycle_times, :wip, :epic_cycle_times]

  def cycle_times
    epics = @project.issues.includes(:issues).
        where(issue_type: 'Epic').
        select{ |epic| epic.cycle_time && @filter.allow_issue(epic) }.
        sort_by{ |epic| epic.completed }

    trend_builder = Stats::TrendBuilder.new.
        pluck{ |epic| epic.cycle_time }.
        map do |epic, mean, stddev|
          { epic: epic, cycle_time: epic.cycle_time, mean: mean, stddev: stddev }
        end

    trend = trend_builder.analyze(epics)


    respond_to do |format|
      format.json { render json: trend.to_json(:include => :issues)
      }
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