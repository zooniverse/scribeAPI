require 'spec_helper'

describe Classification do

  context 'associations' do
    it { should have_many(:triggered_followup_subjects) }

    it { should belong_to(:workflow) }
    it { should belong_to(:user) }
    it { should belong_to(:subject) }

  end

  context 'methods' do

    let(:project){Project.create(title: "test")}
    let(:workflow){Workflow.create(project_id: project.id)}
    let(:subject){Subject.create({workflow: workflow, name: "Basic Subject",location: {standard: "http://some_server.com/location.jpg"}} )}
    let(:subject_set){ Subject_set.create(name: "Record Grouping", state: active, workflow_id: workflow.id, subject: inactive_subject) }
    let(:classification){ Classification.create(workflow: workflow.id, subject_id: subject.id, annotations: [])}

    describe '#generate_new_subjects' do
      it 'should initally have status active' do
        pending("write the spec")
        expect(classification.generate_new_subjects).to be_an_instance_of(Subject)
      end
    end    

    describe '#no_annotation_values' do
      it 'should initally have status active' do
        pending("write the spec")
      end
    end

    describe '#increment_subject_number_of_annontation_values' do
      it 'should initally have status active' do
        pending("write the spec")
      end
    end

  end
end
