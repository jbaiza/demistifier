module ApplicationHelper

  def get_application_queue_priority_tooltip(application)
    text = []
    if application.sort_index & 128 == 128
      text << "Desirable start date in past"
    end
    if application.choose_not_to_receive
      text << "Choose not to receive invitation"
    else
      if application.priority_5years_old && application.priority_child_local
        text << "Older than 5 years"
      end
      if application.priority_commission
        text << "Priority by commission decision"
      end
      if application.priority_sibling
        text << "Sibling in institution"
      end
      if application.priority_parent_local && application.priority_child_local
        text << "Child and parents declared in Riga"
      end
      if application.priority_child_local
        text << "Child declared in Riga"
      end
      unless application.priority_parent_local && application.priority_child_local
        text << "Not declared in Riga"
      end
    end
    text.join('&#013;')
  end

  def convert_to_months_years(time_in_years)
    time_in_years = time_in_years * 12
    years = (time_in_years / 12).round
    months = (time_in_years - years * 12).round
    text = []
    if years > 0
      text << "#{years} #{'year'.pluralize(years)}"
    end
    if years == 0 || months > 0
      text << "#{months} #{'month'.pluralize(months)}"
    end
    text.join(' ')
  end
end
