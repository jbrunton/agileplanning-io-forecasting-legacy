class BacklogBuilder
  def initialize(project, issue_type)
    @project = project
    @issue_type = issue_type
  end

  def build
    backlog = @project.issues.
        select { |issue| issue.issue_type == @issue_type && !issue.completed? }

    in_progress = backlog.
        select{ |issue| issue.started? }

    upcoming = backlog.
        select{ |issue| !issue.started? }

    { in_progress: in_progress, upcoming: upcoming }
  end
end