require 'spec_helper'

describe Subject do

  context 'associations' do
    it { should have_many(:classifications) }
    it { should have_many(:favourites) }
    it { should have_many(:child_subjects) }
    it { should belong_to(:parent_subject) }
    it { should belong_to(:workflow) }
    it { should belong_to(:subject_set) }
  end

  context 'methods' do

    let(:project){Project.create(title: "test")}
    let(:subject_set){ SubjectSet.create(name: "Record Grouping", state: "active") }
    let(:workflow){Workflow.create(project_id: project.id)}
    let(:subject){
      Subject.create(
        {
          name: "Basic Subject",
          workflow: workflow, 
          subject_set: subject_set, 
          parent_subject: parent_subject, 
          retire_count: 1, 
          location: {standard: "http://some_server.com/location.jpg"}
        } 
    )}
    let(:inactive_subject){
      Subject.create( 
      {
        workflow_id: workflow.id, 
        name: "Inactive Subject", 
        status: "inactive", 
        location: {standard: "http://some_server.com/location.jpg"},
        subject_set: subject_set
      }
    )}
    let(:parent_subject){Subject.create(secondary_subject_count: 1, workflow: workflow, subject_set: subject_set)}

    describe '.status' do
      it 'should initally have status active' do
        expect(subject.status).to eq("active")
      end
    end

    describe '#activate!' do
      it 'should properly activate when told to' do
        inactive_subject.activate!
        expect(inactive_subject.status).to eq("active")
      end
    end

    describe '.classification_count' do
      it 'should initally have zero classification count' do
        expect(subject.classification_count).to eq(0)
      end
    end

    describe '#increment_parents_subject_count_by_one' do
      it 'if a subject has a parent subject, the method should increment counter on parent subject' do
        new_subject = Subject.new(parent_subject: parent_subject) #using new because the creating a new subject automatically calls #increment_parents_subject_count_by_one
        expect{new_subject.increment_parents_subject_count_by_one}.to change{parent_subject.secondary_subject_count}.by(1)
      end
    end

    describe '#retire!' do
      it "if a subject classification_count is greater than or equal to the retire limit, set subject status to retired" do
        subject.classification_count = 1
        subject.retire!
        expect(subject.status).to eq("retired")
      end
    end

  end
end
