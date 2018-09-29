class Application < ApplicationRecord
  belongs_to :institution_program_language
  belongs_to :child

  def self.import_data
    @load_time = Time.now
    @imported_application_ids = []
    @not_found_institution_id = []
    Dir.glob('../data/kg_app/KgApplications2_*.json').each do |file_path|
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
  end

  def self.load_application_records(applications)
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
    end
  end

  def self.get_application_params_from_json(application)
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
    data.merge(sort_index: calculate_sort_index(data, @load_time))
  end

  def self.calculate_riga_queue_position
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

  def self.calculate_real_queue_position
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

  def self.calculate_sort_index(data, load_time)
    sort_index = 0
    if data[:desirable_start_date] <= load_time
      sort_index |= 128
    end
    if data[:choose_not_to_receive]
      sort_index |= 1
    else
      if data[:priority_5years_old] && data[:priority_child_local]
        sort_index |= 64
      end
      if data[:priority_commission]
        sort_index |= 32
      end
      if data[:priority_sibling]
        sort_index |= 16
      end
      if data[:priority_parent_local] && data[:priority_child_local]
        sort_index |= 8
      end
      if data[:priority_child_local]
        sort_index |= 4
      end
      unless data[:priority_parent_local] && data[:priority_child_local]
        sort_index |= 2
      end
    end
    sort_index
  end
  # 1000 0000 Pienācis iestāšanās laiks
  # 0100 0000 Obligātais vecums
  # 0010 0000 Komisijas lēmums
  # 0001 0000 Brālis/Māsa
  # 0000 1000 Gan vecāks, gan bērns deklarēts
  # 0000 0100 Bērns deklarēts, vecāki nav
  # 0000 0010 Bērns nav deklarēts
  # 0000 0001 Nevēlas saņemt
end
