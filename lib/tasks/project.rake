require 'fileutils'

namespace :project do

  desc "Load project by key. :area param can be 'content','style','workflows', or 'subjects' (or omitted to load all)."
  task :load, [:project_key, :area] => :environment do |task, args|
    args.with_defaults area: 'all'

    # Validate AREA arg:
    if ! ['all','content','style','workflows','subjects'].include? args[:area]
      puts "Unknown AREA given: #{args[:area]}"
      exit
    end

    project = nil
    # Before proceeding to update anything non-core, confirm we have a project to update:
    if ! ['all','content'].include? args[:area]
      project = Project.find_by key: args[:project_key]

      if project.nil?
        if args[:area] != 'all'
          puts "Before updating #{args[:area]} you must create the project using project:load[#{args[:project_key]}]"
        else
          puts "Halting because project not found"
        end
        exit
      end
    end

    # Load content:
    if ['all','content'].include? args[:area]
      project = load_content args[:project_key]
      puts "Done loading content for \"#{project.title}\""
    end


    # DEPRECATED:
    # Should deprecate this because all static assets can now be fetched directly
    # from project/[key]/assets; There is no need to copy js, images, fonts, etc
    # into app/assets. Serving them directly from the project/../assets folder is
    # preferable because it doesn't clutter app/assets, which should be reserved
    # for core application concerns.
    # Nevertheless, I'm keeping this functionality in place so that projects can
    # gracefully deprecate reliance on copied assets.
    #
    # Load custom styling (css,js,images,fonts, etc):
    if ['all','style'].include? args[:area]
      load_styles project
      puts "Done loading style for \"#{project.title}\""
    end

    # Load workflows:
    if ['all','workflows'].include? args[:area]
      begin
        # Rake::Task['project:load_workflows'].invoke project.key
        load_workflows project.key
      rescue Exception => e
        puts "ERROR: #{e.inspect}"
      end
      puts "Done loading #{project.workflows.count} workflow(s) into \"#{project.title}\""
    end

    # Load subjects:
    if ['all','subjects'].include? args[:area]
      if ! project.workflows.find_by(name: 'mark')
        puts "Can't load subjects before loading a mark workflow! Run rake project:load[#{project.key},workflows] first"
        exit
      end
      Rake::Task['subjects:load_groups'].invoke(project.key)
      puts "Done loading #{project.subject_sets.count} subject sets into \"#{project.title}\""
    end

    if project.status == 'active'
      puts "'#{project.title}' is active"

    elsif Project.active.count == 0
      puts "Activating '#{project.title}'"
      project.activate!

    else
      puts "____________"
      puts "Another project, '#{Project.active.first.title}', is currently active. To activate '#{project.title}', run:"
      puts "  rake project:activate[#{args[:project_key]}]"
    end

    ApplicationController.expire_action_cache 'projects/index.json'
    ApplicationController.expire_action_cache 'home/index'
  end


  desc "List projects and active status"
  task :list, [] => :environment do |task, args|
    args.with_defaults area: 'all'

    puts "Listing projects:"
    Project.all.each do |project|
      puts "  [#{project.status == 'active' ? 'active' : ' ' * 6}] #{project.title}"
    end
  end

  desc "Activate a project by key. Only one project may be active at one time."
  task :activate, [:project_key] => :environment do |task, args|
    args.with_defaults area: 'all'

    project = get_project args[:project_key]
    if ! project.nil?
      puts "Activating #{project.title}"
      project.activate!
    end

    # Rebuild subject-set indexes based on current project:
    Rake::Task['project:create_indexes'].invoke
  end

  def get_project(project_key)
    project = Project.find_by key: project_key
    puts "Failed to find project '#{project_key}'" if project.nil?
    project
  end

  def load_content(project_key)
    project_dir = Rails.root.join('project', project_key)
    project_file_path = "#{project_dir}/project.json"
    project_hash = JSON.parse File.read(project_file_path)

    # load project_file_path
    project = Project.find_or_create_by key: project_key

    # Establish some defaults so that if they're not set in the project hash, we overwrite the old value with the null default
    project_defaults = {
      background: nil,
      logo: nil,
      favicon: nil,
      terms_map: {},
      team_emails: [],
      team: [],
      organizations: [],
      analytics: nil,
      forum: nil,
      menus: {},
      partials: {}
    }
    # Set all valid fields from hash:
    project_hash = project_hash.inject(project_defaults) { |h, (k,v)| h[k] = v if Project.fields.keys.include?(k.to_s); h }
    project.update project_hash

    puts "Created project: #{project.title}"

    # Load pages from content/*:
    content_path = Rails.root.join('project', project_key, 'content')
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

        # Check if we should include group browser content
        group_match = /<!\-\-[\s]*require groups:[\s]*(.*)\-\->/.match(content)
        group_browser = ''
        if group_match && !group_match.captures.empty?
          group_browser = group_match.captures[0]
        end

        project.pages << {
          key: page_key,
          name: name,
          content: content,
          updated_at: updated_at,
          group_browser: group_browser
        }
      end
    end

    # load partial content if exists
    project.partials = {}
    partials_path = Rails.root.join('project', project_key, 'content', 'partials')
    if File.directory? partials_path
      Dir.foreach(partials_path).each do |file|
        path = Rails.root.join partials_path, file
        next if File.directory? path
        next if ! ['.html','.erb','.md'].include? path.extname

        key = file.split('.').first
        content = File.read path
        puts "  Loading partial: \"#{key}\" (#{content.size}b)"

        project.partials[key] = content
      end
    end

    project.tutorial = load_tutorial(project_key)

    project.save
    project
  end

  def load_styles(project)

    load_images(project.key)
    load_fonts(project.key)

    styles_path = Rails.root.join('project', project.key, 'styles.css')
    if File.exist? styles_path
      styles = File.read styles_path
      puts "Loading #{styles.size}b of custom CSS"
      project.styles = styles
    end

    custom_js_path = Rails.root.join('project', project.key, 'custom.js')
    if File.exist? custom_js_path
      custom_js = File.read custom_js_path
      puts "Loading #{custom_js.size}b of custom JS"
      project.custom_js = custom_js
    end

    project.save
  end

  def load_images(project_key)
    image_path = Rails.root.join('project', project_key, 'images/')
    return if ! File.exists? image_path

    puts "Loading images from #{image_path}:"

    Dir.foreach(image_path).each do |file|
      path = Rails.root.join image_path, file
      next if File.directory? path
      next if ! ['.png','.gif','.jpg', '.jpeg', '.svg', '.mp4', '.ico'].include? path.extname
      puts " -- #{file}"
      image_dest = Rails.root.join("app/assets/images/#{project_key}/")
      Dir.mkdir(image_dest) unless File.exists?(image_dest)
      cp(path, image_dest, verbose: false)
    end
  end

  def load_fonts(project_key)
    font_path = Rails.root.join('project', project_key, 'fonts/')
    puts "Loading fonts from #{font_path}:"

    if File.directory?(font_path)
      Dir.foreach(font_path).each do |file|
        path = Rails.root.join font_path, file
        next if File.directory? path
        next if ! ['.eot','.woff2','.woff', '.ttf', '.svg'].include? path.extname
        puts " -- #{file}"
        font_dest = Rails.root.join("app/assets/fonts/#{project_key}/")
        Dir.mkdir(font_dest) unless File.exists?(font_dest)
        cp(path, font_dest, verbose: false)
      end
    end
  end

  # Loads workflow jsons from workflows/*.json
  def load_workflows(project_key)
    project = Project.find_by key: project_key

    workflows_path = Rails.root.join('project', project_key, 'workflows', '*.json')
    puts "Workflows: Loading workflows from #{workflows_path}"

    Dir.glob(workflows_path).each do |workflow_hash_path|
      content = File.read(workflow_hash_path) # .gsub(/\n/, '')
      begin
        next if content == ''

        workflow_hash = JSON.parse content
        workflow_hash.deep_symbolize_keys!

        puts "  Loading '#{workflow_hash[:name]}' workflow"

        # workflow_hash[:project] = project

        tasks = workflow_hash.delete :tasks
        if tasks.is_a? Hash
          tasks = tasks.inject([]) do |a, (task_key, task_config)|
            task_config[:key] = task_key.to_s
            # Remove any config params not officially declared as fields of WorkflowTask:
            task_config = task_config.inject({}) { |h, (k,v)| h[k] = v if WorkflowTask.fields.keys.include?(k.to_s); h }

            # Rewrite pick-one-* tool configs to be structured the same per https://github.com/zooniverse/scribeAPI/issues/241
            # .. Just until project owners update their own configs
            task_config[:tool_config] = translate_pick_one_tool_config task_config

            a << task_config
          end
        end
        workflow_hash[:tasks] = tasks

        workflow_hash = load_help_text workflow_hash, project_key

        workflow = project.workflows.find_or_create_by name: workflow_hash[:name]
        workflow.update_attributes workflow_hash
        puts "    Loaded #{workflow.tasks.count} task(s)"

        if workflow.generates_subjects && ! workflow.generates_subjects_for
          puts "    WARN: #{workflow.name} generates subjects, but generates_subjects_for not set"
        end
      end
    end

    # Order workflows such that each appears before any workflows it generates subjects for
    project.workflows.each do |w|
      w.update_attribute :order, project.workflows.size - num_downstream_workflows(w) - 1
    end


    puts "  WARN: No mark workflow found" if project.workflows.find_by(name: 'mark').nil?
  end

  desc "Rebuilds all required indexes. Should be run any time project.metadata changes or workflows ids change (after reload or when switching activated project)"
  task :create_indexes, [] => :environment do |task, args|
    puts "Rebuilding indexes"

    # Make sure project.status index exists
    Project.create_indexes
    # Make sure various subject indexes exist:
    Subject.create_indexes
    Group.create_indexes
    Workflow.create_indexes
    Favourite.create_indexes
    Classification.create_indexes

    # Create a bunch of project-specific indexes:
    project = Project.current

    SubjectSet.collection.indexes.drop

    # Create workflow counts indexes:
    project.workflows.each do |w|
      # Index for typical Mark query:
      SubjectSet.index({"counts.#{w.id}.active_subjects" => 1, "random_no" => 1}, {background: true})
      # Index for marking by group_id:
      SubjectSet.index({"counts.#{w.id}.active_subjects" => 1, "group_id" => 1}, {background: true})
    end

    # Metadata search configured? Create indexes:
    # TODO Note that indexes created this way must be manually removed.
    # Loading lots of different projects (or the same project with different
    # indexes) will create mult. indexes, which may slow query planning
    if project.metadata_search && project.metadata_search.is_a?(Hash)
      # Loop over fields array:
      if project.metadata_search["fields"].is_a? Array
        project.metadata_search["fields"].each do |field|
          SubjectSet.index({"project" => 1, "metadata.#{field['field']}" => 1}, {background: true})
        end
      end
    end

    SubjectSet.create_indexes

  end

  desc "Drop a project by key"
  task :drop, [:project_key] => :environment do |task, args|
    project = Project.find_by key: args[:project_key]
    if project.nil?
      puts "No project called \"#{args[:project_key]}\" was found in the database"
      exit
    else
      project.destroy
    end

    # Delete fonts:
    FileUtils.remove_dir Rails.root.join("app/assets/fonts/#{args[:project_key]}"), true

    # Delete images:
    FileUtils.remove_dir Rails.root.join("app/assets/images/#{args[:project_key]}"), true

    puts "Deleted project: #{args[:project_key]}"
  end

  desc "Drop & Load a project by key"
  task :reload, [:project_key] => :environment do |task, args|

    Rake::Task['project:drop'].invoke(args[:project_key])
    Rake::Task['project:load'].invoke(args[:project_key])
    Rake::Task['project:create_indexes'].invoke

  end




  def translate_pick_one_tool_config(task_hash)
    config = task_hash[:tool_config]

    # In Pick-one-mark-one and compositeTool, rename 'tools' to 'options'
    if ['pickOneMarkOne', 'compositeTool'].include? task_hash[:tool]
      config[:options] = config.delete :tools if config[:options].nil?
    end

    # In Pick-one and compositeTool, structure 'options' as an array rather than a hash:
    if ['pickOne','compositeTool']
      config[:options] = config[:options].map { |(option_value,config)| config[:value] = option_value; config } if config[:options].is_a?(Hash)
    end

    config
  end

  def load_tutorial(project_key)
    project = Project.find_by key: project_key
    tutorial_hash = {}
    tutorial_path = Rails.root.join('project', project_key, 'tutorial', '*.json')
    puts "Tutorial: Loading workflows from #{tutorial_path}"

    Dir.glob(tutorial_path).each do |tutorial_hash_path|
      content = File.read(tutorial_hash_path) # .gsub(/\n/, '')
      begin
        next if content == ''

        tutorial_hash = JSON.parse content
        tutorial_hash.deep_symbolize_keys!
        tutorial_hash = load_help_text tutorial_hash, project_key
      end
    end
    tutorial_hash
  end


  def load_help_text(h, project_key)
    if h.respond_to? :each
      if h.is_a? Hash
        h.keys.each do |k,v|
          if k == :help && h[k].is_a?(Hash) && ! h[k][:file].nil? || k == "help" && h[k].is_a?(Hash) && ! h[k]["file"].nil?
            # Support nested objects
            if k == "help"
              h[k][:file] = h[k]["file"]
            end
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


end
