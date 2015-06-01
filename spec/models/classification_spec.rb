require 'spec_helper'

describe Classification do

  context 'associations' do
    it { should have_many(:triggered_followup_subjects) }

    it { should belong_to(:workflow) }
    it { should belong_to(:user) }
    it { should belong_to(:subject) }

  end

  context 'methods' do

    let(:project){ Project.create(title: "test") }
    let(:subject_set){ SubjectSet.create(name: "Record Grouping") }
    let(:workflow){ Workflow.create(project_id: project.id)}
    let(:subject){ Subject.create(workflow: workflow, subject_set: subject_set, name: "Basic Subject") }
    let(:classification){ 
      Classification.create(
        workflow: workflow.id, 
        subject: subject, 
        annotation: 
        { 
          "task" => "attestation_form_task",
          "subject_id" => "555cdc08782d311833070000",
          "workflow_id" => "555cdc08782d311833010000",
          "key" => 0,
          "toolIndex" => 0,
          "toolName" => "textRowTool",
          "x" => 563.3333333333334,
          "y" => 182.5,
          "tool_task_description" => { 
            "type" => "textRowTool",
            "label" => "Number",
            "color" => "green",
            "generates_subject_type" => "att_textRowTool_number",
          } 
        }
      ) 
    }

    describe '#check_for_retirement' do
      it 'if the classification.type is not root, return nil' do
        classification.subject.type = "em_date_record"

        expect(classification.check_for_retirement).to be(nil)
      end
    end
    
    describe '#increment_subject_classification_count' do
      it 'should increment a subjects classifcation count by 1' do
        classification.workflow.generates_new_subjects = false

        expect{classification.increment_subject_classification_count}.to change{subject.classification_count}.by(1)
      end
    end

    describe '#generate_new_subjects' do
      it 'should return nil if workflow.generate_new_subjects is false' do
        workflow2 = Workflow.create(generates_new_subjects: false)
        classification = Classification.new(workflow: workflow2)
        expect(classification.generate_new_subjects).to be(nil)
      end
    end  



  end
end
