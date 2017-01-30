module JournalDetailExtension
  extend ActiveSupport::Concern

  included do
    validate :double_attachment
  end

  def double_attachment
    return if property != 'attachment'

    if JournalDetail.where(property: property, journal_id: journal_id, value: value).any?
      errors.add(:base, message: 'already exists')
    end
  end
end

JournalDetail.send(:include, JournalDetailExtension)
