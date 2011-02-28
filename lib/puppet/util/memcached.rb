# -*- coding: utf-8 -*-

# Requires 'dalli', but should be loaded via a 'feature', rather than
# directly.  Currently has to be done by the including class.
module Puppet::Util::Memcached
  def memcache
    # Compression in this client only hits when the value is 1K or larger, at
    # which point it is probably a win for cache efficiency.  Reconsider this
    # assumption if you use another client.
    #
    # Supply a default TTL for the data of an hour, plus a tiny bit, which
    # should give a good efficiency vs "recover from strangeness" trade-off.
    # Tune for your site, obviously, though the defaults should be
    # sufficiently good...
    @memcache ||= Dalli::Client.new('localhost:11211',
                                    :compression => true,
                                    :expires_in  => 62 * 60)
  end

  def memcache_key(request)
    config_version = request.environment.known_resource_types.version
    # We do our own namespacing, because we know more than the memcache client
    # does about the different types of input we might have.
    "puppet@#{request.environment.to_s}@#{config_version}@#{request.indirection_name}@#{request.key}"
  end

  def memcache_get(request)
    key    = memcache_key(request)

    begin
      result = memcache.get(key)
    rescue => detail
      raise "Could not get #{key} from memcache: #{detail}"
    end

    if result
      Puppet.info "Cached data found for #{key}"
      # We should probably assert the right document type, not just a known
      # one.  Oh, well, this will do...
      envelope = PSON.parse(result)
      if decoder = PSON.registered_document_types[envelope['document_type']] then
        return decoder.from_pson(envelope['data'])
      end
    end

    # Couldn't decode it, or whatever.  We got here, so we want to get it,
    # encode it, and store it before we return.
    value = yield
    store = value.to_pson
    # key, value, TTL, options – raw means "don't mashall", which given that
    # has a habit of both changing between versions, and corrupting random
    # memory on invalid input, isn't really safe to use here.
    begin
      memcache.set(key, value.to_pson, nil, :raw => true)
    rescue => detail
      raise "Could not set #{key} in memcache: #{detail}"
    end
    Puppet.info "Cache created for #{key}"

    # Return that value, then.
    value
  end
end
