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
# Subject.destroy_all # keep all subjects for now
Workflow.destroy_all
Classification.destroy_all

#
# gather project info
#

pages = [
  {
    name: 'science',
    content: 
      """
      <h1> Science Page</h1>
      <p>I am a science!</p>
      """
  },
  {
    name: 'about',
    content:    
      """
      <h1> About Page</h1>
      <p>This is the about page.</p>
      """
  },
  {
    name: 'foo',
    content:
      """
      <h1>Foo</h1>
      <p>This is the Foo page.</p>
      """
  }
]

organizations =[ 
  {
    name:        "Zooniverse", 
    location:    "Chicago IL", 
    description: "World leaders in Citizen Science", 
    url:         "https://www.zooniverse.org"
  },
  {
    name:        "New Bedford Whaling Museum", 
    location:    "New Bedford, MA", 
    description: "", 
    url:         "http://www.whalingmuseum.org"
  }
]

scientists = [
  {
    name:        "John Doe", 
    location:    "New Bedford, MA", 
    description: "", 
    url:         "http://www.whalingmuseum.org"
  }
]

developers = [
  {
    name:        "Stuart Lynn", 
    location:    "Chicago, IL", 
    description: "", 
    url:         "https://github.com/stuartlynn"
  }
]

# create new project
project = Project.create(
  producer:      'Zooniverse/NYPL',
  title:         'Whale Tales',
  description:   'The world\'s largest whaling library has been digitized. As a citizen scientist, you will dig through the logbooks of ship captains to read and extract weather related data.  Weather descriptions contained in the logbooks will help improve weather prediction capabilities while making an important part of Massachussetts history during the mid- to late 1800s widely available for anyone interested.',
  summary:       'Transcribe ship logs from the New Bedford Whaling Museum',
  organizations: organizations,
  scientists:    scientists, 
  developers:    developers,
  pages:         pages,
  background:    ''
)

transcribe_tasks = {
  0 => {
      key:          0,
      type:         'date',
      field_name:   'date',
      label:        'Date',
      instruction:  'Please type-in the log date.'
  },
  1 =>{
      key:          1,
      type:        'text',
      field_name:  'journal_entry',
      label:       'Journal Entry',
      instruction: 'Please type-in the journal entry for this day.'
  },
  2 => {
      key:          2,
      type:         'textarea',
      field_name:   'other_entry',
      label:        'Other Entry',
      instruction:  'Type something, anything.'
  }
}

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

mark_workflow = Workflow.create(
  {
    key:               "mark", 
    label:             "Mark Contnet", 
    first_task:        "", 
    tasks:             transcribe_tasks, 
    enables_workflows: {}, 
    project:           project 
  }
)


