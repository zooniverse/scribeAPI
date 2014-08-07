task :test_script => :environment do
  # puts Subject.last
# task :test_script, [:manifest_path] => :environment do |args|
# task :test_script => :environment do
  puts "Running test_script..."
  # debugger
  manifest_path = ENV['manifest_path']
  puts manifest_path
  # puts Dir.pwd
  manifest = JSON.parse( File.read(manifest_path) )
  manifest.each_pair do |group_name, subjects|
    group = Group.create(name: group_name)
    subjects.each do |subject_location|
      Subject.create(group: group, location: subject_location)
      Subject.create(location: subject_location)
    end
  end

  puts "Subject.count: #{Subject.count}"
end