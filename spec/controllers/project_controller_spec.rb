require 'spec_helper'

RSpec.describe ProjectsController, type: :controller do

  before(:each) do 
    @project = create(:basic_project)
  end

  describe "GET #index" do
    it "responds successfully with a valid project json" do
      get :index, format: :json
      expect(response).to be_success
      expect(response).to have_http_status(200)

      content = JSON.parse response.body
      expect(content['project']).to be_truthy
      expect(content['project']).to be_an_instance_of(Hash)
      expect(content['project']['title']).to be_an_instance_of(String)
      expect(content['project']['workflows']).to be_truthy
      expect(content['project']['workflows'].size).to eq(2)

      mark_workflow = content['project']['workflows'].select { |w| w['name'] == 'mark' }.first
      expect(mark_workflow).to be_truthy
      expect(mark_workflow).to be_an_instance_of(Hash)
      expect(mark_workflow['tasks']).to be_truthy
    end
  end

end
