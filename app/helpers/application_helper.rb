module ApplicationHelper
  def format_datetime(datetime)
    datetime.strftime('%d %b %Y')
  end
end
