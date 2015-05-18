require 'spec_helper'


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
        },
        "history_form_task"=>{
          "generates_subjects"=> true,
          "tool"=>"mark",
          "instruction"=>"Draw a rectangle around each record.",
          "tools"=> [
            {"type"=> "rectangleTool", "label"=> "Occupation", "color"=> "green", "generates_subject_type"=> "att_textRowTool_name" },
            {"type"=> "rectangleTool", "label"=> "Surname", "color"=> "green", "generates_subject_type"=> "att_textRowTool_name" },
            {"type"=> "rectangleTool", "label"=> "Christian name", "color"=> "green", "generates_subject_type"=> "att_textRowTool_name" },
            {"type"=> "rectangleTool", "label"=> "Wounds", "color"=> "green", "generates_subject_type"=> "att_textRowTool_name" }
          ],
          "next_task"=> nil
        }
      }
    }
  end


  def front_end_classification_object
    { "_id" => "55525d08782d314af3300000", 
    "workflow_id" => "555257fb782d31c138010000", 
    "subject_id" => "555257fb782d31c138070000", 
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
            "subject_id" => @subject.id, 
            "workflow_id" => "555257fb782d31c138010000", 
            "generates_subjects" => true, 
            "tool_task_description" => { 
              "type" => "textRowTool", 
              "label" => "Question", 
              "color" => "green", 
              "generates_subject_type" => "att_textRowTool_question", 
              "_key" => 0.9674423730466515 } 
            } 
        ], 
      "started_at" => "2015-05-12T20:05:28.217Z", 
      "finished_at" => "2015-05-12T20:05:28.217Z", 
      "user_agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_5)", 
      "child_subject_id" => "55525d08782d314af3310000" 
    }
  end

  context 'associations' do
    it { should have_many(:subjects) }
    it { should have_many(:classifications) }
    it { should belong_to(:project) }
  end

  before(:each) do
    @project = Project.create(title: "Transcibe-a-lot")
    @workflow = Workflow.create(mark_workflow)
    @workflow2 = Workflow.create(generates_new_subjects: false, project: @project)
    @subject_set = SubjectSet.create(name: "Record Grouping", state: "active")
    
    # @subject2 = Subject.crete(workflow: @workflow2)
    # @classification = Classification.create(workflow: @workflow2)
    # @subject.classifications << @classification
  end


  context 'methods' do
    
    describe '#subject_has_enough_classifications' do
      it 'should evaluate whether a subject.cassification is greater than workflow.generates_subjects_after' do
        @subject = Subject.create(workflow: @workflow, subject_set: @subject_set)
        @subject.classification_count = 1
        expect(@workflow.subject_has_enough_classifications(@subject)).to be(true)
      end
    end

    describe "#create_follow_up_subjects" do
      it "only if the workflow.generates_subjects == true should the method allows secondary subject generation" do
        expect(@workflow.create_follow_up_subjects(classification_object)).to be(true)
      end
    end
    


    # describe '#create_secondary_subjects' do

    #   it 'Should correctly update its subject counter when a subject changes status ' do
    #     pending("dealing with other methods first")
    #     s = Subject.create(:workflow =>@workflow, :status =>"pending")
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
