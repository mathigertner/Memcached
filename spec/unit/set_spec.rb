require_relative '../spec_helper'

describe Commands::Set do
  describe '#process_sto' do
    it 'sets data' do
      # Setup
      key = 'key'
      flags = '0'
      bytes = '5'
      cas = 1
      values = [key, flags, '0', bytes, cas]
      memcached = {}
      data = 'value'

      # Exercise
      Commands::Set.process_sto(values: values, memcached: memcached, data: data)

      # Verify
      expected_value = { 'bytes' => bytes.to_i,
                         'cas' => cas,
                         'data' => data,
                         'flags' => flags.to_i }
      expect(memcached[key]).to eql(expected_value)
    end

    it 'sets data to an existent key' do
      # Setup
      key = 'key'
      cas = 1
      values = [key, '0', '0', '5', cas]
      memcached = {}
      data = 'value'
      cas = Commands::Add.process_sto(values: values, memcached: memcached, data: data)
      flags = '1'
      bytes = '3'
      new_values = [key, flags, '0', bytes, cas]
      new_data = 'new'

      # Exercise
      Commands::Set.process_sto(values: new_values, memcached: memcached, data: new_data)

      # Verify
      expected_value = { 'bytes' => bytes.to_i,
                         'cas' => cas,
                         'data' => new_data,
                         'flags' => flags.to_i }
      expect(memcached[key]).to eql(expected_value)
      expect(memcached.size).to eql(1)
    end
  end
end
