crumb :projects do
  link 'Projects', projects_path
end

crumb :project do |project|
  link project.name, project_path(project)
  parent :projects
end

crumb :reports do |project|
  link 'Reports', project_reports_path(project)
  parent :project, project
end

crumb :control_chart do |project|
  link 'Control Chart', project_reports_control_chart_path(project)
  parent :reports, project
end

crumb :forecast_report do |project|
  link 'Forecast', project_reports_forecast_path(project)
  parent :reports, project
end

# crumb :project_issues do |project|
#   link "Issues", project_issues_path(project)
#   parent :project, project
# end

# crumb :issue do |issue|
#   link issue.title, issue_path(issue)
#   parent :project_issues, issue.project
# end

# If you want to split your breadcrumbs configuration over multiple files, you
# can create a folder named `config/breadcrumbs` and put your configuration
# files there. All *.rb files (e.g. `frontend.rb` or `products.rb`) in that
# folder are loaded and reloaded automatically when you change them, just like
# this file (`config/breadcrumbs.rb`).