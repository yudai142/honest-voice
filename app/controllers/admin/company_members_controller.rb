class Admin::CompanyMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_company_member, only: [:update, :destroy]

  def index
    unless owner_or_manager?
      render json: { error: 'この操作は許可されていません。' }, status: :forbidden
      return
    end

    members = @company.company_members.includes(:user).order(created_at: :asc)

    render json: {
      members: members.map { |member| serialize_member(member) }
    }, status: :ok
  end

  def update
    unless owner?
      render json: { error: 'ownerのみロールを更新できます。' }, status: :forbidden
      return
    end

    if @company_member.update(company_member_params)
      render json: { member: serialize_member(@company_member) }, status: :ok
    else
      render json: { errors: @company_member.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    unless owner?
      render json: { error: 'ownerのみメンバーを除外できます。' }, status: :forbidden
      return
    end

    if @company_member.owner?
      render json: { error: 'ownerは除外できません。' }, status: :unprocessable_entity
      return
    end

    @company_member.destroy!
    render json: { message: 'メンバーを除外しました。' }, status: :ok
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_company_member
    @company_member = @company.company_members.find(params[:id])
  end

  def company_member_params
    params.require(:company_member).permit(:role)
  end

  def owner?
    @company.owner_id == current_user.id
  end

  def owner_or_manager?
    return true if owner?

    company_member = @company.company_members.find_by(user_id: current_user.id)
    company_member&.manager?
  end

  def serialize_member(member)
    {
      id: member.id,
      role: member.role,
      user: {
        id: member.user.id,
        email: member.user.email,
        name: member.user.name
      }
    }
  end
end