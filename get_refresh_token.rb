require 'dotenv/load'
require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'webrick'

Dotenv.load

# OOB_URI = 'https://abcd1234.ngrok.io/oauth2callback'.freeze # Replace with your actual ngrok URL
OOB_URI = 'http://localhost:3000/oauth2callback'.freeze

APPLICATION_NAME = 'Gmail API Ruby'.freeze
SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_READONLY

client_id = Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'])
token_store = Google::Auth::Stores::FileTokenStore.new(file: 'tokens.yaml')
authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
user_id = 'default'
credentials = authorizer.get_credentials(user_id)

if credentials.nil?
  url = authorizer.get_authorization_url(base_url: OOB_URI)
  puts "Open the following URL in the browser and authorize the application:"
  puts url

  server = WEBrick::HTTPServer.new(Port: 3000, DocumentRoot: ".")
  trap 'INT' do server.shutdown end

  server.mount_proc '/oauth2callback' do |req, res|
    res.body = 'Authorization successful. You can close this window.'
    code = req.query['code']
    credentials = authorizer.get_and_store_credentials_from_code(user_id: user_id, code: code, base_url: OOB_URI)
    puts "Refresh Token: #{credentials.refresh_token}"
    server.shutdown
  end

  server.start
else
  puts "Refresh Token: #{credentials.refresh_token}"
end