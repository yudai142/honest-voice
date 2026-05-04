# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def create?
    user.present?
  end

  def new?
    create?
  end

  def update?
    user.present? && owner?
  end

  def edit?
    update?
  end

  def destroy?
    user.present? && owner?
  end

  def owner?
    record.user_id == user.id
  end
end
