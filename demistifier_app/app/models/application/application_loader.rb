class Application::ApplicationLoader

  attr_reader :load_time

  def initialize
    @load_time = Time.now
    @imported_application_ids = []
    @not_found_institution_id = []
    @applications_processed = 0
  end

  def import_data
    Dir.glob('../../shared/data/applications/KgApplications2_*.json').each do |file_path|
      puts "Loading file #{file_path}"
      if applications = JSON.parse(File.open(file_path).read).dig('value')
        load_application_records(applications)
      end
    end
    puts "Not found IDs: #{@not_found_institution_id.uniq.join(',')}"
    ids_to_delete = Application.where("id NOT IN (?)", @imported_application_ids)
    Application.delete(ids_to_delete) if ids_to_delete.present?

    InstitutionProgramLanguage.calculate_queue_size
    calculate_riga_queue_position
    calculate_real_queue_position

    save_history
    save_load_date
  end

  def load_application_records(applications)
    applications.each do |application|
      institution = Institution.find_by(institution_id_source: application['institution_id'])
      unless institution
        puts "Institution not found"
        @not_found_institution_id << application['institution_id']
        next
      end
      program_language = InstitutionProgramLanguage.find_or_create_by(
        institution: institution,
        starting_age: application['program_starting_age'],
        language: application['group_language'].encode("UTF-8"),
        language_en: application['group_language_en']
      )
      child = Child.find_or_create_by(child_uid: application['child_uid'])
      application_id = application['id']
      if db_application = Application.find_by(id: application_id)
        db_application.update(get_application_params_from_json(application))
      else
        db_application = Application.create({
          id: application_id,
          institution_program_language: program_language,
          child: child,
          registered_date: Date.parse(application['application_registered_date']),
        }.merge(get_application_params_from_json(application))
        )
      end
      @imported_application_ids << application_id
      @applications_processed += 1
      puts "Processed #{@applications_processed} applications" if @applications_processed % 1000 == 0
    end
  end

  def get_application_params_from_json(application)
    data = {
      desirable_start_date: Date.parse(application['desirable_start_date']),
      priority_5years_old: application['priority_5years_old'] == 1,
      priority_commission: application['priority_commission'] == 1,
      priority_sibling: application['priority_sibling'] == 1,
      priority_parent_local: application['priority_parent_reg_localgov'] == 1,
      priority_child_local: application['priority_child_reg_localgov'] == 1,
      private_fin_local: application['private_kg_fin_by_localgov'] == 1,
      nanny_fin_local: application['nanny_fin_by_localgov'] == 1,
      choose_not_to_receive: application['chose_not_to_receive_inv'] == 1
    }
    data.merge(sort_index: Application.calculate_sort_index(data, load_time))
  end

  def calculate_riga_queue_position
    puts "Calculate Riga queue"
    ActiveRecord::Base.connection.execute(
      "UPDATE applications a
      SET riga_queue_position = (
        SELECT COUNT(*) + 1
        FROM applications b
        WHERE a.institution_program_language_id = b.institution_program_language_id
          AND a.id > b.id
      )"
    )
  end

  def calculate_real_queue_position
    puts "Calculate real queue"
    ActiveRecord::Base.connection.execute(
      "UPDATE applications a
      SET real_queue_position = (
        SELECT COUNT(*) + 1
        FROM applications b
        WHERE a.institution_program_language_id = b.institution_program_language_id
          AND (a.sort_index < b.sort_index OR (a.sort_index = b.sort_index AND a.id > b.id))
      )"
    )
  end

  def save_history
    puts "Save history"
    @applications_processed = 0
    Application.all.each do |application|
      last_history = ApplicationHistory.
        where(institution_program_language_id: application.institution_program_language_id, child_id: application.child_id).
        order(id: :desc).first
      history_atributes = last_history.attributes.except("id", "sort_index", "created_at", "updated_at", "load_date") if last_history
      application_attributes = application.attributes.except("id", "sort_index", "created_at", "updated_at")
      if history_atributes != application_attributes
        ApplicationHistory.create(application_attributes.merge(load_date: load_time))
      end
      @applications_processed += 1
      puts "Processed #{@applications_processed} applications" if @applications_processed % 1000 == 0
    end
  end

  def save_load_date
    statistic_measure = StatisticMeasure.find_by(code: "DATA_RELOAD_DATE")
    Statistic.create(statistic_measure_id: statistic_measure.id, value_date: Date.now)
  end
end
