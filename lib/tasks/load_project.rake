require 'fileutils'

desc 'creates a poject object from the project directory'

  task :project_drop, [:project_key] => :environment do |task, args|

    project = Project.find_by key: args[:project_key]
    puts "Delete project: #{args[:project_key]}"
    if ! project.nil?
      project.destroy
    end

  end

  task :project_load, [:project_key] => :environment do |task, args|
    project_dir = Rails.root.join('project', args[:project_key])
    project_file_path = "#{project_dir}/project.json"
    project_hash = JSON.parse File.read(project_file_path)

    # load project_file_path
    project = Project.find_or_create_by key: args[:project_key]

    # Set all valid fields from hash:
    project_hash = project_hash.inject({}) { |h, (k,v)| h[k] = v if Project.fields.keys.include?(k.to_s); h }
    project.update project_hash

<<<<<<< HEAD
=======
    # load background and logo
    if project.background.nil?
      puts "WARN: No background image found."
    else
      print 'Loading background file...'
      background_file_path = "#{project_dir}/#{File.basename(project.background)}"
      background_file_dest = Rails.root.join("app/assets/images")
      cp(background_file_path, background_file_dest, verbose: false)
      puts 'Done.'
    end

    if project.logo.nil?
      puts "WARN: No logo image found."
    else
      print 'Loading logo file...'
      logo_file_path = "#{project_dir}/#{File.basename(project.logo)}"
      logo_file_dest = Rails.root.join("app/assets/images")
      cp(logo_file_path, logo_file_dest, verbose: true)
      puts 'Done.'
    end

>>>>>>> 22c849ee036e9eb6966968b08ae03820963a198d
    puts "Created project: #{project.title}"

    # Load pages from content/*:
    content_path = Rails.root.join('project', args[:project_key], 'content')
    puts "Loading pages from #{content_path}:"

    prev_pages = project.pages
    project.pages = []

    Dir.foreach(content_path).each do |file|
      path = Rails.root.join content_path, file
      next if File.directory? path
      next if ! ['.html','.erb','.md'].include? path.extname
      ext = path.extname
      page_key = file.split('.').first
      name = page_key.capitalize
      content = File.read path

      puts "  Loading page: \"#{name}\" (#{content.size}b)"
      if page_key == 'home'
        project.home_page_content = content

      else
        # Set updated at if content changed:
        updated_at = Time.now
        if ! prev_pages.nil? && ! prev_pages.empty?
          previous_page = prev_pages.select { |p| p[:key] == page_key }
          if ! previous_page.empty? && (previous_page = previous_page.first)
            updated_at = ! previous_page[:updated_at].nil? && previous_page[:content] == content ? previous_page[:updated_at] : Time.now
          end
        end

        project.pages << {
          key: page_key,
          name: name,
          content: content,
          updated_at: updated_at
        }
      end
    end
    
    load_images(args[:project_key]) 

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

    # rescue Exception => e
      # If a workflow json can't be parsed, halt:
      puts ""
      # puts "ERROR: #{e.inspect}"
     #  puts "Halting: #{e.message}"
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

        puts "  Loading '#{workflow_hash[:name]}' workflow"

        workflow_hash[:project] = project

        tasks = workflow_hash.delete :tasks
        if tasks.is_a? Hash
          tasks = tasks.inject([]) do |a, (task_key, task_config)|
            task_config[:key] = task_key.to_s
            # Remove any config params not officially declared as fields of WorkflowTask:
            task_config = task_config.inject({}) { |h, (k,v)| h[k] = v if WorkflowTask.fields.keys.include?(k.to_s); h }
            a << task_config
          end
        end
        workflow_hash[:tasks] = tasks

        workflow_hash = load_help_text workflow_hash, args[:project_key]

        workflow = Workflow.create workflow_hash
        puts "    Loaded #{workflow.tasks.count} task(s)"

        if workflow.generates_subjects && ! workflow.generates_subjects_for
          puts "    WARN: #{workflow.name} generates subjects, but generates_subjects_for not set"
        end
      # rescue => e
       #  puts "  WARN: Couldn't parse workflow from #{workflow_hash_path}: #{e}"
        # raise "Error parsing #{workflow_hash_path}"
      end
    end

    # Order workflows such that each appears before any workflows it generates subjects for
    project.workflows.each do |w|
      w.update_attribute :order, project.workflows.size - num_downstream_workflows(w) - 1
    end

    puts "  WARN: No mark workflow found" if project.workflows.find_by(name: 'mark').nil?
  end

  def load_images(project_key)
    image_path = Rails.root.join('project', project_key, 'images/')
    puts "Loading images from #{image_path}:"

    Dir.foreach(image_path).each do |file|
      puts " -- #{file}"
      path = Rails.root.join image_path, file
      next if File.directory? path
      next if ! ['.png','.gif','.jpg', '.jpeg'].include? path.extname
      image_dest = Rails.root.join("app/assets/images/#{project_key}/")
      Dir.mkdir(image_dest) unless File.exists?(image_dest)
      cp(path, image_dest, verbose: false)
    end
  end

  def load_help_text(h, project_key)
    if h.respond_to? :each
      if h.is_a? Hash
        h.keys.each do |k,v|
          if k == :help && h[k].is_a?(Hash) && ! h[k][:file].nil?
            help_file_path = Rails.root.join('project', project_key, 'content', 'help', h[k][:file] + ".md")
            if File.exist? help_file_path
              content = File.read(help_file_path)
              # Look for #Title defined in md
              title_reg = /^# ?(.+)/
              # If title found, set title and remove it from body
              if ! (title = content.match(title_reg)).nil?
                h[k][:title] = title[1]
                content.sub! title_reg, ''
                content.sub! /^\n+/, ''
              end
              h[k][:body] = content
              puts "    Loaded help file: #{h[k][:file]}"

            else
              puts "    WARN: Couldn't find #{help_file_path}"
            end

          else
            h[k] = load_help_text h[k], project_key
          end
        end
      else
        h.each_with_index do |v, k|
          h[k] = load_help_text h[k], project_key
        end
      end
    end
    h
  end

  def num_downstream_workflows(w, prev_count=0)
    if w.next_workflow.nil?
      prev_count
    else
      num_downstream_workflows(w.next_workflow, prev_count + 1)
    end
  end
