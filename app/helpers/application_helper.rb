module ApplicationHelper
  def format_date(datetime)
    datetime.strftime('%d %b %Y')
  end

  def format_datetime(datetime)
    datetime.strftime('%d %b %Y, %l:%M%P %Z')
  end
end
