class SyncProjectJob
  include Celluloid

  def sync_project(project, params)
    project.issues.destroy_all

    jira_client = Jira::Client.new(project.domain, params.permit(:username, :password))
    rapid_board = jira_client.get_rapid_board(project.board_id)

    issues = jira_client.search_issues(query: rapid_board.query, expand: ['changelog']) do |progress|
      WebsocketRails["project:#{project.id}"].trigger(:update, { progress: progress })
    end

    issues.each do |issue|
      project.issues.append(issue)
    end

    project.save

    project.compute_cycle_times!
  end
end