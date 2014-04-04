require 'spec_helper'


describe Workflow do 

  before(:each) do 
    @wf = Workflow.create()
  end

  def triggering_annotations
    "annotations" =>[{"key" =>"drawSomething","value" =>"point","marks" =>[{"x" =>201.44,"y" =>573.214,"frame" =>0}]},{"started_at" =>"Fri, 04 Apr 2014 15:11:27 GMT","finished_at" => "Fri, 04 Apr 2014 15:11:29 GMT"}{"workflow":"marking"}]}} 
  end

  def marking_task
    "drawSomething" => {
        "type" => "drawing",
        "question" => "Draw something.",
        "triggers_workflow" => @wf.id.to_s , 
        "choices" => [ {
          "value" => "point",
          "image" => "//placehold.it/30.png",
          "label" => "Show Date",
          "color" => "# "
        },
        {
          "value" => "point",
          "image" => "//placehold.it/30.png",
          "label" => "Location",
          "color" => "#ff0"
        },
        {
          "value" => "point",
          "image" => "//placehold.it/30.png",
          "label" => "Cast Member",
          "color" => "#ff0"
        },
        {
          "value" => "point",
          "image" => "//placehold.it/30.png",
          "label" => "Production Staff",
          "color" => "#ff0"
        },
        {
          "value" => "point",
          "image" => "//placehold.it/30.png",
          "label" => "Thearter Name",
          "color" => "#ff0"
        }
        ]
    }
  end

  it 'Should correctly update its subject counter when a subject changes state' do 
    s = Subject.create(:workflows =>[@wf])
    s.activate!
    @wf.active_subjects.should  == 1 
    s.retire!
    @wf.active_subjects.should  == 0 
  end


  it 'Should trigger a new subject in a subsequent workflow if a task requires it' do 
    triggering_workflow  = Workflow.create(:tasks=> marking_task, first_task: "drawSomething")
    s = Subject.create(:workflows =>[triggering_workflow.id])

    classification = Classification.create(:subject => s, :workflow => triggering_workflow, annotations: triggering_annotations )
    @wf.active_subjects.should == 1
    Subject.find(:workflow_ids => @wf.id).count.should  == 1 
    
  end
end