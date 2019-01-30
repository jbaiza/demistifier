class ContactsController < ApplicationController
  def index
    if params[:name]
      @message = Message.new(message_params)
      if @message.save
        ContactsMailer.send_mail(@message).deliver_now
      end
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def message_params
    params.permit(:name, :email, :message)
  end
end
