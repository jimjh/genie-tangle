#
# Autogenerated by Thrift Compiler (0.9.0)
#
# DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
#

require 'thrift'

class TangleInfo
  include ::Thrift::Struct, ::Thrift::Struct_Union
  UPTIME = 1
  THREADS = 2

  FIELDS = {
    UPTIME => {:type => ::Thrift::Types::DOUBLE, :name => 'uptime'},
    THREADS => {:type => ::Thrift::Types::MAP, :name => 'threads', :key => {:type => ::Thrift::Types::STRING}, :value => {:type => ::Thrift::Types::I32}}
  }

  def struct_fields; FIELDS; end

  def validate
  end

  ::Thrift::Struct.generate_accessors self
end

class SSHException < ::Thrift::Exception
  include ::Thrift::Struct, ::Thrift::Struct_Union
  def initialize(message=nil)
    super()
    self.message = message
  end

  MESSAGE = 1

  FIELDS = {
    MESSAGE => {:type => ::Thrift::Types::STRING, :name => 'message'}
  }

  def struct_fields; FIELDS; end

  def validate
  end

  ::Thrift::Struct.generate_accessors self
end

