class DataSource < ActiveRecord::Base
  DEFAULT = 'brunch-finden.de'
  
  validates_presence_of :name

  # Returns standard DataSource.
  def self.standard
    #unless ds = DataSource.where(:name => DEFAULT).first
    #  ds = DataSource.create({:name => DEFAULT})
    #end
    unless ds = DataSource.find(:first, {:conditions => {:name => DEFAULT}})
      ds = DataSource.create({:name => DEFAULT})
    end
    return ds
  end
end