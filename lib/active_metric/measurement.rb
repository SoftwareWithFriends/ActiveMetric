module ActiveMetric

  class Measurement
    include Mongoid::Document
    index [[:subject_ids, 1]]

    belongs_to :reporter, :polymorphic => true
    has_and_belongs_to_many :subjects, :class_name => "ActiveMetric::Subject"

    field :timestamp, :type => Integer

    scope :eightieth,         lambda {|subject, key| by_subject_sorted(subject, key).limit(1).skip(by_subject(subject).count * 0.8)}
    scope :ninety_eighth,     lambda {|subject, key| by_subject_sorted(subject, key).limit(1).skip(by_subject(subject).count * 0.98)}
    scope :by_subject_sorted, lambda {|subject, key| by_subject(subject).asc(key)}
    scope :by_subject,        lambda {|subject| self.where(:subject_ids => subject.id)}

    def time
      Time.at((timestamp.to_i / 1000).to_i).to_datetime
    end
  end
end
