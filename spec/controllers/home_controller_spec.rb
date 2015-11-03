require 'spec_helper'

RSpec.describe HomeController, type: :controller do

  before(:each) do 
    @project = create(:project)
    @user = create(:user)
  end

  describe "GET #index" do
    it "responds successfully with an HTTP 200 status code" do
      get :index
      expect(response).to be_success
      expect(response).to have_http_status(200)
    end
  end

end
