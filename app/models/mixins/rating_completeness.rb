module Mixins::RatingCompleteness
  def self.included(klass)
    klass.instance_eval do
      include InstanceMethods
    end
  end

  module InstanceMethods
    def completeness_note
      ret = nil
      if rq = self.review_question and self.obligated?
        if self.value.blank? and ['list', 'boolean'].include?(rq.answer_type)
          ret = ActiveModel::Errors.new(self).generate_message(:value, :blank)
        elsif self.text.blank? and rq.answer_type == 'text'
          ret = ActiveModel::Errors.new(self).generate_message(:text, :blank)
        end
      end
      return ret
    end
  end
end
