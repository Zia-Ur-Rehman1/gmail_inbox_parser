require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'dotenv/load'

class OauthController < ApplicationController
  def callback
    client_id = Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'])
    token_store = Google::Auth::Stores::FileTokenStore.new(file: 'tokens.yaml')
    authorizer = Google::Auth::UserAuthorizer.new(client_id, Google::Apis::GmailV1::AUTH_GMAIL_READONLY, token_store)
    user_id = 'default'
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, 
      code: params[:code], 
      base_url: oauth2callback_url
    )
    
    render plain: "Refresh Token: #{credentials.refresh_token}"
  end
end