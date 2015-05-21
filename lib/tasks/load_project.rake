

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
      Rake::Task['load_workflows'].invoke project.key
      Rake::Task['project_setup'].invoke project.key

      puts "Done loading \"#{project.title}\" with #{project.workflows.count} workflow(s), #{project.subject_sets.count} subject sets."

    rescue Exception => e  
      # If a workflow json can't be parsed, halt:
      puts ""
      puts "ERROR: #{e.inspect}"
      puts "Halting: #{e.message}"
    end
  end


  desc "loads workflow jsons from workflows/*.json"
  task :load_workflows, [:project_key] => :environment do |task, args|
    project = Project.find_by key: args[:project_key]
    project.workflows.destroy_all

    workflows_path = Rails.root.join('project', args[:project_key], 'workflows', '*.json')
    puts "Workflows: Loading workflows from #{workflows_path}"

    Dir.glob(workflows_path).each do |workflow_hash_path|
      content = File.read(workflow_hash_path) # .gsub(/\n/, '')
      begin
        next if content == ''

        workflow_hash = JSON.parse content
        workflow_hash.deep_symbolize_keys!
        workflow_hash[:project] = project
        workflow = Workflow.create workflow_hash
        puts "  Loaded '#{workflow.name}' workflow with #{workflow.tasks.count} task(s)"

        if workflow.generates_subjects && ! workflow.generates_subjects_for
          puts "    WARN: #{workflow.name} generates subjects, but generates_subjects_for not set"
        end
      rescue => e
        puts "  WARN: Couldn't parse workflow from #{workflow_hash_path}: #{e}"
        raise "Error parsing #{workflow_hash_path}"
      end
    end

    puts "  WARN: No mark workflow found" if project.workflows.find_by(name: 'mark').nil?
  end
