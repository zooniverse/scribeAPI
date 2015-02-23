
  desc 'imports the subjects'
  task :load_subjects, [:project_name] => :environment do |task, args|
    project_name = args[:project_name]
    subjects_dir = Rails.root.join('project', project_name, 'subjects')
    group_list = Dir.glob(subjects_dir +"/group*.rb")
    if group_list.empty?
      #load_subjects
    else
      group_list.each {|group_file|  load_group group_file}
    end

  end

  desc "loads a group"
  task :load_group, [:group_file] => :environment do |task|

    puts 'in load_group()'

    group_file = args[:group_file]

    #TODO FIX!!!!!!!!!!!
    project    = Project.first

      CSV.foreach(group_file) do |row|
        data = row.to_hash
        name             = data[:name]
        description      = data[:description]
        cover_image_url  = data[:cover_image_url]
        external_url     = data[:external_url]

        meta_data        = data.delete([:name, :description, :cover_image_url, :external_url])
        group = project.groups.create({name: name,
                              description: description,
                              cover_image_url: cover_image_url,
                              external_url: external_url,
                              meta_data: meta_data})
        puts "group is #{group}"
        load_group_subjects group
      end
    end

  desc "loads subjects for a group"
    task :load_group_subjects, [:group_name] => :environment do |task|
      puts "load_group_subjects"

  end

  desc "loads ungrouped subjects"
    task :load_group_subjects, [:group_name] => :environment do |task, args|
  end
