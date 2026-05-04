# frozen_string_literal: true

class CompanyPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    user_is_member?
  end

  def create?
    user.present?
  end

  def update?
    user_is_owner? || user_is_manager?
  end

  def destroy?
    user_is_owner?
  end

  def invite_members?
    user_is_owner? || user_is_manager?
  end

  def manage_members?
    user_is_owner? || user_is_manager?
  end

  private

  def user_is_owner?
    record.owner_id == user.id
  end

  def user_is_manager?
    member = record.company_members.find_by(user_id: user.id)
    member&.manager?
  end

  def user_is_member?
    record.users.include?(user)
  end
end
