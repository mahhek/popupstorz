require 'clickatell'

class Sms < ActiveRecord::Base
end
def initialize(config)
    @config = config
  end

  def create(recipient, message_text)
    api.send_message(recipient, message_text)
  end

  private
  def api
    @api ||= Clickatell::API.authenticate(
      @config["api_key"],
      @config["username"],
      @config["password"]
    )
  end

