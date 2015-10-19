require 'spec_helper'

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
            "total_subjects" => 0,
            "active_subjects" => 0 
          } 
        }
      ) 
    }

    describe '#activate!' do
      it 'activate_subject count of the workflow' do
        pending("are we actually using this method? -- AMS").error("maybe in the rake project_load")
      end
    end
    
    describe '#inc_subject_count_for_workflow' do
      it 'should increment a specific workflows total_subjects key by 1' do
        subject_set.inc_subject_count_for_workflow(workflow)
        subject_set.reload
        expect(subject_set.counts["#{workflow.id.to_s}"]["total_subjects"]).to eq(1)
      end
    end

    describe '#subject_activated_on_workflow' do
      it 'should increment a specific workflows active_subjects key by 1' do
        subject_set.subject_activated_on_workflow(workflow)
        subject_set.reload
        expect(subject_set.counts["#{workflow.id.to_s}"]["active_subjects"]).to eq(1)
      end
    end

    describe '#subject_completed_on_workflow' do
      it 'to increment self.count.worklowid.complete_subjects by 1' do
        subject_set.subject_completed_on_workflow(workflow)
        subject_set.reload
        expect(subject_set.counts["#{workflow.id.to_s}"]["complete_subjects"]).to eq(1)
      end

      it 'to decrement self.count.worklowid.active_subjects by 1' do
        subject_set.subject_completed_on_workflow(workflow)
        subject_set.reload
        expect(subject_set.counts["#{workflow.id.to_s}"]["active_subjects"]).to eq(-1)

      end
    end

  end
end
