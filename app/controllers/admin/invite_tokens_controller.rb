class Admin::InviteTokensController < ApplicationController
  before_action :authenticate_user!
  before_action :set_company
  before_action :set_invite_token, only: [:deactivate, :destroy]
  before_action :authorize_manage_tokens!

  def index
    invite_tokens = @company.invite_tokens.order(created_at: :desc)

    render json: {
      invite_tokens: invite_tokens.map { |token| serialize_token(token) }
    }, status: :ok
  end

  def create
    invite_token = @company.invite_tokens.new(invite_token_params)
    invite_token.creator = current_user

    if invite_token.save
      render json: { invite_token: serialize_token(invite_token) }, status: :created
    else
      render json: { errors: invite_token.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def deactivate
    if @invite_token.update(active: false, status: :used)
      render json: { invite_token: serialize_token(@invite_token) }, status: :ok
    else
      render json: { errors: @invite_token.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @invite_token.destroy!
    render json: { message: '招待トークンを削除しました。' }, status: :ok
  end

  private

  def set_company
    @company = Company.find(params[:company_id])
  end

  def set_invite_token
    @invite_token = @company.invite_tokens.find(params[:id])
  end

  def authorize_manage_tokens!
    return if current_user.admin?

    member = @company.company_members.find_by(user_id: current_user.id)
    return if member&.manager?

    render json: { error: 'この操作は許可されていません。' }, status: :forbidden
  end

  def invite_token_params
    params.fetch(:invite_token, {}).permit(:expires_at, :max_uses)
  end

  def serialize_token(token)
    {
      id: token.id,
      token: token.token,
      invite_url: join_invite_url(token: token.token),
      status: token.status,
      active: token.active,
      max_uses: token.max_uses,
      use_count: token.use_count,
      expires_at: token.expires_at,
      created_at: token.created_at
    }
  end
end