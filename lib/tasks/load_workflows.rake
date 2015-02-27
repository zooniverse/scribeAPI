require Rails.root.join('project', 'example_project', 'project.rb')

desc 'creates a workflow'

    task :workflow_load, [:project_name, :workflow_name] => :environment do |task, args|

      worklow_file_path = Rails.root.join('project', args[:project_name], 'workflows', "#{args[:workflow_name]}.rb")
      load worklow_file_path
      binding.pry
      # Workflow.create({
      #   project_id:
      #   label:
      #   first_task:
      #   tasks:
      #   })


    end
