# frozen_string_literal: true

class QuestionPolicy < ApplicationPolicy
  def index?
    user_is_company_member?
  end

  def show?
    user_is_company_member?
  end

  def create?
    user_is_manager?
  end

  def update?
    user_is_manager? && record.draft?
  end

  def destroy?
    user_is_manager? && record.draft?
  end

  def publish?
    user_is_manager? && record.draft?
  end

  def view_answers?
    user_is_manager?
  end

  private

  def user_is_company_member?
    record.company.users.include?(user)
  end

  def user_is_manager?
    member = record.company.company_members.find_by(user_id: user.id)
    member&.manager?
  end
end
