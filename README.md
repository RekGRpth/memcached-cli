# memcached-cli
memcached command line interface

```sh
This sets a key on the memcached server.
This retrieves a key from the memcached server.
This lists the keys on the memcached server.
This is able to connect to local and remote memcached servers.
The data to set is taken from stdin.
Usage: memcached.sh options
Options:
 -h This help message
 -C [COMMAND] Command to execute. Available commands is add, append, prepend, replace, set, decr, delete, incr, get, stats, touch, list.
 -E [EXPTIME] Expiration time in seconds, 0 mean no delay, if exptime is superior to 30 day, memcached will use it as a UNIX timestamps for expiration.
 -F [FLAGS] 32-bit unsigned integer that the server store with the data (provided by the user), and return along the data when the item is retrieved.
 -H [HOST] Memcached host to connect to. Default is MEMCACHED_HOST environment variable if it set or localhost else.
 -K [KEY] The key of the data stored.
 -N [NOREPLY] Optional parameter that inform the server to not send the reply.
 -P [PORT] Memcached port to connect to. Default is MEMCACHED_PORT environment variable if it set or 11211 else.
 -V [VALUE] The data to stored.
```
