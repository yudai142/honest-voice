class InviteTokensController < ApplicationController
  before_action :set_invite_token

  def join
    unless user_signed_in?
      session[:pending_invite_token] = @invite_token.token
      redirect_to new_user_session_path, alert: 'ログイン後に招待参加を継続します。'
      return
    end

    unless @invite_token.valid_for_use?
      redirect_to root_path, alert: 'この招待URLは無効または期限切れです。'
      return
    end

    if @invite_token.company.company_members.exists?(user_id: current_user.id)
      redirect_to '/member/dashboard', notice: 'すでに参加済みです。'
      return
    end

    @invite_token.company.add_member(current_user, :member)
    @invite_token.mark_as_used(current_user)

    redirect_to '/member/dashboard', notice: '会社に参加しました。'
  end

  private

  def set_invite_token
    @invite_token = InviteToken.find_by!(token: params[:token])
  end
end