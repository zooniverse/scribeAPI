require 'csv'
require 'active_support'


namespace :subjects do
  desc 'links a chain of rake tasks to setup a project, groups, and subjects'

  # Given a project key (aka name/title), returns the Project instance from the db:
  def project_for_key(key)

    # project_file_path = Rails.root.join('project', key, 'project.json')
    # project_hash = JSON.parse File.read(project_file_path)

    project = Project.find_by key: key
    project
  end

  task :progress_report, [] => :environment do |task, args|
    Project.current.workflows.each do |workflow|
      puts workflow.name
      puts "  Total: #{workflow.subjects.count}"
      groups = Subject.group_by_field(:status, {workflow_id: workflow.id})
      groups.each do |(v, count)|
        puts "  #{v}: #{count}"
      end
      completion = 0
      case workflow.name
      when 'mark'
        completion = 1.0 - groups['active'].to_f / workflow.subjects.count
      when 'transcribe'
        completion = 1.0 - groups['active'].to_f / workflow.subjects.count
      when 'verify'
        completion = 1.0 - (groups['inactive'].to_f + groups['active']).to_f / workflow.subjects.count
      end
      puts "  Completion: #{(completion * 100)}%"
    end
  end

  task :bad_parents_make_bad_children, [] => :environment do |task, args|
    Subject.where(status: 'bad').each do |subject| 
      if subject.child_subjects.count > 0
        child_statuses = subject.child_subjects.map { |_s| _s.status }
        puts "Asserting badness of #{subject.id} with children that are: #{child_statuses.join(', ')}"
        subject.bad!
        # break
      end
    end
  end

  task :apply_consensus_after_spec_formatting, [:subject_id] => :environment do |task, args|
    subjects = args[:subject_id].nil? ? Project.current.workflows.find_by(name: 'verify').subjects.where(status: 'active', :classification_count.gte => 5) : [Subject.find(args[:subject_id])]

    subjects.each do |subject| 
      final_subject = subject.child_subjects.first
      revised_consensus = final_subject.calculate_most_popular_parent_classification normalized: true
      # puts "revised: #{revised_consensus.inspect}" if args[:subject_id].present?
      if revised_consensus[:percentage] >= subject.workflow.generates_subjects_agreement
        puts "Make complete: #{final_subject.id}"
        puts "  .. and retire: #{subject.id}"
        # puts "complete: #{final_subject.inspect}"
        # puts "retire!: #{subject.inspect}"
        final_subject.complete!
        subject.retire!
      elsif args[:subject_id].present?
        puts "Not applying consensus by spec formatting"
      end
    end
  end

  task :fix_active_transcribe_subjects_with_contentious_children, [] => :environment do |task, args|
    Subject.where(status: 'contentious').each do |s| 
      if s.parent_subject.status != 'retired'
        puts "parent status: #{s.parent_subject.status}"
        child_statuses = s.parent_subject.child_subjects.map { |_s| _s.status }
        if ! child_statuses.include?('active')
          puts "Subject #{s.id} is contentious, so retiring #{s.parent_subject.id}"
          s.parent_subject.retire!
        else
          puts "Subject #{s.id} is contentious, but has active siblings, so not retiring"
        end
      end
    end
  end

  task :fix_inactive_verifications, [] => :environment do |task, args|
    puts "Looking for inactive Verify subjects..."
    transcribe_subject_ids = Project.current.workflows.find_by(name: 'verify').subjects.where(status: 'inactive').inject([]) { |subject_ids, subject| subject_ids << subject.parent_subject_id; subject_ids }.uniq
    puts "Found #{transcribe_subject_ids.size} distinct transcription subjects with inactive Verify child subjects"
    transcribe_subject_ids.each_with_index do |subject_id, i|
      Subject.find(subject_id).activate!
      puts " - Activate transcribe subject: ", subject_id
    end
  end

  task :load_groups, [:project_key] => :environment do |task, args|
    project_key = args[:project_key]
    subjects_dir = Rails.root.join('project', project_key, 'subjects')

    groups_file = Rails.root.join(subjects_dir, 'groups.csv')

    project = project_for_key project_key

    # project.groups.destroy_all

    num_groups = File.foreach(groups_file).count - 1
    puts "Groups: Creating #{num_groups} groups from groups.csv"
    CSV.foreach(groups_file, :headers=>true, :header_converters=> lambda {|f| f.strip}, :converters=> lambda {|f| f ? f.strip : nil}) do |row|
      data = row.to_hash

      group_key        = data['key'] # .downcase # is there a reason for downcasing?
      name             = data['name']
      description      = data['description']
      cover_image_url  = data['cover_image_url']
      external_url     = data['external_url']
      meta_data        = data.except('name')

      group = project.groups.find_or_create_by key: group_key
      group.update_attributes({
        name: name,
        description: description,
        cover_image_url: cover_image_url,
        external_url: external_url,
        meta_data: meta_data
      })

      puts "  Creating group #{$. - 1} of #{num_groups}: #{group_key}"
      Rake::Task['subjects:load_group_subjects'].invoke(project_key, group_key)

      Rake::Task['subjects:load_group_subjects'].reenable

    end
  end

  task :load_group_subjects, [:project_key, :group_key] => :environment do |task, args|
    project_key = args[:project_key]
    subjects_dir = Rails.root.join('project', project_key, 'subjects')
    group_file = Rails.root.join subjects_dir, "group_#{args[:group_key]}.csv"

    project = project_for_key args[:project_key]
    group = project.groups.find_by key: args[:group_key]

    mark_workflow = project.workflows.find_by(name: 'mark')

    # Loop over contents of group file, which has one subject per row

    subjects_by_set = {}

    puts "    Reading subjects from: #{group_file}"
    if ! File.exist? group_file
      puts "Couldn't find #{group_file}"
    else
      CSV.foreach(group_file, :headers=>true, :header_converters=> lambda {|f| f.strip}, :converters=> lambda {|f| f ? f.strip : nil}) do |row|
        data = row.to_hash
        key = data['set_key']
        key = "_autogen_set_key_#{$.}" if key.blank?
        subjects_by_set[key] ||= []
        subjects_by_set[key] << data
      end
    end

    subjects_by_set.each do |(set_key, subjects)|

      data = subjects.first
      thumbnail       = data['thumbnail']
      name            = data['name']
      meta_data       = data.except('group_id', 'file_path', 'retire_count', 'thumbnail', 'width','height', 'order')

      puts "    Adding subject set: #{set_key}"
      subject_set = group.subject_sets.find_or_create_by key: set_key
      subject_set.update_attributes({
        name: name,
        project: project,
        thumbnail: thumbnail,
        meta_data: meta_data
      })
      puts "      - saved subject set #{subject_set.thumbnail}"

      subjects.each_with_index do |subj, i|
        data = subj

        width = subj['width'].nil? ? nil : subj['width'].to_i
        height = subj['height'].nil? ? nil : subj['height'].to_i

        # If width/height not specified in CSV, autodetect:
        if width.nil? || height.nil?
          require 'fastimage'
          width, height = FastImage.size(subj['file_path'],:raise_on_failure=>false, :timeout=>10.0)
          puts "        - Autodetected image size: #{width} x #{height}"
        end

        # Parse order from csv if avail; otherwise default to position in csv:
        order = subj['order'].nil? ? i : subj['order'].to_i

        # add zooniverse_id if exists
        if subj.has_key?("zooniverse_id")
          meta_data["zooniverse_id"] = subj["zooniverse_id"]
        end

        # puts "      Adding subject: #{subj['file_path']}"
        # Subject.all.where("location.standard" => "https://s3.amazonaws.com/scribe.nypl.org/emigrant-records/originals/037.jpg").count
        # puts "s = SubjectSet[#{subject_set.id}].subjects.where(\"location.standard\" => \"#{subj['file_path']}\").first"
        # puts "  updating metadata: #{meta_data}"

        subject = subject_set.subjects.where("location.standard" => subj['file_path'], type: 'root').first
        subject = subject_set.subjects.create if subject.nil?
        subject.update_attributes({
          location: {
            standard: subj['file_path'],
            thumbnail: subj['thumbnail']
          },
          workflow: mark_workflow,
          meta_data: meta_data,
          width: width,
          height: height,
          order: order,
          group: group
        })
        subject.activate!
        puts "Added subject: #{subject.location[:standard]}"
      end

    end
  end

end
