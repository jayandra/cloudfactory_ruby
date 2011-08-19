module Cf
  class LineYamlValidator

    def self.validate(yaml_path)
      line_dump = YAML::load(File.read(yaml_path))
      errors = []
      # Checking Department
      if line_dump['department'].nil?
        errors << "The line Department is missing!"
      end

      # Checking Input Formats
      input_formats = line_dump['input_formats']
      if input_formats.nil?
        errors << "The Input Format is missing!"
      else
        if input_formats.class == Array
          input_formats.each_with_index do |input_format, index|
            name = input_format['name']
            required = input_format['required']
            valid_type = input_format['valid_type']
            if name.nil?
              errors << "Input Format name is missing in Block #{index+1}!"
            end
          end
        end
      end

      # Checking Stations
      stations = line_dump['stations']
      if stations.nil?
        errors << "Station is missing!"
      else
        if stations.class == Array
          if stations.first['station'].nil?
            errors << "Station Settings missing!"
          else
            stations.each_with_index do |station, i|
              station_index = station['station']['station_index']
              errors << "Station Index is missing in Block station #{i+1}!" if station_index.nil?

              station_type = station['station']['station_type']
              errors << "Station type is missing in Block station #{i+1}!" if station_type.nil?

              if station_type == "tournament"
                jury_worker = station['station']['jury_worker']
                if jury_worker.nil?
                  errors << "Jury worker setting is missing in Block station #{i+1}!"
                elsif !jury_worker.nil?
                  reward = jury_worker['reward']
                  errors << "Reward for Jury worker is missing in block of Tournament Station #{i+1}!" if reward.nil?
                  errors << "Reward Must be greater than 0 in Block station #{i+1}!" if !reward.nil? && reward < 1
                end
              end
              # Checking Worker
              worker = station['station']['worker']
              if worker.class != Hash
                errors << "Worker is missing in Block station #{i+1}!" 
              elsif worker.class == Hash
                # Checking Worker type
                worker.each_pair do |k, v|
                  errors << "Should not be an array" if v.class == Array && k != "skill_badges"
                end
                worker_type = worker['worker_type']
                if worker_type.nil?
                  errors << "Worker Type is missing!"
                else
                  if worker_type != "human" 
                    errors << "Worker type is invalid in Block station #{i+1}!" if worker_type.split("_").last != "robot"
                    if worker_type.split("_").last == "robot"
                      settings = worker['settings']
                      errors << "Settings for the robot worker is missingin Block station #{i+1}!" if settings.nil?
                    end
                  elsif worker_type == "human" 
                    # Checking number of workers if worker_type == "human"
                    num_workers = worker['num_workers']
                    if num_workers.nil?
                      errors << "Number of workers not specified in Block station #{i+1}!"
                    else
                      errors << "Number of workers must be greater than 0 in Block station #{i+1}!" if num_workers < 1
                    end

                    # Checking reward of workers if worker_type == "human"
                    reward = worker['reward']
                    if reward.nil?
                      errors << "Reward of workers not specified in Block station #{i+1}!" 
                    else
                      errors << "Reward of workers must be greater than 0 in Block station #{i+1}!" if reward < 1
                    end
                  end
                end
              end

              if station_type != "improve"
                # Checking Stat_badge
                stat_badge = station['station']['worker']['stat_badge']
                if !stat_badge.nil?
                  errors << "Stat badge setting is invalid in Block station #{i+1}!" if stat_badge.class != Hash
                end

                # Checking skill_badge
                skill_badges = station['station']['worker']['skill_badges']
                if !skill_badges.nil?
                  errors << "Skill badge settings is invalid in Block station #{i+1}!" if skill_badges.class != Array
                  skill_badges.each_with_index do |badge, badge_index|
                    badge_title = badge['title']
                    badge_description = badge['description']
                    max_badges = badge['max_badges']
                    badge_test = badge['test']
                    test_input = badge_test['input'] if badge_test.class == Hash
                    expected_output = badge_test['expected_output'] if badge_test.class == Hash
                    errors << "Skill badge title is Missing in Block #{badge_index+1}!" if badge_title.nil?
                    errors << "Skill badge Description is Missing in Block #{badge_index+1}!" if badge_description.nil?
                    errors << "Skill badge max_badges must be greater than 1000 in Block #{badge_index+1}!" if max_badges < 1000 && !max_badges.nil?
                    errors << "Skill badge Test is Missing in Block #{badge_index+1}!" if badge_test.nil?
                    errors << "Skill badge Test is Invalid (must be Hash) in Block #{badge_index+1}!" if badge_test.class != Hash && !badge_test.nil?
                    errors << "Skill badge Test input is Missing in Block #{badge_index+1}!" if test_input.nil? && !badge_test.nil?
                    errors << "Skill badge Test input is Invalid (must be Hash) in Block #{badge_index+1}!" if  test_input.class != Hash && !test_input.nil? && !badge_test.nil?
                    errors << "Skill badge Test expected_output is Missing in Block #{badge_index+1}!" if expected_output.nil? && !badge_test.nil?
                    errors << "Skill badge Test expected_output is Invalid (must be an array) in Block #{badge_index+1}!" if expected_output.class != Array && !expected_output.nil? && !badge_test.nil?
                  end
                end

                # Checking TaskForm
                if worker_type == "human"
                  task_form = station['station']['task_form']
                  if task_form.nil?
                    custom_task_form = station['station']['custom_task_form']
                    if custom_task_form.nil?
                      errors << "Form is missing in Block station #{i+1}!"
                    elsif custom_task_form.class == Hash
                      form_title = custom_task_form['form_title']
                      errors << "Form Title is missing in Block station #{i+1}!" if form_title.nil?

                      instruction = custom_task_form['instruction']
                      errors << "Form Instruction is missing in Block station #{i+1}!" if instruction.nil?
                    end
                  elsif task_form.class == Hash
                    form_title = task_form['form_title']
                    errors << "Form Title is missing in Block station #{i+1}!" if form_title.nil?

                    instruction = task_form['instruction']
                    errors << "Form Instruction is missing in Block station #{i+1}!" if instruction.nil?

                    # Checking Form Fields
                    form_fields = task_form['form_fields']
                    errors << "Form Field is missing in Block station #{i+1}!" if form_fields.nil?
                    if form_fields.class == Array
                      form_fields.each_with_index do |form_field, index|
                        field_label = form_field['label']
                        errors << "Label is missing in block #{index+1} of Form Field within Station #{i+1}!" if field_label.nil?
                        required = form_field['required']
                        field_type = form_field['field_type']
                        if !field_type.nil?
                          unless %w(short_answer long_answer radio_button check_box select_box date email number).include?(field_type)
                            errors << "Field Type of Form Field is invalid in Block #{index+1} of station Block #{i+1}!"
                          end
                          if field_type == "radio_button" || field_type == "select_box"
                            option_values = form_field['option_values']
                            if option_values.nil?
                              errors << "Option values is required for field_type => #{field_type} in block #{index+1} of Form Field within Station #{i+1} !"
                            elsif !option_values.nil?
                              if option_values.class != Array
                                errors << "Option values must be an array for field_type => #{field_type} in block #{index+1} of Form Field within Station #{i+1}!"  
                              end
                            end
                          end
                        end
                      end
                    else
                      errors << "Form fields must be an array for Station #{i+1}!"
                    end
                  end
                end
              end
            end
          end
        end
      end
      return errors
    end
  end
end