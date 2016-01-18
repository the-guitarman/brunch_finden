class Thread
  # This attribute improves readibility for man
  attr_writer :name
  def name; @name||"unknown Thread";end
  # this method used to limit the overall thread count.
  # its an soft check only, you can use it before creating a new thread
  def self.limit(limit=10)
    while Thread.list.size>=limit do
      Thread.pass;sleep 10
    end
  end
end

class ThreadPool
  class Worker

    attr_accessor :thread
    attr_accessor :name

    def initialize
      @mutex = Mutex.new
      @thread = Thread.new do
        while true
          sleep 0.001
          block = get_block
          if block
            block.call
            reset_worker
          end
        end
      end
    end


    def get_block
      @mutex.synchronize {@block}
    end

    def set_block(block)
      @mutex.synchronize do
        raise RuntimeError, "Thread already busy." if @block
        @block = block
      end
    end

    def process(&block)
      set_block(block)
    end

    def reset_block
      @mutex.synchronize {@block = nil}
    end

    def reset_worker
      reset_block
      self.name="FREE WORKER"
    end

    def busy?
      @mutex.synchronize {!@block.nil?}
    end
  end

  attr_accessor :max_size
  attr_reader :workers

  def initialize(max_size = 20)
    @max_size = max_size
    @workers = []
    @mutex = Mutex.new
  end

  def size #obsolete
    @mutex.synchronize {@workers.size}
  end

  def busy?
    @mutex.synchronize {@workers.any? {|w| w.busy?}}
  end

  def join #obsolete
    sleep 0.01 while busy?
  end

  def process(&block)
    wait_for_worker.set_block(block)
  end

  def wait_for_worker
    while true
      worker = find_available_worker
      (return worker) if worker
      sleep 1
    end
  end

  def find_available_worker
    @mutex.synchronize {free_worker || create_worker}
  end

  def free_worker
    @workers.each {|w| return w unless w.busy?}; nil
  end

  def reduce_free_workers
    @mutex.synchronize do
      if worker = @workers.find{|w| w.busy? == false}
        @workers.delete(worker.exit!)
      end
    end
  end

  def create_worker
    return nil if @workers.size >= @max_size
    worker = Worker.new
    @workers << worker
    worker
  end
end


