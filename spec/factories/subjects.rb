FactoryGirl.define do
  factory :subject do
    location({
      standard: "https://s3.amazonaws.com/scribe.nypl.org/emigrant-s4/full/e3d96570-00b1-0133-8607-58d385a7bbd0.left-bottom.jpg",
      thumbnail: "https://s3.amazonaws.com/scribe.nypl.org/emigrant-s4/thumb/e3d96570-00b1-0133-8607-58d385a7bbd0.left-bottom.jpg"
    })

    factory :root_subject do
      type 'root'
    end
  end
end

