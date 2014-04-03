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


pages = [{ science:  """
            <h1> Science Page</h1>
             """,
       about:    """
            <h1> About Page</h1>
             """,
       library:  """
            <h1> Library Page</h1>
             """
      }]

p = Project.create(:pages => pages)

marking_tasks = {
      "drawSomething" => {
        "type" => "drawing",
        "question" => "Draw something.",
        "choices" => [ {
          "value" => "point",
          "image" => "//placehold.it/30.png",
          "label" => "Show Date",
          "color" => "# "
        },
        {
          "value" => "point",
          "image" => "//placehold.it/30.png",
          "label" => "Location",
          "color" => "#ff0"
        },
        {
          "value" => "point",
          "image" => "//placehold.it/30.png",
          "label" => "Cast Member",
          "color" => "#ff0"
        },
        {
          "value" => "point",
          "image" => "//placehold.it/30.png",
          "label" => "Production Staff",
          "color" => "#ff0"
        },
        {
          "value" => "point",
          "image" => "//placehold.it/30.png",
          "label" => "Thearter Name",
          "color" => "#ff0"
        }
        ]
    }
  }

# verify_workflow    = Workflow.create({name: "verify", tasks:[]  , project: p })
transcribe_workflow  = Workflow.create({key: "transcribe", label:"Transcribe Contnet", tasks:{}, enables_workflows: {}, project: p })
marking_workflow   = Workflow.create({key: "marking", label: "Mark Content", enables_workflows: {transcribe_workflow.id.to_s => {} }, tasks:marking_tasks, project: p })

example_images = ["https://s3.amazonaws.com/programs-cropped.nypl.org/10/00261.jpg","https://s3.amazonaws.com/programs-cropped.nypl.org/10/00262.1.jpg","https://s3.amazonaws.com/programs-cropped.nypl.org/10/00262.2.jpg"]


10.times do |i|
  Subject.create(name:"subject_#{i}", url: example_images.sample, metadata: { width:504, height:782}, workflows: [marking_workflow])
end