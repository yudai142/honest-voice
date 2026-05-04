require 'rails_helper'

RSpec.describe RecurringJob, type: :job do
  let(:question) { create(:question, :published) }
  let!(:due_schedule) { create(:recurring_schedule, question: question, next_scheduled_at: 1.hour.ago, status: :active) }
  let!(:future_schedule) { create(:recurring_schedule, next_scheduled_at: 1.day.from_now, status: :active) }

  it '期限到来済みのスケジュールだけを処理する' do
    allow(AnalysisJob).to receive(:perform_later)

    described_class.perform_now

    expect(AnalysisJob).to have_received(:perform_later).with(question.id).at_most(:once)
    expect(future_schedule.reload.last_run_at).to be_nil
  end
end