class ApplicationMailer < ActionMailer::Base
  default from: ENV['DEMISTIFIER_EMAIL_FROM'],
    to: ENV['DEMISTIFIER_EMAIL_TO']
  layout 'mailer'
end
