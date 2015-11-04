
FactoryGirl.define do

  mark_tasks = JSON.parse('{
    "test_task": {
      "tool": "pickOneMarkOne",
      "generates_subjects": true,
      "tool_config" : {
        "options": [
          {"type": "rectangleTool", "label": "Date", "color": "red", "generates_subject_type": "test_date"},
          {"type": "rectangleTool", "label": "Number", "color": "blue", "generates_subject_type": "test_number"}
        ]
      },
      "next_task": null
    },

    "completion_assessment_task": {
      "tool_config": {
        "displays_transcribe_button": false
      }
    }
  }')

  factory :workflow do
    project

    factory :mark_workflow do
      name 'mark'
      generates_subjects_for 'transcribe'

      after(:build) do |workflow|
        mark_tasks.each do |(key,h)|
          h[:key] = key
          workflow.tasks << WorkflowTask.new(h)
        end
      end
    end

    factory :transcribe_workflow do
      name 'transcribe'
    end

  end
end

