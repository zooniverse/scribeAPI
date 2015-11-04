FactoryGirl.define do
  factory :classification do
    started_at '2015-11-03T22:32:29.043Z'
    finished_at '2015-11-03T22:32:29.043Z'

    association :workflow, factory: :mark_workflow
    # subject_set
    # task_key create(:mark_workflow).tasks.first.key

    # task_key mark_workflow.tasks.first.key
    annotation({})
    
    factory :mark_rectangle_classification do
      annotation({
        toolName: 'rectangleTool',
        subToolIndex: 0,
        x: '313.6253767715221',
        y: '95.30162651842701',
        width: '239.12044221234834',
        height: '90.10335598105826'
      })
    end

  end
end

