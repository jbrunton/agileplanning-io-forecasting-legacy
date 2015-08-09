class Backlog
  attr_reader :in_progress
  attr_reader :upcoming

  def initialize(in_progress, upcoming)
    @in_progress = in_progress
    @upcoming = upcoming
  end

  class Builder
    def initialize(dashboard, issue_type)
      @dashboard = dashboard
      @issue_type = issue_type
    end

    def build
      backlog = @dashboard.issues.
          select { |issue| issue.issue_type == @issue_type && !issue.completed? }

      in_progress = backlog.
          select{ |issue| issue.started? }

      upcoming = backlog.
          select{ |issue| !issue.started? }

      Backlog.new(in_progress, upcoming)
    end
  end
end