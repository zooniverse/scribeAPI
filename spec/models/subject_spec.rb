require 'spec_helper'

describe Subject do
  let(:project){Project.create(title: "test")}
  let(:workflow){Workflow.create(project_id: project.id)}
  let(:subject){Subject.create({workflow: workflow, name: "Basic Subject",location: {standard: "http://some_server.com/location.jpg"}} )}
  let(:inactive_subject){Subject.create({workflow_id: workflow.id, name: "Inactive Subject",location: {standard: "http://some_server.com/location.jpg"}, state: "inactive"})}
  let(:done_subject){Subject.create({workflow_id: workflow.id,name: "Inactive Subject",location: {standard: "http://some_server.com/location.jpg"}, state: "inactive"})}


  it 'should initally have state active' do
    subject.state.should  ==  "active"
  end

  it 'should initally have zero classification count' do
    subject.classification_count.should == 0
  end

  it 'should initally have zero classification count' do
    subject.classification_count.should ==  0
  end

  it 'should change state to done when it reaches classification count' do
    subject.classification_count = subject.workflow.retire_limit - 1
    subject.save
    subject.increment_classification_count_by(1)
    subject.state.should == 'done'
  end

  it 'should increment classification count' do
    subject.increment_classification_count_by 1
    subject.classification_count.should  == 1
  end

  it 'should properly activate when told to' do
    inactive_subject.activate!
    inactive_subject.state.should ==  "active"
  end
end
