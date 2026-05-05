# frozen_string_literal: true

module Admin
  class RecurringSchedulesController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_schedule, only: [:update, :pause, :resume, :destroy]

    # GET /admin/recurring_schedules
    def index
      schedules = current_company_schedules.order(created_at: :desc)

      respond_to do |format|
        format.html { render :index }
        format.json do
          render json: {
            schedules: schedules.map { |s| serialize_schedule(s) }
          }
        end
      end
    end

    # POST /admin/recurring_schedules
    def create
      schedule = current_company.recurring_schedules.new(schedule_params)

      if schedule.save
        render json: { schedule: serialize_schedule(schedule) }, status: :created
      else
        render json: { errors: schedule.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH /admin/recurring_schedules/:id
    def update
      if @schedule.update(schedule_params)
        render json: { schedule: serialize_schedule(@schedule) }
      else
        render json: { errors: @schedule.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH /admin/recurring_schedules/:id/pause
    def pause
      @schedule.paused!
      render json: { schedule: serialize_schedule(@schedule) }
    end

    # PATCH /admin/recurring_schedules/:id/resume
    def resume
      @schedule.active!
      render json: { schedule: serialize_schedule(@schedule) }
    end

    # DELETE /admin/recurring_schedules/:id
    def destroy
      @schedule.destroy
      head :no_content
    end

    private

    def current_company
      @current_company ||= current_user.owned_companies.first || current_user.companies.first
    end

    def current_company_schedules
      current_company ? RecurringSchedule.where(company: current_company) : RecurringSchedule.none
    end

    def set_schedule
      @schedule = current_company_schedules.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Schedule not found' }, status: :not_found
    end

    def schedule_params
      params.require(:recurring_schedule).permit(
        :name, :frequency, :status, :target_scope,
        :question_template_id, :next_scheduled_at, :day_of_month
      )
    end

    def serialize_schedule(schedule)
      {
        id: schedule.id,
        name: schedule.name,
        frequency: schedule.frequency,
        status: schedule.status,
        target_scope: schedule.target_scope,
        question_template_id: schedule.question_template_id,
        next_scheduled_at: schedule.next_scheduled_at,
        last_run_at: schedule.last_run_at,
        created_at: schedule.created_at
      }
    end

    def authorize_admin!
      render json: { error: 'Forbidden' }, status: :forbidden unless current_user.admin?
    end
  end
end
