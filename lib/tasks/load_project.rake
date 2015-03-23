
desc 'creates a poject object from the project directory'

  task :project_load, [:project_name] => :environment do |task, args|
    project_file_path = Rails.root.join('project', args[:project_name], 'project.rb')
    load project_file_path
    project = Project.create({
        title: Specific_project[:title],
        summary: Specific_project[:summary],
        # home_page_content: Specific_project[:home_page_content],
        organizations: Specific_project[:organizations] ,
        team: Specific_project[:team],
        # pages: Specific_project[:pages],
      })

  end
