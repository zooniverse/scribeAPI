require 'csv'
require 'active_support'


  desc 'links a chain of rake tasks to setup a project, groups, and subjects'

    # Given a project key (aka name/title), returns the Project instance from the db:
    def project_for_key(key)

      project_file_path = Rails.root.join('project', key, 'project.rb')
      require project_file_path

      project = Project.find_by title: Specific_project[:title]
      project
    end


    task :project_setup, [:project_name] => :environment do |task, args|
      project_name = args[:project_name]
      subjects_dir = Rails.root.join('project', project_name, 'subjects')

      project = project_for_key project_name
      Rake::Task['load_workflows'].invoke(project_name, project.id)
        
      group_list = Dir.glob(subjects_dir + "./groups*.csv")
      group_list.each do |group_file|
        Rake::Task['load_group'].invoke(group_file, project_name)
      end
    end

  desc "loads a group"
    task :load_group, [:group_file, :project_name] => :environment do |task, args|
      project_name = args[:project_name]
      group_file = args[:group_file]

      #TODO FIX!!!!!!!!!!!
      # project = Project.first
      project = project_for_key project_name
      
      project.groups.destroy_all

      num_groups = File.foreach(group_file).count - 1
      puts "Groups: Creating #{num_groups} groups from groups.csv"
      CSV.foreach(group_file, :headers=>true, :header_converters=> lambda {|f| f.strip}, :converters=> lambda {|f| f ? f.strip : nil}) do |row|

        data = row.to_hash

        name             = data['name'].downcase
        description      = data['description']
        cover_image_url  = data['cover_image_url']
        external_url     = data['external_url']
        retire_count     = data['retire_count']

        meta_data        = data.except('name', 'description', 'cover_image_url', 'external_url', 'retire_count')

        puts "  Creating group #{$. - 1} of #{num_groups}: #{name}"
        group = project.groups.create({
                              name: name,
                              description: description,
                              cover_image_url: cover_image_url,
                              external_url: external_url,
                              meta_data: meta_data})

        Rake::Task['load_subjects'].invoke(project_name, name, group["_id"], retire_count)

        # Have to call reenable if we hope to invoke it again for next csv, if any
        Rake::Task['load_subjects'].reenable
      end
    end

  desc "loads subjects for a group"

    task :load_subjects, [:project_name, :group_name, :group_id, :retire_count] => :environment do |task, args|
      project = project_for_key args[:project_name]
      mark_workflow = project.workflows.find_by(name: 'mark')

      # this isn't going to work multi-word groups
      group_file_name = "group_" + args[:group_name]
      group_file_path = Rails.root.join('project', args[:project_name], 'subjects' + "/#{group_file_name}.csv")

      group = Group.find(args['group_id'])
      group.subjects.destroy_all

      puts "    Loading #{CSV.foreach(group_file_path).count - 1} subjects for group #{args[:group_name]}"

      CSV.foreach(group_file_path, {:headers=>true}) do |row|
        data = row.to_hash

        group_id = args['group_id']
        file_path = data['file_path']
        thumbnail = data['thumbnail']
        retire_count = args['retire_count']
        meta_data = data.except('group_id', 'file_path', 'retire_count', 'thumbnail')


        subj = Subject.create({
          group_id: group_id,
          file_path: file_path,
          location: {
            standard: file_path,
            thumbnail: thumbnail
          },
          workflow_ids: [mark_workflow.id],
          retire_count: retire_count,
          meta_data: meta_data
        })
        # puts "apply worfklow id: #{mark_workflow.id} to subject #{subj.id}"
          
      end

    end

    
  desc "loads workflow jsons from workflows/*.json"
    task :load_workflows, [:project_name, :project_id] => :environment do |task, args|
      project_id = args[:project_id]
      project = Project.find project_id
      project.workflows.destroy_all

      workflows_path = Rails.root.join('project', args[:project_name], 'workflows', '*.json')
      puts "Workflows: Loading workflows from #{workflows_path}"

      Dir.glob(workflows_path).each do |workflow_hash_path|
        content = File.read(workflow_hash_path).gsub(/\n/, '')
        begin
          workflow_hash = JSON.parse content
          workflow_hash.deep_symbolize_keys!
          workflow_hash[:project] = project
          workflow = Workflow.create workflow_hash
          puts "  Loaded '#{workflow.name}' workflow with #{workflow.tasks.count} tasks"
        rescue
          puts "  WARN: Couldn't parse workflow from #{workflow_hash_path}"
        end
      end

      puts "  WARN: No mark workflow found" if project.workflows.find_by(name: 'mark').nil?
  end

