require_relative '../spec_helper'

describe Commands::Replace do
  describe '#process_sto' do
    it 'replace data' do
      # Setup
      key = 'key'
      cas = 1
      memcached = {}
      data = 'old'
      values = [key, '0', '0', '3', cas]
      Commands::Add.process_sto(values: values, memcached: memcached, data: data)
      flags = '1'
      bytes = '5'
      new_values = [key, flags, '0', bytes, cas]
      new_data = 'value'

      # Exercise
      Commands::Replace.process_sto(values: new_values, memcached: memcached, data: new_data)

      # Verify
      expected_value = { 'bytes' => bytes.to_i,
                         'cas' => cas,
                         'data' => new_data,
                         'flags' => flags.to_i }
      expect(memcached[key]).to eql(expected_value)
    end

    it 'key does not exist' do
      # Setup
      values = ['key', '0', '0', '5', 1]
      memcached = {}
      data = 'value'

      # Exercise
      Commands::Replace.process_sto(values: values, memcached: memcached, data: data)

      # Verify
      expect(memcached).to be_empty
    end
  end
end
