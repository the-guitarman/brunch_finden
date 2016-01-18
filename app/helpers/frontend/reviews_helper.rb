module Frontend::ReviewsHelper
  def review_destination_name(review_or_destination)
    if review_or_destination.is_a?(Review) or review_or_destination.is_a?(AggregatedReview)
      ret = review_or_destination.destination.name
    else
      ret = review_or_destination.name
    end
    return ret
  end

  def get_review_question_answer_text(rating_or_aggregated_rating, review_question)
    answer_text = 'Keine Bewertung vorhanden'
    if rating_or_aggregated_rating 
      unless rating_or_aggregated_rating.value?
        answer_text = I18n.t('shared.please_select')
      else
        #review_answer = review_question.review_answers.
        #  where(['score >= ?', rating_or_aggregated_rating.value.to_f]).
        #  order(:score).limit(1).first
        review_answer = review_question.review_answers.find(:first, {
          :conditions => ['score >= ?', rating_or_aggregated_rating.value.to_f],
          :order => 'score ASC'
        })
        if review_answer
          answer_text = review_answer.text
        end
      end
    end
    return answer_text
  end
end