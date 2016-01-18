module Mixins::ActsAsRaterScorer
  def self.included(klass)
    klass.instance_eval do      
      include InstanceMethods
      extend ClassMethods
    end
  end

  module ClassMethods
    def acts_as_rater_scorer(call_for_rater = nil, options = {})
      unless (call_for_rater or Review.reflect_on_association(call_for_rater.to_sym))
        raise "acts_as_rater_scorer expects the frontend_user association or method."
      else
        cattr_accessor :call_for_rater
        self.call_for_rater = call_for_rater
      end
      
      if not options.is_a?(Hash) or options.empty?
        raise "acts_as_rater_scorer expects same scorer options." 
      end
      
      unless Rails.env.test?
        options.keys.each do |key|
          unless (
              self.respond_to?(:instance_methods) and
              self.instance_methods.include?((Rails.version >= '3.0.0' ? key.to_sym : key.to_s))) or (
              self.respond_to?(:column_names) and 
              self.column_names.include?(key.to_s))
            raise "acts_as_rater_scorer option #{key} have to be valid attributes or methods of #{self.name}"
          end
        end
      end
      
      ad_option = options.delete(:after_destroy)
      if ad_option.blank? or ad_option == true
        after_destroy  :_after_destroy_acts_as_rater_scorer_handler

        after_destroy_eval_code = '
          private 

          def _after_destroy_acts_as_rater_scorer_handler
        '
        options.each do |key, array|
          value = array.first
          score = array.last
          raise "The score for #{key} has to be an integer value." unless score.is_a?(Integer)
          
          inc_call = "inc_rater_score!(#{score})"
          dec_call = "dec_rater_score!(#{score})"
          after_destroy_eval_code += "
            if #{value.inspect} == :inc
              #dec_rater_score!(self.#{key}.to_i * #{score})
            
            elsif #{value.inspect} == :dec
              #inc_rater_score!(self.#{key}.to_i * #{score})
            
            elsif self.#{key} == #{value.inspect}
              dec_rater_score!(#{score})
            
            end
          "
        end
        after_destroy_eval_code += '
          end
        '
        class_eval after_destroy_eval_code
      end
      
      as_option = options.delete(:after_save)
      if as_option.blank? or as_option == true
        after_save  :_after_safe_acts_as_rater_scorer_handler

        after_save_eval_code = '
          private 

          def _after_safe_acts_as_rater_scorer_handler
        '
        options.each do |key, array|
          value = array.first
          score = array.last
          raise "The score for #{key} has to be an integer value." unless score.is_a?(Integer)
          
          inc_call = "inc_rater_score!(#{score})"
          dec_call = "dec_rater_score!(#{score})"
          after_save_eval_code += "
            changes = self.changes
            if changes.include?('#{key}')
              if #{value.inspect} == :inc
                if changes['#{key}'][0] != changes['#{key}'][1]
                  #{inc_call}
                end

              elsif #{value.inspect} == :dec
                if changes['#{key}'][0] != changes['#{key}'][1]
                  #{dec_call}
                end

              elsif changes['#{key}'][0] != changes['#{key}'][1] and changes['#{key}'][1] == #{value.inspect}
                #{inc_call}
              end
            end
          "
        end
        after_save_eval_code += '
          end
        '
        class_eval after_save_eval_code
      end
    end
  end

  module InstanceMethods
    def _call_for_rater
      self.send(self.class.call_for_rater.to_sym)
    end
    
    # add points for action to frontend user score
    def inc_rater_score(add)
      if add || false
        fu = self._call_for_rater
        fu.score += add 
      end
      #puts "add: #{add}"
      add
    end

    def inc_rater_score!(add)
      if add = inc_rater_score(add)
        fu = self._call_for_rater
        fu.save
      end
      add
    end

    # remove points for action from frontend user score
    def dec_rater_score(remove)
      if remove || false
        fu = self._call_for_rater
        fu.score -= remove 
        fu.score = 0 if fu.score < 0
      end
      #puts "remove: #{remove}"
      remove
    end

    def dec_rater_score!(remove)
      if remove = dec_rater_score(remove)
        fu = self._call_for_rater
        fu.save
      end
      remove
    end
  end
end
