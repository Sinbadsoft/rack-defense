require_relative 'spec_helper'

describe 'Rack::Defense::Throttle' do
  before do
    Redis.current.flushdb
    @rule = Rack::Defense::Throttle.new('upload_photo', 5, 10, Redis.current)
    do_max_hits_minus_one_requests
  end

  describe '.throttle?' do
    it 'allow request number max_hits if after period' do
      refute @rule.throttle? 11
    end
    it 'block request number max_hits if in period' do
      assert @rule.throttle? 10
    end
    it 'allow consecutive valid periods' do
      (1..20).each { |i| do_max_hits_minus_one_requests(11 * i) }
    end
  end

  def do_max_hits_minus_one_requests(offset=0)
    [0, 3, 5, 9].map { |e| e + offset }.each do |e|
      refute @rule.throttle?(e), "timestamp #{e}"
    end
  end
end
