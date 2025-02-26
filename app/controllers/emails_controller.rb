class EmailsController < ApplicationController
  def index
    gmail_service = GmailService.new
    @emails = gmail_service.fetch_inbox_emails

    render json: @emails
  end
end