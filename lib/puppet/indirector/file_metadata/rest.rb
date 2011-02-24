# -*- coding: utf-8 -*-
require 'puppet/file_serving/metadata'
require 'puppet/indirector/file_metadata'
require 'puppet/indirector/rest'

require 'puppet/util/memcached'

class Puppet::Indirector::FileMetadata::Rest < Puppet::Indirector::REST
  desc "Retrieve file metadata via a REST HTTP interface, with memcached caching."
  include Puppet::Util::Memcached

  def initialize(*args)
    raise "'dalli' gem required for memcached use" unless Puppet.features.dalli?
    super
  end

  def find(request)
    puts "Finding #{request} in rest"
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
