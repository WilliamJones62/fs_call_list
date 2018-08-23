module ApplicationHelper
  def display_date(date)
    formatted = date.strftime("%e %b %Y")
  end
end
