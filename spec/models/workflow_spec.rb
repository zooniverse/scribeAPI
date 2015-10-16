require 'spec_helper'

describe Workflow do

  def mark_workflow
    {
      "name" => "mark",
      "label" => "Mark Workflow",

      "subject_fetch_limit" => "10",
      "generates_subjects" =>  true,
      "generates_subjects_after" =>  1,
      "generates_subjects_for" =>  "transcribe",
      "generates_subjects_max" =>  1,
      "retire_limit" => 2,

      "first_task" => "pick_page_type",

      "tasks" => {
        "pick_page_type" => {
          "tool" => "pickOne",
          "instruction" => "What kind of page is this?",
          "next_task" =>  nil,
          "tool_config" =>  {
            "options" => {
              "attestation_form" => {
                "label" => "attestation_form",
                "next_task" => "attestation_form_task"
              }
            }
          }
        },
        "attestation_form_task" => {
          "generates_subjects" =>  true,
          "tool" => "pickOneMarkOne",
          "instruction" => "Draw a rectangle around each record.",
          "tool_config" =>  {
            "tools" => [
              {"type" => "rectangleTool", "label" => "Occupation", "color" => "green", "generates_subject_type" => "att_textRowTool_name" },
              {"type" => "rectangleTool", "label" => "Surname", "color" => "green", "generates_subject_type" => "att_textRowTool_name" },
              {"type" => "rectangleTool", "label" => "Christian name", "color" => "green", "generates_subject_type" => "att_textRowTool_name" },
              {"type" => "rectangleTool", "label" => "Wounds", "color" => "green", "generates_subject_type" => "att_textRowTool_name" }
            ]
          },
          "next_task" => nil
        }
      }
    }
  end


  def classification_object
    { 
      "_id" => "555cdc15412d4d05952d0000",
      "workflow_id" => workflow.id,
      "subject_id" => subject.id,
      "location" => nil,
      "annotation" => { 
        "value" => "attestation_form",
        "subToolIndex" => 0,
        "toolName" => "textRowTool",
        "generates_subject_type" => "att_transcribe_number",
        "x" => 581.9763268672797,
        "y" => 188.2794353259611,
        "yUpper" => 188.2794353259611,
        "yLower" => 288.2794353259611 },
      "user_agent" => "Mozilla/5.0",
      "task_key" => "attestation_form_task",
      "tool_name" => "textRowTool"
     }
  end

  context 'associations' do
    it { should have_many(:subjects) }
    it { should have_many(:classifications) }
    it { should belong_to(:project) }

    it "should embed many albums" do
     relation = Workflow.relations['tasks']
     relation.klass.should ==(WorkflowTask)
     relation.relation.should ==(Mongoid::Relations::Embedded::Many)
   end
  end


  context 'methods' do

    let(:project){ Project.create(title: "Transcibe-a-lot") }
    let(:workflow){ Workflow.create(mark_workflow) }
    let(:workflow2){ Workflow.create(generates_subjects: false, project: project, name: "transcribe") }
    let(:subject_set){ SubjectSet.create(name: "Record Grouping", state: "active") }
    let(:primary_subject){ Subject.create(subject_set: subject_set, workflow: workflow ) }  
    let(:subject){ Subject.create(subject_set: subject_set, parent_subject: primary_subject, workflow: workflow2) }  

    describe '#subject_has_enough_classifications' do
      it 'should evaluate whether a subject.cassification is greater than workflow.generate_subjects_after' do
        subject = Subject.create(workflow: workflow, subject_set: subject_set)
        subject.classification_count = 1
        expect(workflow.subject_has_enough_classifications(subject)).to be(true)
      end
    end

    describe "#create_secondary_subjects" do

      it 'should increase the total number of subjects by 1' do
        classification = double(classification_object)
        task = double("attestation_form_task" => {
                      "generates_subjects" =>  true,
                      "tool" => "pickOneMarkOne",
                      "instruction" => "Draw a rectangle around each record.",
                      "tool_config" =>  {
                        "tools" => [
                          {"type" => "rectangleTool", "label" => "Occupation", "color" => "green", "generates_subject_type" => "att_textRowTool_name" },
                          {"type" => "rectangleTool", "label" => "Surname", "color" => "green", "generates_subject_type" => "att_textRowTool_name" },
                          {"type" => "rectangleTool", "label" => "Christian name", "color" => "green", "generates_subject_type" => "att_textRowTool_name" },
                          {"type" => "rectangleTool", "label" => "Wounds", "color" => "green", "generates_subject_type" => "att_textRowTool_name" }
                        ]
                      },
                      "next_task" => nil
                    }
                )

        allow(classification).to receive(:subject).and_return(primary_subject)
        allow(classification).to receive(:annotation).and_return(classification_object["annotation"])
        expect(classification).to receive(:workflow).and_return(workflow)
        expect(classification).to receive(:child_subject).and_return(subject)

        expect(workflow).to receive(:task_by_key).and_return(task)
        expect(task).to receive(:generates_subjects).and_return(true)
        expect(task).to receive(:find_tool_box).and_return({"type" => "rectangleTool", "label" => "Occupation", "color" => "green", "generates_subject_type" => "att_textRowTool_name" })
        expect(classification).to receive(:child_subject=)

        classification.subject.location = {standard: "this/is/a/img.jpg"}
        allow(classification).to receive(:save)

        expect{workflow.create_secondary_subjects(classification)}.to change{Subject.all.count}.by(1)
        
      end

    end  

  end 

end
