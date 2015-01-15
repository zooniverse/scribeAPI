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
  description:   '''
    The world\'s largest whaling library has been digitized. As a citizen scientist, you will dig through the logbooks of ship captains to read and extract weather related data.  Weather descriptions contained in the logbooks will help improve weather prediction capabilities while making an important part of Massachussetts history during the mid- to late 1800s widely available for anyone interested.
  ''',
  home_page_content: '''
    <h1>Whale Tales</h1>
    <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean nulla neque, luctus a malesuada hendrerit, scelerisque tempus lectus. Sed semper tellus ut sapien cursus vehicula. Praesent pellentesque tellus id tortor pharetra, lacinia vehicula eros condimentum. In ultrices ligula ac augue vestibulum, quis accumsan est facilisis. Integer aliquet elementum est quis feugiat. Aliquam erat volutpat. Nunc quis consequat est. Fusce sit amet viverra ex, ac euismod ante. Nam vitae tincidunt velit. Aliquam ultricies neque lacus, at dapibus libero pellentesque ut. Nam vulputate mauris varius porttitor porta. In fermentum turpis nulla, nec vulputate libero malesuada ut. Praesent in libero vestibulum, sodales augue sed, porta metus.</p>

    <p>In id porttitor tellus, ut malesuada ante. In mollis ante eget erat ornare faucibus ut at tellus. Pellentesque sed nisi in eros auctor ornare nec ac nisi. In semper eu ligula eu interdum. Quisque vitae volutpat leo. Integer euismod risus id fermentum varius. Donec aliquam ipsum risus, vitae scelerisque lorem aliquam a. Cras efficitur pharetra dapibus. Ut fermentum metus erat, nec egestas lectus aliquam quis.</p>

    <p>Sed gravida dictum urna in fringilla. Praesent ac dolor ipsum. Quisque sodales eu lorem nec gravida. Maecenas vel tortor felis. Curabitur tristique urna ex. Sed semper mattis sem, nec dictum enim lobortis a. Sed non mollis sem, vel accumsan justo. Vivamus consequat nulla non aliquet semper. Vivamus lectus eros, sollicitudin ornare rhoncus quis, vestibulum a quam. Integer mattis nibh ex, vel consequat elit efficitur vel. Duis blandit, nisl ac laoreet viverra, orci magna eleifend elit, eu cursus dui neque non mi. Fusce quis ex nec sapien auctor placerat. Morbi imperdiet a ante et porta. Vivamus sed libero sit amet erat dictum faucibus. Praesent sed aliquet lectus, vitae pretium neque.</p>
  ''',

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


