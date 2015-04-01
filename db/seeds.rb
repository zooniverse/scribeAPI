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
Subject.destroy_all # keep all subjects for now
Workflow.destroy_all
Classification.destroy_all

pages = [
  {
    name: 'science',
    content:
      """
      <div class=\"page-content\">
        <h1> Science Page</h1>
        <p>I am a science!</p>
        <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Quisque tincidunt ante sit amet nibh ultricies imperdiet. Sed eleifend interdum urna ut cursus. In egestas imperdiet molestie. Suspendisse potenti. Donec imperdiet eleifend fermentum. Suspendisse ac eros facilisis, volutpat quam eu, pulvinar nibh. Nulla sed lectus quis mauris ullamcorper mollis nec at neque. Integer scelerisque orci ac velit tincidunt consectetur. Sed venenatis, erat nec sagittis molestie, tellus libero semper nulla, ut tincidunt nisl lorem semper odio. Nam ipsum urna, congue tincidunt eleifend pretium, interdum a felis. Nunc urna massa, condimentum ac nisl a, faucibus faucibus leo. Fusce arcu urna, blandit in lorem id, ornare dapibus nibh. Quisque bibendum odio augue, at faucibus risus sollicitudin ac. Donec eget diam vel massa pharetra iaculis et vel risus.</p>
        <p>Nullam lectus odio, facilisis ac quam non, viverra condimentum nulla. Sed non ornare tortor. Mauris luctus varius tellus at blandit. Nulla maximus consequat quam, non hendrerit risus facilisis sit amet. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Suspendisse viverra in justo sit amet maximus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Integer vulputate nisi ac turpis ultricies, tempor ultrices justo viverra. Praesent molestie ultrices lacus, nec auctor tellus molestie quis. Sed et sem leo. Fusce sed turpis vehicula, suscipit arcu sed, commodo ipsum. Nullam auctor tortor quis lobortis convallis. Aliquam a diam ligula. Nunc id interdum nunc. Maecenas quis tortor metus. Cras eget molestie tellus.</p>
      </div>
      """
  },
  {
    name: 'about',
    content:
      """
      <div class=\"page-content\">
        <h1>About Page</h1>
        <p>This is the about page.</p>
        <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam at felis ultrices, tincidunt est nec, ultrices metus. Vivamus tempor nisi vitae erat pharetra, sit amet efficitur tellus aliquam. Fusce dolor dolor, facilisis et mollis a, egestas sed mauris. Duis sodales enim ac dui sodales sollicitudin. Sed commodo semper scelerisque. Cras elementum pulvinar nulla, et imperdiet orci porta nec. Integer feugiat massa ac libero finibus, non dapibus lectus tincidunt. Nulla sed pulvinar diam. Praesent cursus erat in cursus sagittis. Pellentesque ultricies, mi vel dapibus aliquam, metus massa tempus lectus, ut scelerisque ex urna id massa. Vestibulum eget justo nec dui ultrices tempor. In facilisis risus nibh, ac porttitor enim pulvinar nec.</p>
      </div>
      """
  },
  {
    name: 'foo',
    content:
      """
      <div class=\"page-content\">
        <h1>Foo</h1>
        <p>This is the Foo page.</p>
        <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam et nunc diam. Praesent turpis justo, ultrices et sollicitudin a, consequat non magna. Suspendisse vehicula cursus mi, a fermentum lorem bibendum sit amet. Pellentesque facilisis, orci non facilisis porta, ipsum tellus posuere ante, eget dignissim tellus tellus id erat. Etiam non lobortis orci, ac laoreet nisl. Vestibulum viverra aliquam viverra. Mauris a purus dictum, auctor est non, bibendum dui. Nullam in euismod dolor.</p>
        <p>Nam eu augue luctus, porta lorem et, bibendum lacus. Maecenas justo quam, aliquet vitae ligula ut, pretium rhoncus lectus. In posuere, urna molestie tincidunt pulvinar, nisl nulla malesuada erat, eget viverra eros eros non augue. Suspendisse dolor augue, iaculis vitae tristique vitae, dignissim a velit. Curabitur laoreet malesuada lorem a tincidunt. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Sed cursus purus vitae eros elementum semper. Proin sit amet orci ipsum. Maecenas feugiat libero justo, mollis condimentum diam dictum quis. Pellentesque commodo id sapien sed consectetur. Nullam purus lorem, bibendum condimentum fringilla vitae, tristique ut ligula. Interdum et malesuada fames ac ante ipsum primis in faucibus.</p>
        <p>Etiam feugiat neque id ante mollis ultricies. Vestibulum vitae congue elit, at placerat dui. Cras tristique posuere nulla non ullamcorper. Sed sed neque id mauris aliquet posuere. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Aenean in enim tellus. Quisque nec venenatis massa. Nullam efficitur rutrum imperdiet. Nam facilisis consectetur dignissim. Fusce sed velit ut ligula fringilla lacinia. Nullam lorem est, facilisis nec sagittis sit amet, ultrices quis lorem. Maecenas mattis eleifend semper.</p>
        <p>In ornare sodales augue id sollicitudin. Pellentesque accumsan lobortis turpis, eu venenatis tortor sodales at. Mauris enim tortor, congue nec auctor et, tincidunt ut neque. Sed fringilla, metus maximus vestibulum pulvinar, nisi arcu feugiat eros, et porttitor dolor elit at libero. Nullam porttitor ante ut diam volutpat luctus. Morbi risus dui, vehicula ut aliquam at, varius id nulla. Nam turpis enim, rutrum id pellentesque eget, posuere id nunc. Nam pretium felis quis libero pulvinar, nec egestas lacus fringilla. Vestibulum aliquet ex id mi auctor feugiat.</p>
        <p>Nunc euismod convallis orci sit amet lobortis. Nam dictum tempor sapien, blandit imperdiet purus egestas eu. Ut ullamcorper feugiat orci, at scelerisque enim porta ut. Morbi tempus quis ipsum eget congue. Cras ultrices tempor dapibus. Nulla sodales diam congue, euismod libero vitae, molestie urna. Cras a posuere magna, sed imperdiet orci.</p>
      </div>
      """
  }
]

organizations =[
  {
    name:        'Zooniverse',
    location:    'Chicago IL',
    description: 'World leaders in Citizen Science',
    url:         'https://www.zooniverse.org'
  },
  {
    name:        'New Bedford Whaling Museum',
    location:    'New Bedford, MA',
    description: '',
    url:         'http://www.whalingmuseum.org'
  }
]

team = [
  {
    name:        'John Doe',
    location:    'New Bedford, MA',
    description: '',
    url:         'http://www.whalingmuseum.org'
  },
  {
    name:        'Stuart Lynn',
    location:    'Chicago, IL',
    description: '',
    url:         'https://github.com/stuartlynn'
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
  team: team,
  pages:         pages,
  background:    ''
)

# verify_workflow    = Workflow.create({name: "verify", tasks:[]  , project: p })



transcribe_tasks = {
  journal_date: {
      key:          0,
      tool:         'singleDate',
      field_name:   'date',
      label:        'Date',
      instruction:  'Please type-in the log date.',
      next_task:     'journal_entry'
  },
  journal_entry: {
      key:          1,
      tool:        'textBlock',
      field_name:  'journal_entry',
      label:       'Journal Entry',
      instruction: 'Please type-in the journal entry for this day.',
      next_task:   'additional_comment'
  },
  additional_comment: {
      key:          2,
      type:         'textBlock',
      field_name:   'other_entry',
      label:        'Other Entry',
      instruction:  'Type something, anything.',
      next_task:     nil
  }
}

transcribe_workflow = Workflow.create(
  {
    name:              'transcribe',
    label:             'Transcribe Workflow',
    first_task:        'journal_entry',
    tasks:             transcribe_tasks,
    enables_workflows: {},
    project:           project
  }
)

mark_workflow = Workflow.create(
  {
    name: 'mark',
    label: 'Mark Workflow',
    project: project,
    subject_fetch_limit: '10',
    enables_workflows: {},
    first_task: 'pick_page_type',
    tasks: {

      pick_page_type: {
        order: 0,
        tool: 'pick_one',
        instruction: 'What kind of page is this?',
        options: {
          history_sheet: {
            label: 'History Sheet',
            image: 'images/history_sheet_thumbnail.jpg',
            next_task: 'history_sheet_task'
          },
          casualty_form: {
            label: 'Casualty Form',
            image: 'images/casualty_form_thumbnail.jpg',
            next_task: 'casualty_form_task'
          },
          attestation: {
            label: 'Attestation',
            image: 'images/attestation_thumbnail.jpg',
            next_task: 'attestation_task'
          }
        },
        next_task: 'fake_task'
      },

      fake_task: {
        order: 3,
        tool: 'single',
        instruction: 'Is there anything left to mark here?',
        options: {
          yes: {
            label: 'Yes',
            image: ''
          },
          no: {
            label: 'No',
            image: ''
          }
        },
        next_task: 'mark_fields'
      },

      mark_fields: {
        tool: 'drawing',
        instruction: 'Pick a field and mark it with the corresponding marking tool.',
        tools: [
          {type: 'superAwesomePointTool', label: 'SuperAwesomePointTool', color: 'red'},
          {type: 'textRow', label: 'Text Row', color: 'green'},
          {type: 'line', label: 'Line', color: 'yellow'},
          {type: 'rectangle', label: 'Rectangle', color: 'lime'},
          {type: 'polygon', label: 'Polygon', color: 'cyan'},
          {type: 'circle', label: 'Circle', color: 'blue'},
          {type: 'ellipse', label: 'Ellipse', color: 'magenta'}
        ],
        next_task: nil
      },

      attestation_task: {
        order: 1,
        tool: 'pick_one_mark_one',
        options: {
          header: {
            tool: 'rectangle_tool',
            instruction: 'Draw a rectangle around the \'Header\' region.'
          },
          oath: {
            tool: 'rectangle_tool',
            instruction: 'Draw a rectangle around the \'Oath\' region.'
          },
          attesting_officer: {
            tool: 'rectangle_tool',
            instruction: 'Draw a rectangle around the \'Attesting Officer\' region.'
          },
          question: {
            tool: 'rectangle_tool',
            instruction: 'Draw a rectangle around the \'Question\' region.'
          }
        }
      },
      history_sheet_task: {
        order: 2,
        tool: {},
        options: {}
      },
      casualty_form_task: {
      }
    }
  }
)

example_images= [
  'offline/example_subjects/logbookofalfredg1851unse_0083.jpg',
  'offline/example_subjects/logbookofalfredg1851unse_0083.jpg',
  'offline/example_subjects/logbookofalfredg1851unse_0083.jpg',
  'offline/example_subjects/logbookofalfredg1851unse_0083.jpg'
  ]

10.times do |i|
  Subject.create(
    name:"subject_#{i}", 
    location: {
      standard: example_images.sample
    }, 
    meta_data: { 
      width:504, height:782
    }, 
    workflows: [mark_workflow]
  )
end
