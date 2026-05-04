# frozen_string_literal: true

class CompanyMemberPolicy < ApplicationPolicy
  def index?
    user_is_manager?
  end

  def show?
    user_is_manager?
  end

  def create?
    user_is_manager?
  end

  def update?
    user_is_owner?
  end

  def destroy?
    user_is_owner? && !record.owner?
  end

  private

  def user_is_owner?
    record.company.owner_id == user.id
  end

  def user_is_manager?
    member = record.company.company_members.find_by(user_id: user.id)
    member&.manager?
  end
end
