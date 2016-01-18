class Error < ActiveRecord::Base
  validates_presence_of :message, :backtrace
  
  def self.create_for(exception, status = nil, request = nil, parameters = {})
    create({
      :message => exception.message,
      :backtrace => exception.backtrace.join("\n"),
      :status => status,
      :fullpath => request ? request.fullpath : nil,
      :params => parameters.inspect
    })
  end
end