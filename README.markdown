Puppet Memcached
================
Prototype integration with memcached.  This is purely for demonstration
purposes and should not be used in production, I bet.

This caches all file metadata in memcached, and returns that metadata
rather than recalculating it each time.

The data expires after an hour or so by default, but the keys in the data
use the Puppet config_version; if you change the config version, then
you'll begin using a new set of cached data, and the old data will
expire eventually.

In production, you should probably plan on having a config_version script,
most likely producing your current git version or something similar.

This actually replaces your default 'rest' terminus for file_metadata, so
to use it, just stick it somewhere your server can read it, and put it in
front of your Puppet install in your RUBYLIB.
