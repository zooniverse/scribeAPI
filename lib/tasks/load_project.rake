

desc 'creates a poject object from the project directory'

  task :project_load, [:project_key] => :environment do |task, args|
    project_dir = Rails.root.join('project', args[:project_key])
    project_file_path = "#{project_dir}/project.json"
    project_hash = JSON.parse File.read(project_file_path)

    # load project_file_path
    project = Project.find_or_create_by key: args[:project_key]
    project.update({
      title: project_hash['title'],
      short_title: project_hash['short_title'],
      summary: project_hash['summary'],
      organizations: project_hash['organizations'],
      background: project_hash['background'],
      team: project_hash['team'],
      forum: project_hash['forum'],
      pages: []
    })

    # copy background image to assets directory
    background_file_path = Dir.glob("#{project_dir}/#{project.background}")
    background_file_dest = Rails.root.join("public")

    if project.background.nil?
      puts "WARN: No background image found. Using example_project default."
    end

    copy(background_file_path, background_file_dest, verbose: false)

    puts "Project: Created '#{project.title}'"

    # Load pages from content/*:
    content_path = Rails.root.join('project', args[:project_key], 'content')
    puts "Loading pages from #{content_path}:"
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

    styles_path = Rails.root.join('project', args[:project_key], 'styles.css')
    if File.exist? styles_path
      styles = File.read styles_path
      puts "Loading #{styles.size}b of custom CSS"
      project.styles = styles
    end

    project.save

    begin
      Rake::Task['project_setup'].invoke(args[:project_key])

      puts "Done loading \"#{project.title}\" with #{project.workflows.count} workflow(s), #{project.subject_sets.count} subject sets."

    rescue Exception => e  
      # If a workflow json can't be parsed, halt:
      puts ""
      puts "ERROR: #{e.inspect}"
      puts "Halting: #{e.message}"
    end
  end
