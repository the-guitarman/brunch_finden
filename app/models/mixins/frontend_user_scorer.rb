module Mixins::FrontendUserScorer
  LEVELS = [
    '0:1500:first_time_user', '1:3200:newbe', '2:6500:ambitious',
    '3:15000:advanced', '4:40000:well_versed', '5:200000:professional',
    '6:260000:specialist', '7:320000:expert', '8:320000:power_user'
  ]

  def self.included(klass)
    klass.instance_eval do      
      include InstanceMethods
      #extend ClassMethods
    end
  end

  #module ClassMethods
  #end

  module InstanceMethods
    def level
      fu = self.frontend_user_scorer_calls_for_frontend_user
      fu.score = 0 unless fu.score; ret = {}
      LEVELS.each do |level|
        level_arr = level.split(':')
        ret = {:level => level_arr[0], :label => level_arr[2]}
        return  ret if fu.score < level_arr[1].to_i
      end
      ret
    end
  end
end
