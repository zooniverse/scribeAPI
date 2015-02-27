require Rails.root.join('project', 'example_project', 'project.rb')

desc 'creates a workflow'

    task :workflow_load, [:project_name, :project_id, :workflow_name] => :environment do |task, args|

      worklow_file_path = Rails.root.join('project', args[:project_name], 'workflows', "#{args[:workflow_name]}.rb")
      load worklow_file_path
      workflow = Workflow.create({
        project_id: args[:project_id],
        label: Mark_workflow[:label],
        first_task: Mark_workflow[:first_task],
        tasks: Mark_workflow[:tasks]
        })

      binding.pry

    end
