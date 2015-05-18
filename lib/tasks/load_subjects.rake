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

      Rake::Task['load_groups'].invoke(project_name)
    end

    task :load_groups, [:project_name] => :environment do |task, args|
      project_name = args[:project_name]
      subjects_dir = Rails.root.join('project', project_name, 'subjects')

      groups_file = Rails.root.join(subjects_dir, 'groups.csv')

      project = project_for_key project_name

      project.groups.destroy_all

      num_groups = File.foreach(groups_file).count - 1
      puts "Groups: Creating #{num_groups} groups from groups.csv"
      CSV.foreach(groups_file, :headers=>true, :header_converters=> lambda {|f| f.strip}, :converters=> lambda {|f| f ? f.strip : nil}) do |row|
        data = row.to_hash

        group_key        = data['key'].downcase
        name             = data['name']
        description      = data['description']
        cover_image_url  = data['cover_image_url']
        external_url     = data['external_url']
        meta_data        = data.except('name')

        group = project.groups.create({
                              name: name,
                              key: group_key,
                              description: description,
                              cover_image_url: cover_image_url,
                              external_url: external_url,
                              meta_data: meta_data})

        puts "  Creating group #{$. - 1} of #{num_groups}: #{group_key}"
        Rake::Task['load_group_subjects'].invoke(project_name, group_key)

        Rake::Task['load_group_subjects'].reenable

      end
    end

    task :load_group_subjects, [:project_name, :group_key] => :environment do |task, args|
      project_name = args[:project_name]
      subjects_dir = Rails.root.join('project', project_name, 'subjects')
      group_file = Rails.root.join subjects_dir, "group_#{args[:group_key]}.csv"

      group = Group.find_by key: args[:group_key]

      project = project_for_key args[:project_name]
      mark_workflow = project.workflows.find_by(name: 'mark')

      # Loop over contents of group file, which has one subject per row

      subjects_by_set = {}

      puts "    Reding subjects from: #{group_file}"
      CSV.foreach(group_file, :headers=>true, :header_converters=> lambda {|f| f.strip}, :converters=> lambda {|f| f ? f.strip : nil}) do |row|
        data = row.to_hash
        key = data['set_key']
        key = "_autogen_set_key_#{$.}" if key.blank?
        subjects_by_set[key] ||= []
        subjects_by_set[key] << data
      end

      subjects_by_set.each do |(set_key, subjects)|

        data = subjects.first
        thumbnail       = data['thumbnail']
        name            = data['name']
        meta_data       = data.except('group_id', 'file_path', 'retire_count', 'thumbnail')

        puts "    Adding subject set: #{set_key}"
        subject_set = group.subject_sets.create({
          name: name,
          project: project,
          thumbnail: thumbnail,
          meta_data: meta_data
        })
        puts "      - saved subject set #{subject_set.thumbnail}"

        subjects.each do |subj|
          data = subj
          # puts "    Load subject/subjeset: #{data}"
          # group_id = group.id # args['group_id']
          meta_data = subj.except('file_path', 'retire_count', 'thumbnail')

          puts "      Adding subject: #{subj['file_path']}"
          s = subject_set.subjects.create({
            file_path: subj['file_path'],
            location: {
              standard: subj['file_path'],
              thumbnail: subj['thumbnail']
            },
            workflow: mark_workflow,
            meta_data: meta_data
          })
          s.activate!
          puts "        - saved subject: #{s.file_path}"
        end

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
      content = File.read(workflow_hash_path) # .gsub(/\n/, '')
      begin
        workflow_hash = JSON.parse content
        workflow_hash.deep_symbolize_keys!
        workflow_hash[:project] = project
        workflow = Workflow.create workflow_hash
        puts "  Loaded '#{workflow.name}' workflow with #{workflow.tasks.count} tasks"
      rescue => e
        puts "  WARN: Couldn't parse workflow from #{workflow_hash_path}: #{e}"
      end
    end

    puts "  WARN: No mark workflow found" if project.workflows.find_by(name: 'mark').nil?
  end
