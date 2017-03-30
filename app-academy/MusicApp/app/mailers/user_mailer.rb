class UserMailer < ActionMailer::Base
  default from: "no-reply@musiciscool.com"

  def activation_email(user)
    @user = user
    @url = "#{activate_users_url}?activation_token=#{@user.activation_token}"
    mail(to: user.email, subject: "Music Is Cool Activation Email")
  end
end
