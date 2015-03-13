# require Rails.root.join('project', 'example_project', 'project.rb')

desc 'creates a poject object from the project directory'
  include ActiveModel::Serialization

  task :project_load, [:project_name] => :environment do |task, args|
    project_file_path = Rails.root.join('project', args[:project_name], 'project.rb')
    # Load project-specific project.rb:
    require project_file_path

    project = Project.create({
        title: Specific_project[:title],
        summary: Specific_project[:summary],
        # home_page_content: Specific_project[:home_page_content],
        organizations: Specific_project[:organizations] ,
        team: Specific_project[:team],
        # pages: Specific_project[:pages],
      })
    puts "Project: Created '#{project.title}'"

    Rake::Task['project_setup'].invoke(args[:project_name])
    # binding.pry
  end
