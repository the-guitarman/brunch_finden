class PathToCache < ActiveRecord::Base
  set_table_name :path_to_cache
  
  validates_presence_of :path
  validates_uniqueness_of :path
  
  def self.find_or_create(path)
    if ptc = find(:first, {:conditions => {:path => path}})
      ptc.update_attributes({
        :expired_count => ptc.expired_count + 1,
        :expired_last => DateTime.now
      })
    else
      ptc = create({:expired_last => DateTime.now, :path => path})
    end
    return ptc
  end
end