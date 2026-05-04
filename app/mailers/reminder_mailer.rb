# frozen_string_literal: true

class ReminderMailer < ApplicationMailer
  def question_reminder(user, question, days_before_deadline)
    @user = user
    @question = question
    @days_before_deadline = days_before_deadline

    mail(
      to: @user.email,
      subject: "【Honest Voice】「#{@question.title}」の回答締切まであと#{@days_before_deadline}日です"
    )
  end
end