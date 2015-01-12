# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# puts 'DEFAULT USERS'
# user = User.create! :name => ENV['ADMIN_NAME'].dup, :email => ENV['ADMIN_EMAIL'].dup, :password => ENV['ADMIN_PASSWORD'].dup, :password_confirmation => ENV['ADMIN_PASSWORD'].dup
# puts 'user: ' << user.name

Project.destroy_all
# Subject.destroy_all
Workflow.destroy_all
Classification.destroy_all


pages = [
  {
    name: 'science',
    content: 
      """
      <h1> Science Page</h1>
      """
  },
  {
    name: 'about',
    content:    
      """
      <h1> About Page</h1>
      """
  },
  {
    name: 'foo',
    content:
      """
      <h1> This is a foo page</h1>
      """
  }
]

puts pages

project = Project.create(:pages => pages)

puts project

# marking_tasks = {
#       "drawSomething" => {
#         "type" => "drawing",
#         "question" => "Draw something.",
#         "choices" => [ {
#           "value" => "point",
#           "image" => "//placehold.it/30.png",
#           "label" => "Show Date",
#           "color" => "# "
#         },
#         {
#           "value" => "point",
#           "image" => "//placehold.it/30.png",
#           "label" => "Location",
#           "color" => "#ff0"
#         },
#         {
#           "value" => "point",
#           "image" => "//placehold.it/30.png",
#           "label" => "Cast Member",
#           "color" => "#ff0"
#         },
#         {
#           "value" => "point",
#           "image" => "//placehold.it/30.png",
#           "label" => "Production Staff",
#           "color" => "#ff0"
#         },
#         {
#           "value" => "point",
#           "image" => "//placehold.it/30.png",
#           "label" => "Thearter Name",
#           "color" => "#ff0"
#         }
#         ]
#     }
#   }

transcribe_tasks = [
    {
      :key         => 0,
      :type        => 'date', # type of input
      :field_name  => 'date',
      :label       => 'Date',
      :instruction => 'Please type-in the log date.'
    },
    {
      :key         => 1,
      :type        => 'text',
      :field_name  => 'journal_entry',
      :label       => 'Journal Entry',
      :instruction => 'Please type-in the journal entry for this day.'
    },
    {
      :key         => 2,
      :type        => 'textarea',
      :field_name  => 'other_entry',
      :label       => 'Other Entry',
      :instruction => 'Type something, anything.'
    }
]

puts transcribe_tasks

marking_tasks = ""

transcribe_workflow = Workflow.create(
  {
    key:               "transcribe", 
    label:             "Transcribe Contnet", 
    first_task:        "", 
    tasks:             transcribe_tasks, 
    enables_workflows: {}, 
    project:           project 
  }
)

puts transcribe_workflow

marking_workflow = Workflow.create(
  {
    key: "marking", 
    label: "Mark Content",  
    first_task:"drawSomething", 
    enables_workflows: {transcribe_workflow.id.to_s => {} }, 
    tasks:marking_tasks, 
    project: project 
  }
)

# verify_workflow    = Workflow.create({name: "verify", tasks:[]  , project: p })
# transcribe_workflow  = Workflow.create({key: "transcribe", label:"Transcribe Contnet", first_task:"", tasks:{}, enables_workflows: {}, project: project })

# example_images = ["https://s3.amazonaws.com/programs-cropped.nypl.org/10/00261.jpg","https://s3.amazonaws.com/programs-cropped.nypl.org/10/00262.1.jpg","https://s3.amazonaws.com/programs-cropped.nypl.org/10/00262.2.jpg"]

# 10.times do |i|
#   Subject.create(name:"subject_#{i}", location: {standard: example_images.sample}, meta_data: { width:504, height:782}, workflows: [marking_workflow])
# end