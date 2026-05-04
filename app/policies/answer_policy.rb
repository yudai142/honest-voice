# frozen_string_literal: true

class AnswerPolicy < ApplicationPolicy
  def index?
    user_is_manager?
  end

  def show?
    user_is_manager?
  end

  def create?
    true # 匿名で回答可能
  end

  def view_stats?
    user_is_manager?
  end

  def export?
    user_is_manager?
  end

  private

  def user_is_manager?
    return false unless user.present?

    company = record.question&.company
    return false unless company

    member = company.company_members.find_by(user_id: user.id)
    member&.manager?
  end
end
