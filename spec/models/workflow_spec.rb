require 'spec_helper'
require 'pry'


describe Workflow do

  def mark_workflow
    {
      "name"=>"mark",
      "label"=>"Mark Workflow",

      "subject_fetch_limit"=>"10",
      "generates_new_subjects"=> true,
      "generates_subjects_after"=> 1,
      "generates_subjects_for"=> "transcribe",
      "generates_subjects_max"=> 1,
      "retire_limit"=>2,

      "first_task"=>"pick_page_type",

      "tasks"=>{
        "pick_page_type"=>{
          "order"=>0,
          "tool"=>"pick_one",
          "instruction"=>"What kind of page is this?",
          "next_task"=> nil,
          "options"=>{
            "history_sheet"=>{
              "label"=>"history_sheet",
              "next_task"=>"history_form_task"
            },
            "attestation_form"=>{
              "label"=>"attestation_form",
              "next_task"=>"attestation_form_task"
            }
          }
        },
        "attestation_form_task"=>{
          "generates_subjects"=> true,
          "tool"=>"mark",
          "instruction"=>"Draw a rectangle around each record.",
          "tools"=> [
            {"type"=> "textRowTool", "label"=> "Number", "color"=> "green", "generates_subject_type"=> "att_textRowTool_number" },
            {"type"=> "textRowTool", "label"=> "Name", "color"=> "green", "generates_subject_type"=> "att_textRowTool_name" },
            {"type"=> "textRowTool", "label"=> "Regiment", "color"=> "green", "generates_subject_type"=> "att_textRowTool_regiment" },
            {"type"=> "textRowTool", "label"=> "Question", "color"=> "green", "generates_subject_type"=> "att_textRowTool_question" }
          ],
          "next_task"=> nil
        }
      }
    }
  end


  def classification_object
    { 
      "_id" => "555cdc15412d4d05952d0000",
      "workflow_id" => workflow.id,
      "subject_id" => primary_subject.id,
      "annotation" => { 
        "_toolIndex" => 0,
        "task" => "attestation_form_task",
        "_key" => 0.8344426495023072,
        "subject_id" => "555cdc08782d311833070000",
        "workflow_id" => "555cdc08782d311833010000",
        "key" => 0,
        "toolIndex" => 0,
        "toolName" => "textRowTool",
        "x" => 563.3333333333334,
        "y" => 182.5,
        "yUpper" => 182.5,
        "yLower" => 282.5,
        "tool_task_description" => { 
          "type" => "textRowTool",
          "label" => "Number",
          "color" => "green",
          "generates_subject_type" => "att_textRowTool_number",
          "_key" => 0.1147315001580864 } 
        },
      "started_at" => "2015-05-20T19:10:13.887Z",
      "finished_at" => "2015-05-20T19:10:13.887Z",
      "user_agent" => "Mozilla/5.0" 
    }
  end

  context 'associations' do
    it { should have_many(:subjects) }
    it { should have_many(:classifications) }
    it { should belong_to(:project) }
  end


  context 'methods' do

    let(:project){ Project.create(title: "Transcibe-a-lot") }
    let(:workflow){ Workflow.create(mark_workflow) }
    let(:workflow2){ Workflow.create(generates_new_subjects: false, project: project, name: "transcribe") }
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
      
      it "return false if self.generates_new_subjects is false" do
        expect(workflow2.create_secondary_subjects(classification_object)).to be(nil)
      end

      it 'should increase the total number of subjects by 1' do
        
        workflow = Workflow.create(generates_new_subjects: true, name: "transcribe")
        classification = double(classification_object)
        allow(classification).to receive(:subject).and_return(primary_subject)
        allow(classification).to receive(:workflow).and_return(workflow)

        allow(classification).to receive(:annotation).and_return(classification_object["annotation"])
        classification.subject.location = {standard: "this/is/a/img.jpg"}
        allow(classification).to receive(:child_subject=)
        allow(classification).to receive(:save)
        subject.classification_count = 1

        expect{workflow.create_secondary_subjects(classification)}.to change{Subject.all.count}.by(1)
        
      end

    end

    describe '#find_tools_from_subject_type' do
      it 'should find the tools for a given subject_type in a workflow' do
        
        expect(workflow.find_tools_from_subject_type("att_textRowTool_number")).to eq({"type"=> "textRowTool", "label"=> "Number", "color"=> "green", "generates_subject_type"=> "att_textRowTool_number" })

      end
    end    


  end 
end
