class SearchSuggestionHandler
  def run
    generate
  end
  
  private
  
  def generate
    SearchSuggestion.update_all({:state => :active})
    bs = GLOBAL_CONFIG[:find_each_batch_size]
    deltas_enabled = ThinkingSphinx.deltas_enabled?
    ThinkingSphinx.deltas_enabled = false
    Location.showable.find_each({:batch_size => bs}) do |l|
      create_search_suggestion(l.name, 1)
    end
    City.showable.find_each({:batch_size => bs}) do |c|
      create_search_suggestion(c.name, 2)
    end
    Coupon.showable.find_each({:batch_size => bs}) do |c|
      create_search_suggestion(c.name, 3)
    end
    CouponCategory.showable.find_each({:batch_size => bs}) do |cc|
      create_search_suggestion(cc.name, 4)
    end
    SearchSuggestion.delete_all({:state => :active})
    ThinkingSphinx.deltas_enabled = deltas_enabled
    SearchSuggestion.reindex
  end
  
  def create_search_suggestion(phrase, weight)
    SearchSuggestion.create({:phrase => phrase, :weight => weight, :state => :new})
  end
end