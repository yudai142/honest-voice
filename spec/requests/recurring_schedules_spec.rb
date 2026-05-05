# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::RecurringSchedules', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin_user) { create(:user, :admin) }
  let(:member_user) { create(:user, :member) }
  let(:company) { create(:company, owner_id: admin_user.id) }
  let(:question_template) { create(:question_template, company: company) }
  let(:recurring_schedule) do
    create(:recurring_schedule,
           company: company,
           question_template: question_template,
           target_scope: 'all')
  end

  describe 'アクセス制御' do
    context '未認証ユーザー' do
      it 'index: ログインページにリダイレクトされる' do
        get '/admin/recurring_schedules'
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'memberユーザー' do
      before { sign_in member_user }

      it 'index: 403 Forbidden を返す' do
        get '/admin/recurring_schedules'
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET /admin/recurring_schedules' do
    before do
      sign_in admin_user
      company
      recurring_schedule
    end

    it '200 OK を返す' do
      get '/admin/recurring_schedules'
      expect(response).to have_http_status(:ok)
    end

    it '自社のスケジュール一覧を返す' do
      get '/admin/recurring_schedules', as: :json
      json = response.parsed_body
      expect(json['schedules']).to be_an(Array)
      expect(json['schedules'].length).to eq(1)
    end

    it '他社のスケジュールは含まれない' do
      other_admin = create(:user, :admin)
      other_company = create(:company, owner_id: other_admin.id)
      create(:recurring_schedule, company: other_company)

      get '/admin/recurring_schedules', as: :json
      json = response.parsed_body
      expect(json['schedules'].length).to eq(1)
    end
  end

  describe 'POST /admin/recurring_schedules' do
    before do
      sign_in admin_user
      company
      question_template
    end

    let(:valid_params) do
      {
        recurring_schedule: {
          name: '月次フィードバック調査',
          frequency: 'monthly',
          target_scope: 'all',
          question_template_id: question_template.id,
          next_scheduled_at: 1.month.from_now.iso8601
        }
      }
    end

    it 'スケジュールが作成される' do
      expect {
        post '/admin/recurring_schedules', params: valid_params, as: :json
      }.to change(RecurringSchedule, :count).by(1)
    end

    it '201 Created を返す' do
      post '/admin/recurring_schedules', params: valid_params, as: :json
      expect(response).to have_http_status(:created)
    end

    it '作成したスケジュールのデータを返す' do
      post '/admin/recurring_schedules', params: valid_params, as: :json
      json = response.parsed_body
      expect(json['schedule']['name']).to eq('月次フィードバック調査')
      expect(json['schedule']['target_scope']).to eq('all')
    end

    context '不正なパラメータ' do
      it 'nameが空の場合 422 を返す' do
        post '/admin/recurring_schedules',
             params: { recurring_schedule: { name: '', frequency: 'monthly' } },
             as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH /admin/recurring_schedules/:id' do
    before do
      sign_in admin_user
      company
      recurring_schedule
    end

    it 'スケジュールを更新できる' do
      patch "/admin/recurring_schedules/#{recurring_schedule.id}",
            params: { recurring_schedule: { name: '更新後の名前' } },
            as: :json
      expect(response).to have_http_status(:ok)
      expect(recurring_schedule.reload.name).to eq('更新後の名前')
    end

    it '他社のスケジュールは更新できない' do
      other_admin = create(:user, :admin)
      other_company = create(:company, owner_id: other_admin.id)
      other_schedule = create(:recurring_schedule, company: other_company)

      patch "/admin/recurring_schedules/#{other_schedule.id}",
            params: { recurring_schedule: { name: '不正更新' } },
            as: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /admin/recurring_schedules/:id/pause' do
    before do
      sign_in admin_user
      company
      recurring_schedule
    end

    it 'スケジュールを停止できる' do
      patch "/admin/recurring_schedules/#{recurring_schedule.id}/pause", as: :json
      expect(response).to have_http_status(:ok)
      expect(recurring_schedule.reload.status).to eq('paused')
    end
  end

  describe 'PATCH /admin/recurring_schedules/:id/resume' do
    before do
      sign_in admin_user
      company
      create(:recurring_schedule,
             company: company,
             status: :paused,
             question_template: question_template,
             target_scope: 'all')
    end

    it '停止中スケジュールを再開できる' do
      paused = RecurringSchedule.last
      patch "/admin/recurring_schedules/#{paused.id}/resume", as: :json
      expect(response).to have_http_status(:ok)
      expect(paused.reload.status).to eq('active')
    end
  end

  describe 'DELETE /admin/recurring_schedules/:id' do
    before do
      sign_in admin_user
      company
      recurring_schedule
    end

    it 'スケジュールが削除される' do
      expect {
        delete "/admin/recurring_schedules/#{recurring_schedule.id}", as: :json
      }.to change(RecurringSchedule, :count).by(-1)
    end

    it '204 No Content を返す' do
      delete "/admin/recurring_schedules/#{recurring_schedule.id}", as: :json
      expect(response).to have_http_status(:no_content)
    end

    it '他社のスケジュールは削除できない' do
      other_admin = create(:user, :admin)
      other_company = create(:company, owner_id: other_admin.id)
      other_schedule = create(:recurring_schedule, company: other_company)

      expect {
        delete "/admin/recurring_schedules/#{other_schedule.id}", as: :json
      }.not_to change(RecurringSchedule, :count)
      expect(response).to have_http_status(:not_found)
    end
  end
end
