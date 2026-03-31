class ApplicationMailer < ActionMailer::Base
  helper ApplicationHelper

  default from: -> { ENV["GOOGLE_SMTP_USER"].presence || "Ezpense <noreply@localhost>" }
  layout "mailer"
end
