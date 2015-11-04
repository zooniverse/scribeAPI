
FactoryGirl.define do
  factory :project do
    key 'test-project'
    status 'active'

    factory :basic_project do
      after(:create) do |project|
        create :mark_workflow, project: project
        create :transcribe_workflow, project: project
      end
    end

  end
end
