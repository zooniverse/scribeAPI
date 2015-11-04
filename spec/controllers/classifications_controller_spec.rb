require 'spec_helper'

RSpec.describe ClassificationsController, type: :controller do

  before(:each) do 
    @project = create(:basic_project)
    create(:transcribe_workflow)
    puts "created project: #{@project.workflows.map { |w| w.name }}", @project.workflows.find_by(name: 'transcribe').name
  end

  describe "POST #create" do
    it "creates a classification" do
      vals = attributes_for(:mark_rectangle_classification)
      vals[:metadata] = {}
      vals[:metadata][:started_at] = vals.delete :started_at
      vals[:metadata][:finished_at] = vals.delete :finished_at

      # Not sure why the `association` call inside classification factory doesn't take care of this:
      vals[:workflow_id] = create(:mark_workflow).id
      vals[:subject_id] = create(:root_subject).id

      vals[:task_key] = create(:mark_workflow).tasks.first.key

      puts "POST: #{vals.inspect}"

      post :create, classifications: vals
      expect(response).to be_success
      expect(response).to have_http_status(200)
      puts "got resp: #{response.body}"

=begin
      content = JSON.parse response.body
      expect(content['project']).to be_truthy
      expect(content['project']).to be_an_instance_of(Hash)
      expect(content['project']['title']).to be_an_instance_of(String)
      expect(content['project']['workflows']).to be_truthy
      expect(content['project']['workflows'].size).to eq(2)

      mark_workflow = content['project']['workflows'].select { |w| w['name'] == 'mark' }.first
      expect(mark_workflow).to be_truthy
      expect(mark_workflow['tasks']).to be_truthy
=end
    end
  end

end
