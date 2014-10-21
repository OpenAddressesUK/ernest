require 'active_support/concern'

module Provenanceable
  extend ActiveSupport::Concern

  included do
    before_save :create_activity
    belongs_to :activity
  end

  private

    def create_activity
      self.activity = Activity.create(executed_at: DateTime.now)
    end

end
