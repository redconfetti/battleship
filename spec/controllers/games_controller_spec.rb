require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  let(:player) { Player.create(email: 'johndoe@example.com', password: 'someP@$$word') }

  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #pending" do
    it "returns http success" do
      get :pending
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    before(:each) { sign_in player }
    it "returns http success" do
      post :create
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['id']).to_not be_nil
      expect(json_response['created_at']).to_not be_nil
      expect(json_response['updated_at']).to_not be_nil
      expect(json_response['startDate']).to_not be_nil
      expect(json_response['startDateUnixTimestamp']).to_not be_nil
      expect(json_response['status']).to eq 'pending'
    end
  end

end
