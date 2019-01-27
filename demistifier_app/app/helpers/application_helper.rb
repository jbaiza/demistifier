module ApplicationHelper

  def get_application_queue_priority_tooltip(application, session)
    text = []
    if application.choose_not_to_receive
      text << t("priority_tooltip.choose_not_to_receive")
    else
      if time = session[:calculation_time]
        time = Time.parse(time) if time.is_a? String
      end
      if (time && time > application.desirable_start_date)
        text << "#{t("priority_tooltip.desirable_start_date_before")} #{l(time.to_date)}"
      elsif (!time && application.sort_index & 128 == 128)
        text << t("priority_tooltip.start_date_in_past")
      end
      if application.priority_5years_old && application.priority_child_local
        text << t("priority_tooltip.priority_5years_old")
      end
      if application.priority_commission
        text << t("priority_tooltip.priority_commission")
      end
      if application.priority_sibling
        text << t("priority_tooltip.priority_sibling")
      end
      if application.priority_parent_local && application.priority_child_local
        text << t("priority_tooltip.priority_parent_child_local")
      end
      if application.priority_child_local
        text << t("priority_tooltip.priority_child_local")
      end
      unless application.priority_parent_local && application.priority_child_local
        text << t("priority_tooltip.not_declared")
      end
    end
    text.join("&#013;")
  end

  def convert_to_months_years(time_in_years)
    time_in_years = time_in_years * 12
    years = (time_in_years / 12).round
    months = (time_in_years - years * 12).round
    text = []
    if years > 0
      text << "#{years} #{t(:year, count: years)}"
    end
    if years == 0 || months > 0
      text << "#{months} #{t(:month, count: months)}"
    end
    text.join(" ")
  end
end
