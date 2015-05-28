require 'spec_helper'
require 'pry'

describe SubjectSet do

  context 'associations' do
    it { should have_many(:subjects) }

    it { should belong_to(:group) }
    it { should belong_to(:project) }

  end

  context 'methods' do

    let(:project){ Project.create(title: "test") }
    let(:workflow){ Workflow.create(project_id: project.id)}
    let(:subject_set){ 
      SubjectSet.create(  
        state: "active",
        name: "Ordered Group of Records",
        project: project,
        counts: { 
          "#{workflow.id.to_s}"=> { 
            "total_subjects" => 1,
            "active_subjects" => 2 
          } 
        }
      ) 
    }

    describe '#activate!' do
      it '' do
        pending("are we actually using this method -- AMS").error("maybe in the rake project_load")
      end
    end
    
    describe '#inc_subject_count_for_workflow' do
      it 'should increment a specific workflows total_subjects key by 1' do

        expect{subject_set.inc_subject_count_for_workflow(workflow)}.to change{subject_set.counts["#{workflow.id.to_s}"]["total_subjects"]}.by(1)

      end
    end

    describe '#subject_activated_on_workflow' do
      it 'should increment a specific workflows active_subjects key by 1' do
        expect{subject_set.subject_activated_on_workflow(workflow)}.to change{subject_set.counts["#{workflow.id.to_s}"]["active_subjects"]}.by(1)
      end
    end

    # describe '#subject_completed_on_workflow' do
    #   it '' do
    #   pending("write test")
    #   end
    # end

    # describe '#subject_completed_on_workflow' do
    #   it '' do
    #   pending("write test")
    #   end
    # end

  end
end
