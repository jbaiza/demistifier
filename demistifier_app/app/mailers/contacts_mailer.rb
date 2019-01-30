class ContactsMailer < ApplicationMailer
  def send_mail(message)
    @message = message

    mail reply_to: message.email,
         subject: I18n.t('contacts_mailer.send_mail.subject')
  end
end
