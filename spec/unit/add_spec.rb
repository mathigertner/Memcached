require_relative '../spec_helper'

describe Commands::Add do
  describe '#process_sto' do
    it 'stores data' do
      # Setup
      key = 'key'
      flags = '0'
      bytes = '5'
      cas = 1
      values = [key, flags, '0', bytes, cas]
      memcached = {}
      data = 'value'

      # Exercise
      Commands::Add.process_sto(values: values, memcached: memcached, data: data)

      # Verify
      expected_value = { 'bytes' => bytes.to_i,
                         'cas' => cas,
                         'data' => data,
                         'flags' => flags.to_i }
      expect(memcached[key]).to eql(expected_value)
    end

    it 'key already exists' do
      # Setup
      key = 'key'
      values = [key, '0', '0', '5', 1]
      memcached = {}
      data = 'value'
      new_data = 'newst'
      values[4] = Commands::Add.process_sto(values: values, memcached: memcached, data: data)

      # Exercise
      Commands::Add.process_sto(values: values, memcached: memcached, data: new_data)

      # Verify
      expect(memcached[key]['data']).to equal(data)
    end
  end
end
