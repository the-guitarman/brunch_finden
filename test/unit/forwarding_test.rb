#encoding: utf-8
require 'test_helper'

class ForwardingTest < ActiveSupport::TestCase
  # process before each test method
  def setup
    
  end

  # process before each test method
  def teardown

  end

  def test_01_create
    Forwarding.delete_all

    # Url forwarding needs a source url and a destination url.
    uf_test_1 = Forwarding.create
    assert !uf_test_1.valid?
    assert uf_test_1.errors.invalid?(:source_url)
    assert uf_test_1.errors.invalid?(:destination_url)

    attributes = valid_attributes({:source_url => nil})
    uf_test_2 = Forwarding.create(attributes)
    assert !uf_test_2.valid?
    assert uf_test_2.errors.invalid?(:source_url)
    assert !uf_test_2.errors.invalid?(:destination_url)

    attributes = valid_attributes({:destination_url => nil})
    uf_test_3 = Forwarding.create(attributes)
    assert !uf_test_3.valid?
    assert !uf_test_3.errors.invalid?(:source_url)
    assert uf_test_3.errors.invalid?(:destination_url)

    # Source url has to be different to the destination url.
    attributes = valid_attributes
    attributes[:destination_url] = attributes[:source_url]
    uf_test_4 = Forwarding.create(attributes)
    assert !uf_test_4.valid?
    assert uf_test_4.errors.invalid?(:source_url)
    assert uf_test_4.errors.invalid?(:destination_url)

    # All  things are ok.
    attributes = valid_attributes
    uf_test_5 = Forwarding.create(attributes)
    assert uf_test_5.valid?
    assert !uf_test_5.errors.invalid?(:source_url)
    assert !uf_test_5.errors.invalid?(:destination_url)

    assert_equal false, uf_test_5.last_use_at.blank?
    assert_equal ActiveSupport::TimeWithZone, uf_test_5.last_use_at.class

    # Check for dublicate source url.
    uf_test_6 = Forwarding.create(attributes)
    assert !uf_test_6.valid?
    assert uf_test_6.errors.invalid?(:source_url)
    assert !uf_test_6.errors.invalid?(:destination_url)

    # More than one source url forwards to one destination url.
    attributes[:source_url] += 's'
    uf_test_7 = Forwarding.create(attributes)
    assert uf_test_7.valid?
    assert !uf_test_7.errors.invalid?(:source_url)
    assert !uf_test_7.errors.invalid?(:destination_url)

    assert_equal false, uf_test_7.last_use_at.blank?
    assert_equal ActiveSupport::TimeWithZone, uf_test_5.last_use_at.class
  end

  def test_02_update
    Forwarding.delete_all

    attributes = valid_attributes
    uf1 = Forwarding.create(attributes)
    assert uf1.valid?
    attributes[:source_url] += 's'
    uf2 = Forwarding.create(attributes)
    assert uf2.valid?

    # Url forwarding needs a source url and a destination url.
    temp = uf1.source_url
    uf1.source_url = nil
    assert !uf1.save
    assert uf1.errors.invalid?(:source_url)
    assert !uf1.errors.invalid?(:destination_url)
    uf1.source_url = temp
    assert uf1.save
    
    temp = uf1.destination_url
    uf1.destination_url = nil
    assert !uf1.save
    assert !uf1.errors.invalid?(:source_url)
    assert uf1.errors.invalid?(:destination_url)
    uf1.destination_url = temp
    assert uf1.save

    # Source url has to be different to the destination url.
    temp = uf1.destination_url
    uf1.destination_url = uf1.source_url
    assert !uf1.save
    assert uf1.errors.invalid?(:source_url)
    assert uf1.errors.invalid?(:destination_url)
    uf1.destination_url = temp
    assert uf1.save

    # Check for dublicate source url.
    temp = uf2.source_url
    uf2.source_url = uf1.source_url
    assert !uf2.save
    assert uf2.errors.invalid?(:source_url)
    assert !uf2.errors.invalid?(:destination_url)
    uf2.source_url = temp
    assert uf2.save
  end

  def test_03_destroy
    Forwarding.delete_all

    uf = Forwarding.create(valid_attributes)

    uf.destroy
    assert uf.frozen?
  end

  def test_04_find_by_source_url_and_update_last_use_at
    Forwarding.delete_all

    attributes = valid_attributes
    uf1 = Forwarding.create(attributes)
    assert uf1.valid?
    attributes[:source_url] += 's'
    uf2 = Forwarding.create(attributes)
    assert uf2.valid?

    sleep(2)

    # Find by other than source url, then nothing happens to last_use_at.
    uf_found1 = Forwarding.find(uf1.id)
    assert_equal uf1.last_use_at.to_s, uf_found1.last_use_at.to_s

    uf_found2 = Forwarding.first
    assert_equal uf1.last_use_at.to_s, uf_found2.last_use_at.to_s
    
    uf_found3 = Forwarding.last
    assert_equal uf2.last_use_at.to_s, uf_found3.last_use_at.to_s

    uf_found4 = Forwarding.find(:first, :conditions => {
      :destination_url => '/categories/computers-software'
    })
    assert_equal uf1.last_use_at.to_s, uf_found4.last_use_at.to_s

    ufs_found1 = Forwarding.find(:all, :conditions => {
      :destination_url => '/categories/computers-software'
    })
    assert_equal uf1.last_use_at.to_s, ufs_found1.first.last_use_at.to_s
    assert_equal uf2.last_use_at.to_s, ufs_found1.last.last_use_at.to_s

    uf_found5 = Forwarding.find_by_destination_url('/categories/computers-software')
    assert_equal uf1.last_use_at.to_s, uf_found5.last_use_at.to_s

    

    # Find by source url, then last_use_at will be updated to Time.now.
    temp = Time.now
    sleep(1)
    uf_found6 = Forwarding.find(:first, :conditions => {
      :source_url => '/categories/computer'
    })
    assert temp < uf_found6.last_use_at

    temp = Time.now
    sleep(1)
    ufs_found2 = Forwarding.find(:all, :conditions => {
      :source_url => '/categories/computers'
    })
    assert temp < ufs_found2.first.last_use_at

    temp = Time.now
    sleep(1)
    uf_found7 = Forwarding.find_by_source_url('/categories/computer')
    assert temp < uf_found7.last_use_at
  end

  def test_05_find_by_source_url_and_do_not_update_last_use_at
    Forwarding.delete_all

    attributes = valid_attributes
    uf1 = Forwarding.create(attributes)
    assert uf1.valid?
    attributes[:source_url] += 's'
    uf2 = Forwarding.create(attributes)
    assert uf2.valid?

    sleep(2)

    Forwarding.update_last_use_at_on_find_enabled = false
    
    # Find by source url, but do not update last_use_at.
    uf_found1 = Forwarding.find(:first, :conditions => {
      :source_url => '/categories/computer'
    })
    assert_equal uf1.last_use_at.to_s, uf_found1.last_use_at.to_s

    ufs_found2 = Forwarding.find(:all, :conditions => {
      :source_url => '/categories/computers'
    })
    assert_equal uf2.last_use_at.to_s, ufs_found2.first.last_use_at.to_s

    uf_found3 = Forwarding.find_by_source_url('/categories/computer')
    assert_equal uf1.last_use_at.to_s, uf_found3.last_use_at.to_s

    Forwarding.update_last_use_at_on_find_enabled = true
  end

  def test_06_update_destination_urls_if_they_will_be_forwarded_too
    # Update source_url to destination_url example:
    # Computer forwards to Hardware: - Computer => Hardware
    # Hardware will be deleted und forwarded to Electronics: - Hardware => Electronics
    # Former forwardings to Hardware have to be updated to Electronics too.
    # - so update: Comuter => Electronics
    Forwarding.delete_all

    attributes = valid_attributes({
      :source_url => '/categories/computer',
      :destination_url => '/categories/hardware'
    })
    # - Computer => Hardware
    uf1 = Forwarding.create(attributes)
    assert uf1.valid?

    attributes = valid_attributes({
      :source_url => '/categories/hardware',
      :destination_url => '/categories/electronics'
    })
    # - Hardware => Electronics
    uf2 = Forwarding.create(attributes)
    assert uf2.valid?

    uf1.reload
    # - so Comuter now forwards to Electronics
    assert_equal uf2.destination_url, uf1.destination_url
  end

  def test_07_self_cleaner
    Forwarding.delete_all
    assert_equal 0, Forwarding.count

    attributes = valid_attributes
    uf1 = Forwarding.create(attributes)
    assert uf1.valid?
    attributes[:source_url] += 's'
    uf2 = Forwarding.create(attributes)
    assert uf2.valid?
    assert_equal 2, Forwarding.count

    Forwarding.cleaner({:show_messages => false})
    assert_equal 2, Forwarding.count

    uf1.update_attributes({:last_use_at => ((Time.now - 1.year) - 1.day)})
    Forwarding.cleaner({:show_messages => false})
    assert_equal 1, Forwarding.count
    
    uf1.update_attributes({:last_use_at => Time.now.yesterday})
    Forwarding.cleaner({:show_messages => false})
    assert_equal 1, Forwarding.count

    Forwarding.cleaner({:show_messages => false, :last_use_before => Time.now})
    assert_equal 0, Forwarding.count
  end

  private

  def valid_attributes(add_attributes={})
    {
      :source_url => '/categories/computer',
      :destination_url => '/categories/computers-software'
    }.merge(add_attributes)
  end
end
