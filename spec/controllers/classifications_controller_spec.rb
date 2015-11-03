require 'spec_helper'

RSpec.describe ClassificationsController, type: :controller do

  before(:each) do 
    @project = create(:basic_project)
  end

  describe "POST #create" do
    it "creates a classification" do
      vals = {
        classifications: attributes_for(:mark_rectangle_classification)
      }
      vals[:meta_data] = {}
      vals[:meta_data][:started_at] = vals.delete :started_at
      vals[:meta_data][:finished_at] = vals.delete :finished_at

      post :create, vals
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
