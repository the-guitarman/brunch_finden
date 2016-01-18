class SearchQueryLogReporter
  include SearchQuery::Reporter
  
  def run
    report
  end
end