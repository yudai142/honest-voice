require 'rails_helper'

RSpec.describe ReminderJob, type: :job do
  let(:company) { create(:company) }
  let(:question) { create(:question, :published, company: company, deadline: 3.days.from_now) }
  let(:target_user) { create(:user, notification_enabled: true) }
  let(:answered_user) { create(:user, notification_enabled: true) }
  let(:muted_user) { create(:user, notification_enabled: false) }

  before do
    create(:company_member, company: company, user: target_user, role: :member)
    create(:company_member, company: company, user: answered_user, role: :member)
    create(:company_member, company: company, user: muted_user, role: :member)
    create(:answer, question: question, company: company, user: answered_user, body: '回答済み')
  end

  it '未回答かつ通知有効ユーザーのみにリマインドを送る' do
    delivery = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
    allow(ReminderMailer).to receive(:question_reminder).and_return(delivery)

    described_class.perform_now(question.id, 3)

    expect(ReminderMailer).to have_received(:question_reminder).with(target_user, question, 3)
    expect(ReminderMailer).not_to have_received(:question_reminder).with(answered_user, question, 3)
    expect(ReminderMailer).not_to have_received(:question_reminder).with(muted_user, question, 3)
  end
end