require 'csv'
  

  desc 'imports the subjects'
  task :load_subjects, [:project_name] => :environment do |task, args|
    project_name = args[:project_name]
    subjects_dir = Rails.root.join('project', project_name, 'subjects')
    group_list = Dir.glob(subjects_dir + "./groups*.csv")

    if group_list.empty?
      #load_subjects
    else
      group_list.each do |group_file|
        Rake::Task['load_group'].invoke(group_file)
      end
    end
  end

  desc "loads a group"
  task :load_group, [:group_file] => :environment do |task, args|

    group_file = args[:group_file]


    #TODO FIX!!!!!!!!!!!
    project = Project.first

    CSV.foreach(group_file, :headers=>true, :header_converters=> lambda {|f| f.strip}, :converters=> lambda {|f| f ? f.strip : nil}) do |row|

      puts 'group_file: ', group_file

      data = row.to_hash
            
      name             = data['name']
      description      = data['description']
      cover_image_url  = data['cover_image_url']
      external_url     = data['external_url']
      meta_data        = data.delete([:name, :description, :cover_image_url, :external_url])

      # binding.pry

      # puts 'group hash: ', {name: name,
      # description: description,
      # cover_image_url: cover_image_url,
      # external_url: external_url,
      # meta_data: meta_data}

      group = project.groups.create({name: name,
                            description: description,
                            cover_image_url: cover_image_url,
                            external_url: external_url,
                            meta_data: meta_data})


      puts "group is #{group}"
      Rake::Task['load_group_subjects'].invoke('foo','bar')
    end
  end

  desc "loads subjects for a group"
    task :load_group_subjects, [:project_name, :group_name] => :environment do |task, args|
      puts "ARGS: #{args}"

  end
