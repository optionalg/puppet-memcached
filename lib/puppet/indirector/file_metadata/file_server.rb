require 'puppet/file_serving/metadata'
require 'puppet/indirector/file_metadata'
require 'puppet/indirector/file_server'
require 'puppet/util/memcached'

class Puppet::Indirector::FileMetadata::FileServer < Puppet::Indirector::FileServer
  desc "Retrieve file metadata using Puppet's fileserver."
  include Puppet::Util::Memcached

  def initialize(*args)
    raise "'dalli' gem required for memcached use" unless Puppet.features.dalli?
    super
  end

  def find(request)
    # This is a cheap way around otherwise needing to patch the code; the
    # original is actually an empty class, so we are pretty much safe down
    # here doing this.
    if Puppet.settings[:run_mode] == "master" then
      memcache_get(request) do
        super(request)
      end
    else
      super(request)
    end
  end
end
