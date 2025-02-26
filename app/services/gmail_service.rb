require 'google/apis/gmail_v1'
require 'googleauth'

class GmailService
  OOB_URI = 'http://localhost:3000/oauth2callback'.freeze

  APPLICATION_NAME = 'Gmail API Ruby'.freeze
  SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_READONLY

  def initialize
    @service = Google::Apis::GmailV1::GmailService.new
    @service.client_options.application_name = APPLICATION_NAME
    @service.authorization = authorize
    # service.authorization = credentials

    # Fetch the inbox
    # response = service.list_user_messages('me', max_results: 10)
    # messages = response.messages

    # Display the message IDs
    # render plain: messages.map(&:id).join("\n")
  end

  def fetch_inbox_emails
    result = @service.list_user_messages('me', q: 'in:inbox')
    # result.messages


    messages = result.messages

    # Extract and display details
    message_details = messages.map do |msg|
      message = @service.get_user_message('me', msg.id)
      headers = message.payload.headers

      from = headers.find { |h| h.name == 'From' }&.value
      to = headers.find { |h| h.name == 'To' }&.value
      cc = headers.find { |h| h.name == 'Cc' }&.value
      subject = headers.find { |h| h.name == 'Subject' }&.value

      {
        from: from,
        to: to,
        cc: cc,
        subject: subject
      }
    end

    format_message_details(message_details)

  rescue Google::Apis::Error => e
    puts "An error occurred: #{e}"
    []
  end

  private

  def format_message_details(details)
    details.map do |detail|
      <<~MESSAGE
        From: #{detail[:from]}
        To: #{detail[:to]}
        #{'Cc: ' + detail[:cc] if detail[:cc]}
        Subject: #{detail[:subject]}
      MESSAGE
    end.join("\n\n")
  end

  def authorize
    client_id = Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'])
    token_store = Google::Auth::Stores::FileTokenStore.new(file: 'tokens.yaml')
    authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: OOB_URI)
      puts "Open the following URL in the browser and enter the resulting code after authorization"
      puts url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(user_id: user_id, code: code, base_url: OOB_URI)
    end
    credentials
  end
end