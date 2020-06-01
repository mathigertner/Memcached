require_relative '../spec_helper'

describe Commands::Append do
  describe '#process_sto' do
    it 'appends data' do
      # Setup
      key = 'key'
      flags = '0'
      bytes = '5'
      cas = 1
      values = [key, flags, '0', bytes, cas]
      memcached = {}
      data = 'value'
      Commands::Add.process_sto(values: values, memcached: memcached, data: data)
      append_bytes = '1'
      append_values = [key, flags, '0', append_bytes, cas]
      append_data = 'z'

      # Exercise
      Commands::Append.process_sto(values: append_values, memcached: memcached, data: append_data)

      # Verify
      expected_value = { 'bytes' => bytes.to_i + append_bytes.to_i,
                         'cas' => cas,
                         'data' => "#{data}#{append_data}",
                         'flags' => flags.to_i }
      expect(memcached[key]).to eql(expected_value)
    end

    it 'key does not exist' do
      # Setup
      key = 'key'
      cas = 1
      memcached = {}
      append_values = [key, '0', '0', '1', cas]
      append_data = 'z'

      # Exercise
      Commands::Append.process_sto(values: append_values, memcached: memcached, data: append_data)

      # Verify
      expect(memcached).to be_empty
    end
  end
end
