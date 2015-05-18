require 'spec_helper'
require 'pry'


describe Workflow do

  def mark_workflow
    {
      "name"=>"mark",
      "label"=>"Mark Workflow",

      "subject_fetch_limit"=>"10",
      "generates_new_subjects"=> true,
      "generate_subjects_after"=> 1,
      "generates_subjects_for"=> "transcribe",
      "generate_subjects_max"=> 1,
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
          "generate_subjects"=> true,
          "tool"=>"mark",
          "instruction"=>"Draw a rectangle around each record.",
          "tools"=> [
            {"type"=> "textRowTool", "label"=> "Number", "color"=> "green", "generated_subject_type"=> "att_textRowTool_number" },
            {"type"=> "textRowTool", "label"=> "Name", "color"=> "green", "generated_subject_type"=> "att_textRowTool_name" },
            {"type"=> "textRowTool", "label"=> "Regiment", "color"=> "green", "generated_subject_type"=> "att_textRowTool_regiment" },
            {"type"=> "textRowTool", "label"=> "Question", "color"=> "green", "generated_subject_type"=> "att_textRowTool_question" }
          ],
          "next_task"=> nil
        },
        "history_form_task"=>{
          "generate_subjects"=> true,
          "tool"=>"mark",
          "instruction"=>"Draw a rectangle around each record.",
          "tools"=> [
            {"type"=> "rectangleTool", "label"=> "Occupation", "color"=> "green", "generated_subject_type"=> "att_textRowTool_name" },
            {"type"=> "rectangleTool", "label"=> "Surname", "color"=> "green", "generated_subject_type"=> "att_textRowTool_name" },
            {"type"=> "rectangleTool", "label"=> "Christian name", "color"=> "green", "generated_subject_type"=> "att_textRowTool_name" },
            {"type"=> "rectangleTool", "label"=> "Wounds", "color"=> "green", "generated_subject_type"=> "att_textRowTool_name" }
          ],
          "next_task"=> nil
        }
      }
    }
  end


  def classification_object
    { "_id" => "55525d08782d314af3300000", 
    "workflow_id" => workflow.id, 
    "subject_id" => primary_subject.id, 
    "location" => nil, 
    "annotations" => 
      [ { 
        "_toolIndex" => 3,  
        "value" => [ 
          { 
            "key" => 0, 
            "tool" => 3, 
            "toolName" => 
            "textRowTool", 
            "x" => 290.18228252155285, 
            "y" => 468.2760019591559, 
            "yUpper" => 468.2760019591559, 
            "yLower" => 510.3945391348069, 
            "_key" => 0.1621886498760432 } ], 
            "task" => "attestation_form_task", 
            "_key" => 0.7740179121028632, 
            "subject_id" => subject.id, 
            "workflow_id" => "555257fb782d31c138010000", 
            "generate_subjects" => true, 
            "tool_task_description" => { 
              "type" => "textRowTool", 
              "label" => "Question", 
              "color" => "green", 
              "generated_subject_type" => "att_textRowTool_question", 
              "_key" => 0.9674423730466515 } 
            } 
        ], 
      "started_at" => "2015-05-12T20:05:28.217Z", 
      "finished_at" => "2015-05-12T20:05:28.217Z", 
      "user_agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5)", 
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
    let(:subject){ Subject.create(subject_set: subject_set, workflow: workflow2) }  
    let(:primary_subject){ Subject.create(subject_set: subject_set, workflow: workflow ) }  
    # let(:classification){ Classification.create(workflow: @workflow, subject: primary_subject, annotations: classification_object.annotations) }

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
        classification = Classification.new(classification_object) 

        classification.subject.classification_count = 1
        # we expect the Subject count to increase because 1 through Classification creation and once by calling #create_secondary_subjects
        expect{workflow.create_secondary_subjects(classification)}.to change{Subject.all.count}.by(2)
      end

      it 'should set the classification.child_subject_id to the generated subject' do
        # pending("write this test").error()
        workflow2
        # classification = double(classification_count: 1, subject: primary_subject)
        classification = double(classification_object)
        # classification = Classification.new(classification_object)
        allow(classification).to receive(:subject).and_return(primary_subject)
        allow(classification).to receive(:child_subject)
        classification.subject.classification_count = 1

        child_subject = workflow.create_secondary_subjects(classification)
        binding.pry
        expect(classification.child_subject.id).to eq(primary_subject.child_subjects[0].id)

      end

    end
    


    # describe '#create_secondary_subjects' do

    #   it 'Should correctly update its subject counter when a subject changes status ' do
    #     pending("dealing with other methods first")
    #     s = Subject.create(:workflow =>workflow, :status =>"pending")
    #     s.activate!
    #     @workflow.active_subjects.should  == 1
    #     s.retire!
    #     @workflow.active_subjects.should  == 0
    #   end

    #   it 'should trigger a new subject in a subsequent workflow if a task requires it' do
    #     pending("dealing with other methods first")
    #     triggering_workflow  = Workflow.create(:tasks=> marking_task, first_task: "drawSomething")
    #     s = Subject.create(:workflows =>[triggering_workflow.id])

    #     classification = Classification.create(:subject => s, :workflow => triggering_workflow, annotations: triggering_annotations )
    #     @workflow.active_subjects.should == 1
    #     Subject.find(:workflow_ids => @workflow.id).count.should  == 1

    #   end

    # end


  end #end of context
end
