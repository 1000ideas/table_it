class Progresstime < ActiveRecord::Base
  belongs_to :issue

  scope :started, lambda { where(closed: [false, nil]) }

  def timediff
    if end_time
      ((end_time - start_time) / 3600.0).round(2)
    end
  end

  def close!
    update_attributes(end_time: DateTime.now, closed: true)
    timediff
  end
end
