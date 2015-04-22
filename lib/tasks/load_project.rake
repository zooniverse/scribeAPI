

desc 'creates a poject object from the project directory'

  task :project_load, [:project_name] => :environment do |task, args|
    project_dir = Rails.root.join('project', args[:project_name])
    project_file_path = "#{project_dir}/project.rb"

    load project_file_path
    project = Project.find_or_create_by title: Specific_project[:title]
    project.update({
      short_title: Specific_project[:short_title],
      summary: Specific_project[:summary],
      organizations: Specific_project[:organizations],
      background: Specific_project[:background],
      team: Specific_project[:team],
      forum: Specific_project[:forum],
      pages: []
    })

    # copy background image to assets directory
    background_file_path = Dir.glob("#{project_dir}/#{project.background}")
    background_file_dest = Rails.root.join("app", "assets", "images")
    copy(background_file_path, background_file_dest, verbose: false)

    puts "Project: Created '#{project.title}'"

    # Load pages from content/*:
    content_path = Rails.root.join('project', args[:project_name], 'content')
    Dir.foreach(content_path).each do |file|
      path = Rails.root.join content_path, file
      next if File.directory? path

      ext = file[(0...file.index('.'))]
      page_key = file.split('.').first
      name = page_key.capitalize
      content = File.read path

      puts "  Loading page: \"#{name}\" (#{content.size}b)"
      if page_key == 'home'
        project.home_page_content = content

      else
        project.pages << {
          key: page_key,
          name: name,
          content: content
        }
      end
    end

    project.save

    Rake::Task['project_setup'].invoke(args[:project_name])
    # binding.pry
  end
