# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
puts 'DEFAULT USERS'
user = User.create! :name => ENV['ADMIN_NAME'].dup, :email => ENV['ADMIN_EMAIL'].dup, :password => ENV['ADMIN_PASSWORD'].dup, :password_confirmation => ENV['ADMIN_PASSWORD'].dup
puts 'user: ' << user.name

Project.destroy_all
Subject.destroy_all
Workflow.destroy_all
Classification.destroy_all

p = Project.create

verify_workflow 	 = Workflow.create({name: "verify", tasks:[]  , project: p })
transcribe_workflow  = Workflow.create({name: "transcribe", tasks:[], enables_workflows: [verify_workflow.id], project: p })
marking_workflow 	 = Workflow.create({name: "marking", enables_workflows: [transcribe_workflow.id], tasks:[{}], project: p })

10.times do |i|
	Subject.create(name:"subject_#{i}", url: "http://lorempixel.com/600/800/cats/", width: 600, height:800, workflows: [marking_workflow])
end