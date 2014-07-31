task :injest_subjects, [:manifest_path] :=> :environment do |t,args|
  Subject.destroy_all
  Group.destroy_all 

  manifest = JSON.parse(IO.read(args[:manifest_path]))
  manifest.each_pair do |group_name, subjects|
    g = Group.create(name: group_name) 
    subjects.each do |subject|
      Subject.create(group: g, url: '' )
    end
  end
end