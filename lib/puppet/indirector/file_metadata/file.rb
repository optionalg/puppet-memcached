# -*- coding: utf-8 -*-
require 'puppet/file_serving/metadata'
require 'puppet/indirector/file_metadata'
require 'puppet/indirector/direct_file_server'

class Puppet::Indirector::FileMetadata::File < Puppet::Indirector::DirectFileServer
  desc "Retrieve file metadata via the local file system."

  def find(request)
    puts "Finding #{request} in file"
    # This is a cheap way around otherwise needing to patch the code; the
    # original is actually an empty class, so we are pretty much safe down
    # here doing this.
    if Puppet.settings[:run_mode] == "master" then
      memcache_get(request) do
        return unless data = super
        data.collect

        data
      end
    else
      return unless data = super
      data.collect

      data
    end
  end

  def search(request)
    return unless result = super

    result.each { |instance| instance.collect }

    result
  end
end
