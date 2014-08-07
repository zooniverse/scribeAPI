task :create_subjects => :environment do
  puts 'Creating subjects...'
  
  Subject.destroy_all
  Group.destroy_all 
  
  manifest = JSON.parse( File.read( ENV['manifest_path'] ) )
  manifest.each_pair do |group_name, subjects|
    group = Group.create(name: group_name)
    subjects.each do |subject_location|
      Subject.create(group_name: group_name, group: group, location: subject_location)
    end
  end

  puts "#{Subject.count} subject(s) created."

end

task :create_manifest => :environment do
  puts 'Creating manifest file...'
  data_path = ENV['data_path']
  groups = {}
  puts Dir.glob(data_path + "/**/*.jpg").each {|path| g = path.split("/").last(2).first; file = path.split("/").last; groups[g] ||= []; groups[g] << file}
  File.open("../data/file_manifest.json","w"){|f| f.puts JSON.pretty_generate(groups)} 
end