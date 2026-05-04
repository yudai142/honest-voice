# frozen_string_literal: true

class InviteTokenPolicy < ApplicationPolicy
  def index?
    user_is_manager?
  end

  def show?
    user_is_manager?
  end

  def create?
    user_is_manager?
  end

  def revoke?
    user_is_manager?
  end

  def use_token?
    true # 誰でもトークンを使用して参加可能
  end

  private

  def user_is_manager?
    member = record.company.company_members.find_by(user_id: user.id)
    member&.manager?
  end
end
