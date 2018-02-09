require 'digest'
require 'zlib'

class Digest::CRC32 < Digest::Class
  include Digest::Instance

  def initialize
    reset
  end

  def reset
    @crc32 = 0
  end

  def update(str)
    @crc32 = Zlib.crc32(str, @crc32)
  end

  def finish
    [@crc32].pack('N')
  end
end
