
FactoryGirl.define do
  factory :project do
    key 'test-project'
    status 'active'

    factory :basic_project do
      after(:create) do |project|
        project.workflows << create(:mark_workflow)
        project.workflows << create(:transcribe_workflow)
      end
    end

  end
end
