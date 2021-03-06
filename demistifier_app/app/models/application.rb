class Application < ApplicationRecord
  belongs_to :institution_program_language
  belongs_to :child

  def self.import_data
    ApplicationLoader.new.import_data
  end

  def self.recalculate_sort_index
    load_time = Time.now
    Application.all.each{|a| a.recalculate_sort_index(load_time)}
    ApplicationLoader.new.calculate_real_queue_position
  end

  def recalculate_sort_index(load_time)
    self.sort_index = Application.calculate_sort_index(self, load_time)
    save
  end

  def self.calculate_sort_index(data, load_time)
    sort_index = 0
    if data[:choose_not_to_receive]
      sort_index |= 1
    else
      if data[:desirable_start_date] <= load_time
        sort_index |= 128
      end
      if data[:priority_5years_old] && data[:priority_child_local]
        sort_index |= 64
      elsif data[:priority_commission]
        sort_index |= 32
      elsif data[:priority_sibling]
        sort_index |= 16
      elsif data[:priority_parent_local] && data[:priority_child_local]
        sort_index |= 8
      elsif data[:priority_child_local]
        sort_index |= 4
      else
        sort_index |= 2
      end
    end
    sort_index
  end

  def self.calculate_program_applications_real_queue_position(applications, session)
    if time = session[:calculation_time]
      time = Time.parse(time) if time.is_a? String
      applications = applications.sort_by { |a| [Application.calculate_sort_index(a, time), -a.riga_queue_position] }.reverse!
      applications.each_with_index do |app, index|
        app.real_queue_position = index + 1
      end
      applications
    else
      applications
    end
  end

  def real_queue_position_calculated(session)
    if time = session[:calculation_time]
      time = Time.parse(time) if time.is_a? String
      Application.where(institution_program_language_id: institution_program_language_id).
        sort_by { |a| [Application.calculate_sort_index(a, time), -a.riga_queue_position] }.reverse.index(self) + 1
    else
      real_queue_position
    end
  end

  def waiting_time
    return 0 unless institution_program_language.avg_invited
    (real_queue_position / institution_program_language.avg_invited)
  end
  # 1000 0000 Pienācis iestāšanās laiks
  # 0100 0000 Obligātais vecums
  # 0010 0000 Komisijas lēmums
  # 0001 0000 Brālis/Māsa
  # 0000 1000 Gan vecāks, gan bērns deklarēts
  # 0000 0100 Bērns deklarēts, vecāki nav
  # 0000 0010 Bērns nav deklarēts
  # 0000 0001 Nevēlas saņemt


  def self.validate_data_with_eriga
    agent = Mechanize.new
    incorrect_data = {}
    choose_not_to_receive_differs = 0
    priority_5years_old_differs = 0
    priority_commission_differs = 0
    priority_sibling_differs = 0
    priority_parent_local_differs = 0
    priority_child_local_differs = 0
    desirable_start_date_differs = 0
    total = 0
    Dir.glob('../data/from_eRiga/*').each do |file_path|
      url = "file:///Users/janis.baiza/Repositories/demistifier/demistifier_app/#{file_path}"
      agent.get(url) do |page|
        if page.code.to_i == 200
          institution_name = page.search(:css, '#ctl00_phContent_detailsControl_lblDetailsName').first.text
          unless institution = Institution.where("name LIKE ? OR alternate_names LIKE ?",
              institution_name.gsub('"', '_'), institution_name.gsub('"', '_')).first
            puts "ERROR: NOT FOUND #{institution_name}"
            next
          end
          group_language = page.search(:css, '#ctl00_phContent_detailsControl_lblDetailsLanguage').first.text.downcase
          unless program_language = InstitutionProgramLanguage.find_by(institution_id: institution.id, language: group_language)
            puts "ERROR: LANG NOT FOUND #{institution_name} #{group_language}"
            next
          end
          page.search('table#tableRinda tr').each_with_index do |row, index|
            next if index < 2
            cells = row.search('span')
            registered_date = cells[1].text
            date = cells[2].text.split('.').map{|e| e.to_i}
            desirable_start_date = Date.new(date[2], date[1], date[0])
            child_uid = cells[3].text
            unless child = Child.find_by(child_uid: child_uid)
              puts "ERROR: NO CHILD #{institution_name} #{group_language} #{child_uid}"
              next
            end
            next unless application = Application.find_by(child_id: child.id, institution_program_language_id: program_language.id)
            # <th class="txt_11_black_b" style="width: 50px" tooltip="Neiekļaut uzēnmšanas sarakstā">Neiekļaut uzņ. sar.</th>
            # <th class="txt_11_black_b" style="width: 50px" tooltip="Bērns ir sasniedzis obligāto izglītības vecumu">Obl. vecums</th>
            # <th class="txt_11_black_b" style="width: 50px" tooltip="Bērnam ir piešķirts statuss &quot;Komisijas lēmums&quot;">Kom. lēmums</th>
            # <th class="txt_11_black_b" style="width: 50px" tooltip="Bērnam ir piešķirts statuss &quot;brālis/māsa&quot;">Brālis / māsa</th>
            # <th class="txt_11_black_b" style="width: 50px" tooltip="Vecāku deklarētā dzīvesvieta ir Rīgas pilsētas administratīvajā teritorijā">V.dekl. Rīgā</th>
            # <th class="txt_11_black_b" style="width: 50px" tooltip="Bērna deklarētā dzīvesvieta ir Rīgas pilsētas administratīvajā teritorijā">B.dekl. Rīgā</th>
            choose_not_to_receive = check_priority(cells[4])
            priority_5years_old = check_priority(cells[5])
            priority_commission = check_priority(cells[6])
            priority_sibling = check_priority(cells[7])
            priority_parent_local = check_priority(cells[8])
            priority_child_local = check_priority(cells[9])
            total += 1
            if choose_not_to_receive != application.choose_not_to_receive ||
                priority_5years_old != application.priority_5years_old ||
                priority_commission != application.priority_commission ||
                priority_sibling != application.priority_sibling ||
                priority_parent_local != application.priority_parent_local ||
                priority_child_local != application.priority_child_local ||
                desirable_start_date != application.desirable_start_date
              inst = incorrect_data[institution_name] ||= {}
              lang = inst[group_language] ||= {}
              child_data = lang[child_uid] ||= {}
              if choose_not_to_receive != application.choose_not_to_receive
                child_data.merge!(choose_not_to_receive: true)
                choose_not_to_receive_differs += 1
              end
              if priority_5years_old != application.priority_5years_old
                child_data.merge!(priority_5years_old: true)
                priority_5years_old_differs += 1
              end
              if priority_commission != application.priority_commission
                child_data.merge!(priority_commission: true)
                priority_commission_differs += 1
              end
              if priority_sibling != application.priority_sibling
                child_data.merge!(priority_sibling: true)
                priority_sibling_differs += 1
              end
              if priority_parent_local != application.priority_parent_local
                child_data.merge!(priority_parent_local: true)
                priority_parent_local_differs += 1
              end
              if priority_child_local != application.priority_child_local
                child_data.merge!(priority_child_local: true)
                priority_child_local_differs += 1
              end
              if desirable_start_date != application.desirable_start_date
                child_data.merge!(desirable_start_date: true)
                desirable_start_date_differs += 1
              end
            end
          end
        else
          puts "ERROR"
        end
      end
    end
    [total, choose_not_to_receive_differs, priority_5years_old_differs, priority_commission_differs,
      priority_sibling_differs, priority_parent_local_differs, priority_child_local_differs, desirable_start_date_differs]
  end

  def self.check_priority(cell)
    cell.search('.has-value').count > 0
  end

  def self.load_from_eriga
    agent = Mechanize.new
    load_time = Time.now
    Dir.glob('../data/from_eRiga/*').each do |file_path|
      url = "file:///Users/janis.baiza/Repositories/demistifier/demistifier_app/#{file_path}"
      agent.get(url) do |page|
        if page.code.to_i == 200
          institution_name = page.search(:css, '#ctl00_phContent_detailsControl_lblDetailsName').first.text
          unless institution = Institution.where("name LIKE ? OR alternate_names LIKE ?",
              institution_name.gsub('"', '_'), institution_name.gsub('"', '_')).first
            puts "ERROR: NOT FOUND #{institution_name}"
            next
          end
          group_language = page.search(:css, '#ctl00_phContent_detailsControl_lblDetailsLanguage').first.text.downcase
          unless program_language = InstitutionProgramLanguage.find_by(institution_id: institution.id, language: group_language)
            puts "ERROR: LANG NOT FOUND #{institution_name} #{group_language}"
            next
          end
          page.search('table#tableRinda tr').each_with_index do |row, index|
            next if index < 2
            cells = row.search('span')
            date, time = cells[1].text.split("\u00A0\u00A0")
            date = date.split('.')
            time = time.split(':')
            registered_date = Time.new(date[2], date[1], date[0], time[0], time[1])
            date = cells[2].text.split('.').map{|e| e.to_i}
            desirable_start_date = Date.new(date[2], date[1], date[0])
            child_uid = cells[3].text
            child = Child.find_or_create_by(child_uid: child_uid)
            choose_not_to_receive = check_priority(cells[4])
            priority_5years_old = check_priority(cells[5])
            priority_commission = check_priority(cells[6])
            priority_sibling = check_priority(cells[7])
            priority_parent_local = check_priority(cells[8])
            priority_child_local = check_priority(cells[9])

            data = {
              desirable_start_date: desirable_start_date,
              priority_5years_old: priority_5years_old,
              priority_commission: priority_commission,
              priority_sibling: priority_sibling,
              priority_parent_local: priority_parent_local,
              priority_child_local: priority_child_local,
              choose_not_to_receive: choose_not_to_receive
            }
            data.merge!(sort_index: calculate_sort_index(data, load_time))

            if application = Application.find_by(child_id: child.id, institution_program_language_id: program_language.id)
              application.update(data)
            else
              Application.create({
                institution_program_language: program_language,
                child: child,
                registered_date: registered_date,
              }.merge(data)
              )
            end
          end
        else
          puts "ERROR"
        end
      end
    end
    true
  end

  def institution_name
    institution_program_language.institution.name
  end

  def language
    institution_program_language.language_en.capitalize
  end

end
