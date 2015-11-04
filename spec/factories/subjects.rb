FactoryGirl.define do
  factory :subject do

    subject_set
    random_no 0.014725536017314744
    updated_at "2015-11-02T17:27:01.645Z"
    created_at "2015-11-02T17:27:01.643Z"
    location({
      "standard" => "https://s3.amazonaws.com/scribe.nypl.org/emigrant-s4/full/e2d1b360-00b1-0133-7643-58d385a7bbd0.right-bottom.jpg",
      "thumbnail" => "https://s3.amazonaws.com/scribe.nypl.org/emigrant-s4/thumb/e2d1b360-00b1-0133-7643-58d385a7bbd0.right-bottom.jpg"
    })
    meta_data({})
    width 1374
    height 1091
    order 86
    # workflow_id "56379cdd70617545e9010000"
    association :workflow, factory: :mark_workflow
    group_id "56379cdd70617545e91b0000"

    factory :root_subject do

    end
  end
end
