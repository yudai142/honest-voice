require 'rails_helper'

RSpec.describe ReminderMailer, type: :mailer do
  let(:user) { create(:user, email: 'member@example.com', name: 'Member User') }
  let(:question) { create(:question, title: '回答お願いします', deadline: 3.days.from_now) }

  describe '#question_reminder' do
    let(:mail) { described_class.question_reminder(user, question, 3) }

    it '宛先と件名を設定する' do
      expect(mail.to).to eq(['member@example.com'])
      expect(mail.subject).to include('回答お願いします')
    end

    it '回答済みの方はご無視くださいを本文に含める' do
      expect(mail.body.encoded).to include('回答済みの方はご無視ください')
      expect(mail.body.encoded).to include('3日')
    end
  end
end