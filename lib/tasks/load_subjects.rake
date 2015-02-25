require 'csv'


  desc 'links a chain of rake tasks to setup a project, groups, and subjects'
    task :project_setup, [:project_name] => :environment do |task, args|
      project_name = args[:project_name]
      subjects_dir = Rails.root.join('project', project_name, 'subjects')
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
      project = Project.first

      CSV.foreach(group_file, :headers=>true, :header_converters=> lambda {|f| f.strip}, :converters=> lambda {|f| f ? f.strip : nil}) do |row|

        puts 'group_file: ', group_file

        data = row.to_hash

        name             = data['name'].downcase
        description      = data['description']
        cover_image_url  = data['cover_image_url']
        external_url     = data['external_url']
        meta_data        = data.except(:name, :description, :cover_image_url, :external_url)

        group = project.groups.create({
                              name: name,
                              description: description,
                              cover_image_url: cover_image_url,
                              external_url: external_url,
                              meta_data: meta_data})
        binding.pry



        Rake::Task['load_subjects'].invoke(project_name, name, group["_id"])
      end
    end

  desc "loads subjects for a group"

    task :load_subjects, [:project_name, :group_name, :group_id, :retire_count] => :environment do |task, args|
      # this isn't going to work multi-word groups
      puts "LOADING THE SUBJECTS"
      group_file_name = "group_" + args[:group_name]
      group_file_path = Rails.root.join('project', args[:project_name], 'subjects' + "/#{group_file_name}.csv")

      CSV.foreach(group_file_path, {:headers=>true}) do |row|
        data = row.to_hash

        group_id = args['group_id']
        file_path = data['file_path']
        thumbnail = data['thumbnail']
        width = data["width"]
        height = data["height"]
        retire_count = args['retire_count']
        state = data['state']
        type = data['type']
        meta_data = data.except([:group_id, :file_path, :retire_count, :state, :type])


        Subject.create({
          group_id: group_id,
          state: state,
          type: type,
          })
      end

    end
