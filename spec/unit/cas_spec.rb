require_relative '../spec_helper'

describe Commands::Cas do
  before(:all) do
    @socket = TCPSocket.open('localhost', 8080)
  end

  describe '#process_sto' do
    it 'updates data' do
      # Setup
      key = 'key'
      cas = 1
      values = [key, '0', '0', '9', cas, false]
      memcached = {}
      data = 'memcached'
      Commands::Add.process_sto(values: values, memcached: memcached, data: data)
      flags = '1'
      bytes = '5'
      new_data = 'redis'
      cas_values = [key, flags, '0', bytes, cas, @socket]

      # Exercise
      Commands::Cas.process_sto(values: cas_values, memcached: memcached, data: new_data)

      # Verify
      expected_value = { 'bytes' => bytes.to_i,
                         'cas' => cas,
                         'data' => new_data,
                         'flags' => flags.to_i }
      expect(memcached[key]).to eql(expected_value)
      expect(memcached.size).to eql(1)
    end

    it 'does not update data' do
      # Setup
      key = 'key'
      cas = 1
      values = [key, '0', '0', '9', cas, false]
      memcached = {}
      data = 'memcached'
      Commands::Add.process_sto(values: values, memcached: memcached, data: data)
      flags = '1'
      bytes = '5'
      new_data = 'redis'
      cas_values = [key, flags, '0', bytes, 20, @socket]

      # Exercise
      Commands::Cas.process_sto(values: cas_values, memcached: memcached, data: new_data)

      # Verify
      expect(memcached[key]['data']).to eql(data)
    end
  end
end
