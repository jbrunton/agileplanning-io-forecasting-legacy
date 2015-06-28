crumb :dashboards do
  link 'Dashboards', dashboards_path
end

crumb :dashboard do |dashboard|
  link dashboard.name, dashboard_path(dashboard)
  parent :dashboards
end

crumb :reports do |dashboard|
  link 'Reports', dashboard_reports_path(dashboard)
  parent :dashboard, dashboard
end

crumb :control_chart do |dashboard|
  link 'Control Chart', dashboard_reports_control_chart_path(dashboard)
  parent :reports, dashboard
end

crumb :forecast_report do |dashboard|
  link 'Forecast', dashboard_reports_forecast_path(dashboard)
  parent :reports, dashboard
end

# crumb :project_issues do |dashboard|
#   link "Issues", project_issues_path(dashboard)
#   parent :dashboard, dashboard
# end

# crumb :issue do |issue|
#   link issue.title, issue_path(issue)
#   parent :project_issues, issue.dashboard
# end

# If you want to split your breadcrumbs configuration over multiple files, you
# can create a folder named `config/breadcrumbs` and put your configuration
# files there. All *.rb files (e.g. `frontend.rb` or `products.rb`) in that
# folder are loaded and reloaded automatically when you change them, just like
# this file (`config/breadcrumbs.rb`).