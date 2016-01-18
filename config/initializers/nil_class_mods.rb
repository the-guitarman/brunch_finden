if Rails.version < '3.0.0'
  class NilClass
    def any?
      false
    end
  end
end