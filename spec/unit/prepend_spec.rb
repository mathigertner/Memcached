require_relative '../spec_helper'

describe Commands::Prepend do
  describe '#process_sto' do
    it 'prepend data' do
      # Setup
      key = 'key'
      flags = '0'
      bytes = '5'
      cas = 1
      values = [key, flags, '0', bytes, cas]
      memcached = {}
      data = 'value'
      Commands::Add.process_sto(values: values, memcached: memcached, data: data)
      prepend_bytes = '1'
      prepend_values = [key, flags, '0', prepend_bytes, cas]
      prepend_data = 'z'

      # Exercise
      Commands::Prepend.process_sto(values: prepend_values, memcached: memcached, data: prepend_data)

      # Verify
      expected_value = { 'bytes' => bytes.to_i + prepend_bytes.to_i,
                         'cas' => cas,
                         'data' => "#{prepend_data}#{data}",
                         'flags' => flags.to_i }
      expect(memcached[key]).to eql(expected_value)
    end

    it 'key does not exist' do
      # Setup
      key = 'key'
      cas = 1
      memcached = {}
      prepend_values = [key, '0', '0', '1', cas]
      prepend_data = 'z'

      # Exercise
      Commands::Append.process_sto(values: prepend_values, memcached: memcached, data: prepend_data)

      # Verify
      expect(memcached).to be_empty
    end
  end
end
