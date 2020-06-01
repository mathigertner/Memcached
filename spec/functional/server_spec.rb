require_relative '../spec_helper'
require 'socket'

describe Memcached::Server do
  before(:all) do
    @socket = TCPSocket.open('localhost', 8080)
  end

  context 'receives an invalid command' do
    it 'returns error' do
      @socket.puts "hello\r\n"
      o = @socket.gets
      expect(o).to eql("ERROR\r\n")
    end
  end

  context 'receives wrong parameters' do
    it 'returns client_error' do
      @socket.puts "add key\r\n"
      o = @socket.gets
      expect(o).to eql("CLIENT_ERROR <parameters>\r\n")
    end
  end

  context 'receives add cmd' do
    it 'returns stored' do
      @socket.puts "add key 0 0 5\r\n"
      data = "value\r\n"
      Marshal.dump(data, @socket, 5)
      o = @socket.gets
      expect(o).to eql("STORED\r\n")
    end

    it 'returns stored' do
      @socket.puts "add tp 0 1 5\r\n"
      data = "redis\r\n"
      Marshal.dump(data, @socket, 5)
      o = @socket.gets
      expect(o).to eql("STORED\r\n")
    end

    it 'returns not_stored' do
      @socket.puts "add key 0 0 3\r\n"
      data = "new\r\n"
      Marshal.dump(data, @socket, 3)
      o = @socket.gets
      expect(o).to eql("NOT_STORED\r\n")
    end
  end

  context 'receives append cmd' do
    it 'returns stored' do
      @socket.puts "append key 0 0 1\r\n"
      data = "z\r\n"
      Marshal.dump(data, @socket, 1)
      o = @socket.gets
      expect(o).to eql("STORED\r\n")
    end

    it 'returns not_stored' do
      @socket.puts "append foo 0 0 3\r\n"
      data = "bar\r\n"
      Marshal.dump(data, @socket, 3)
      o = @socket.gets
      expect(o).to eql("NOT_STORED\r\n")
    end
  end

  context 'receives prepend cmd' do
    it 'returns stored' do
      @socket.puts "prepend key 0 0 1\r\n"
      data = "a\r\n"
      Marshal.dump(data, @socket, 1)
      o = @socket.gets
      expect(o).to eql("STORED\r\n")
    end

    it 'returns not_stored' do
      @socket.puts "prepend foo 0 0 3\r\n"
      data = "bar\r\n"
      Marshal.dump(data, @socket, 3)
      o = @socket.gets
      expect(o).to eql("NOT_STORED\r\n")
    end
  end

  context 'receives replace cmd' do
    it 'returns stored' do
      @socket.puts "replace key 0 0 3\r\n"
      data = "new\r\n"
      Marshal.dump(data, @socket, 3)
      o = @socket.gets
      expect(o).to eql("STORED\r\n")
    end

    it 'returns not_stored' do
      @socket.puts "replace foo 0 0 3\r\n"
      data = "bar\r\n"
      Marshal.dump(data, @socket, 3)
      o = @socket.gets
      expect(o).to eql("NOT_STORED\r\n")
    end
  end

  context 'receives set cmd' do
    it 'returns stored' do
      @socket.puts "set key 0 0 5\r\n"
      data = "value\r\n"
      Marshal.dump(data, @socket, 5)
      o = @socket.gets
      expect(o).to eql("STORED\r\n")
    end
  end

  context 'receives get cmd' do
    context 'tp elem was deleted' do
      it 'returns nothing' do
        sleep 1
        @socket.puts "get tp\r\n"
        o = @socket.gets
        expect(o).to eql("END\r\n")
      end
    end

    it 'returns data' do
      @socket.puts "get key\r\n"
      o1 = @socket.gets
      data = Marshal.load(@socket)[0..4]
      o2 = @socket.gets
      expect(o1).to eql("VALUE key 0 5\r\n")
      expect(data).to eql('value')
      expect(o2).to eql("END\r\n")
    end

    it 'returns nothing' do
      @socket.puts "get nothing\r\n"
      o = @socket.gets
      expect(o).to eql("END\r\n")
    end
  end

  context 'receives gets cmd' do
    it 'returns data' do
      @socket.puts "gets key\r\n"
      o1 = @socket.gets
      data = Marshal.load(@socket)[0..4]
      o2 = @socket.gets
      expect(o1).to eql("VALUE key 0 5 3\r\n")
      expect(data).to eql('value')
      expect(o2).to eql("END\r\n")
    end

    it 'returns nothing' do
      @socket.puts "gets nothing\r\n"
      o = @socket.gets
      expect(o).to eql("END\r\n")
    end
  end

  context 'receives cas cmd' do
    it 'returns stored' do
      @socket.puts "cas key 0 0 9 3\r\n"
      data = "memcached\r\n"
      Marshal.dump(data, @socket, 9)
      o = @socket.gets
      expect(o).to eql("STORED\r\n")
    end

    it 'returns exists' do
      @socket.puts "cas key 0 0 5 4\r\n"
      data = "redis\r\n"
      Marshal.dump(data, @socket, 5)
      o = @socket.gets
      expect(o).to eql("EXISTS\r\n")
    end

    it 'returns exists' do
      @socket.puts "cas foo 0 0 5 4\r\n"
      data = "redis\r\n"
      Marshal.dump(data, @socket, 5)
      o = @socket.gets
      expect(o).to eql("NOT_FOUND\r\n")
    end

    context 'noreply cmd received' do
      it 'updates elem and does not send confirmation message' do
        @socket.puts "cas key 0 0 3 3 noreply\r\n"
        data = "new\r\n"
        Marshal.dump(data, @socket, 3)
        o1 = @socket.ready?
        expect(o1).to be false

        # verify it was succesfully updated
        @socket.puts "get key\r\n"
        o2 = @socket.gets
        data = Marshal.load(@socket)[0..2]
        o3 = @socket.gets
        expect(o2).to eql("VALUE key 0 3\r\n")
        expect(data).to eql('new')
        expect(o3).to eql("END\r\n")
      end
    end
  end
end
