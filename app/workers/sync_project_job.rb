class SyncProjectJob
  include Celluloid

  def sync_project(project, params)
    project.issues.destroy_all

    jira_client = Jira::Client.new(project.domain, params.permit(:username, :password))
    rapid_board = jira_client.get_rapid_board(project.board_id)
    jira_client.search_issues(query: rapid_board.query).each do |issue|
      project.issues.append(issue)
    end

    project.save
  end
end