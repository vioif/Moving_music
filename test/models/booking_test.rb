require 'test_helper'

class BookingTest < ActiveSupport::TestCase

  def setup
    @musician = create(:user)
    @client = create(:user, :client)
  end

  test "a valid booking can be created" do
    booking = build(:booking, musician: @musician, client: @client)
    booking.save
    assert booking.persisted?, "a valid booking should be persisted"
  end

  test "booking address must be present" do
    booking = build(:booking, musician: @musician, client: @client, address: nil)
    booking.save
    refute booking.persisted?, "booking should not persist without address"
  end

  test "booking with a invalid address displays error" do
    booking = build(:booking, musician: @musician, client: @client, address: 'adsjhflakdjafjhadsg')
    booking.save
    refute booking.persisted?, "booking should not persist with an invalid address"
  end

  test "booking can be created when address is valid" do
    booking = build(:booking, musician: @musician, client: @client, address: '220 King Street West, Toronto')
    booking.save
    assert booking.persisted?, "booking should save with a valid address"
  end

  test "booking start_time must be in the future" do
    booking = build(:booking, musician: @musician, client: @client, start_time: Time.now)
    booking.save
    refute booking.persisted?, "booking should not persist unless start date is in future"
  end

  test "booking end_time must be later than start_time" do
    booking = build(:booking, musician: @musician, client: @client)
    booking.end_time = booking.start_time
    booking.save
    refute booking.persisted?, "booking should not persist with end_time before start_time"
  end

  test "booking without an event_name will error" do
    booking = build(:booking, musician: @musician, client: @client, event_name: nil)
    booking.save
    refute booking.persisted?, "booking should not persist without an event"
  end

end
