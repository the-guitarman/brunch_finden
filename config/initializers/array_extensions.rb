class Array
  # returns all ids of arrays elements
  def element_ids
    self.collect do |e| e.id if e.id end
  end

  def map_to_hash
		map { |e| yield e }.inject({}) { |carry, e| carry.merge! e }
	end
end