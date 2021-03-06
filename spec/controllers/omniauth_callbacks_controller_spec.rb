require 'rails_helper'

# Enable real network connection
WebMock.allow_net_connect!

describe Users::OmniauthCallbacksController do

  describe 'google_oauth2' do
    before :each do
      google_hash
    end
    
    context 'when logging in with a valid email' do
      before :each do
        allow(User).to receive(:find_for_google_oauth2) { User.new }
        allow(controller).to receive(:sales_auth) { true }
      end

      it 'should verify if email belongs to a registered user' do
        expect(User).to receive(:find_for_google_oauth2).with(request.env["omniauth.auth"], nil)
        get :google_oauth2
      end
    
      it 'should redirect to the email page' do
        get :google_oauth2
        expect(response).to redirect_to new_email_path
      end
    end

    context 'logging in when javascript is enabled' do
      it 'should render a popup' do
        request.env['omniauth.params']['popup'] = true
        get :google_oauth2
        expect(response).to render_template("partials/_callback")
      end
    end

    context 'when logging with with an unauthorized email' do
      it 'should redirect to the login page' do
        get :google_oauth2
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'sales_oauth' do
    before :each do
      google_hash
    end

    context 'when logging in with invalid salesforce' do
      it 'should redirect to the root page' do
        allow(controller).to receive(:sales_auth) { false }
        get :google_oauth2
        expect(response).to redirect_to root_path
      end
    end
  end
end