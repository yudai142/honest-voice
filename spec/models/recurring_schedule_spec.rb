# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecurringSchedule, type: :model do
  describe 'バリデーション' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:company_id) }
  end

  describe 'アソシエーション' do
    it { should belong_to(:company) }
    it { should belong_to(:question).optional }
    it { should belong_to(:question_template).optional }
  end

  describe 'enum' do
    it { should define_enum_for(:frequency).with_values(monthly: 0, quarterly: 1, yearly: 2) }
    it { should define_enum_for(:status).with_values(active: 0, paused: 1, completed: 2) }
  end

  describe 'スコープ' do
    let(:company) { create(:company) }

    describe '.active_schedules' do
      it 'activeなスケジュールのみ返す' do
        active = create(:recurring_schedule, company: company, status: :active)
        paused = create(:recurring_schedule, company: company, status: :paused)
        expect(RecurringSchedule.active_schedules).to include(active)
        expect(RecurringSchedule.active_schedules).not_to include(paused)
      end
    end

    describe '.due_today' do
      it '次回実行日が現在以前のスケジュールを返す' do
        due = create(:recurring_schedule, company: company, next_scheduled_at: 1.hour.ago)
        not_due = create(:recurring_schedule, company: company, next_scheduled_at: 1.day.from_now)
        expect(RecurringSchedule.due_today).to include(due)
        expect(RecurringSchedule.due_today).not_to include(not_due)
      end
    end
  end

  describe '#due?' do
    let(:company) { create(:company) }

    it '次回実行日が過去の場合 true を返す' do
      schedule = create(:recurring_schedule, company: company, next_scheduled_at: 1.hour.ago)
      expect(schedule.due?).to be true
    end

    it '次回実行日が未来の場合 false を返す' do
      schedule = create(:recurring_schedule, company: company, next_scheduled_at: 1.day.from_now)
      expect(schedule.due?).to be false
    end
  end

  describe '#mark_as_run' do
    let(:company) { create(:company) }

    it 'last_run_at が更新される' do
      schedule = create(:recurring_schedule, company: company, next_scheduled_at: 1.hour.ago)
      # freeze_time を RSpec の形式（Timecop または ActiveSupport のヘルパー）に合わせる
      # Rails 7+ の RSpec では travel_to が使える
      travel_to Time.current do
        schedule.mark_as_run
        expect(schedule.reload.last_run_at).to be_within(1.second).of(Time.current)
      end
    end

    it 'monthly: next_scheduled_at が1ヶ月後になる' do
      now = Time.current
      schedule = create(:recurring_schedule, company: company, frequency: :monthly, next_scheduled_at: now)
      schedule.mark_as_run
      expect(schedule.reload.next_scheduled_at).to be_within(1.minute).of(now.next_month)
    end

    it 'quarterly: next_scheduled_at が3ヶ月後になる' do
      now = Time.current
      schedule = create(:recurring_schedule, company: company, frequency: :quarterly, next_scheduled_at: now)
      schedule.mark_as_run
      expect(schedule.reload.next_scheduled_at).to be_within(1.minute).of(now + 3.months)
    end

    it 'yearly: next_scheduled_at が1年後になる' do
      now = Time.current
      schedule = create(:recurring_schedule, company: company, frequency: :yearly, next_scheduled_at: now)
      schedule.mark_as_run
      expect(schedule.reload.next_scheduled_at).to be_within(1.minute).of(now.next_year)
    end
  end

  describe 'target_scope' do
    let(:company) { create(:company) }

    it 'デフォルト値は all' do
      schedule = build(:recurring_schedule, company: company, target_scope: nil)
      # DBのデフォルト値
      created = create(:recurring_schedule, company: company)
      expect(created.target_scope).to eq('all')
    end

    it 'target_scope に department を設定できる' do
      schedule = create(:recurring_schedule, company: company, target_scope: 'department')
      expect(schedule.target_scope).to eq('department')
    end
  end
end
