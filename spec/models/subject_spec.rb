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
    let(:workflow){Workflow.create(project_id: project.id)}
    let(:subject){Subject.create({workflow: workflow, name: "Basic Subject",location: {standard: "http://some_server.com/location.jpg"}} )}
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
    let(:done_subject){Subject.create({workflow_id: workflow.id,name: "Inactive Subject",location: {standard: "http://some_server.com/location.jpg"}, status: "inactive"})}
    let(:subject_set){ SubjectSet.create(name: "Record Grouping", state: "active") }

    describe '.status' do
      it 'should initally have status active' do
        expect(subject.status).to eq("active")
      end
    end

    describe '.classification_count' do
      it 'should initally have zero classification count' do
        expect(subject.classification_count).to eq(0)
      end
    end

    describe '#increment_parents_subject_count_by_one' do
      it 'should change status to done when it reaches classification count' do
        
      end
    end

    describe '#activate!' do
      it 'should properly activate when told to' do
        inactive_subject.activate!
        expect(inactive_subject.status).to eq("active")
      end
    end

  end
end
