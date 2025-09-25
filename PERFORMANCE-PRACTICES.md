# PHP Performance Best Practices

This document revisits the essential optimized-performance practices for PHP & PHP-FPM runtime from a practical perspective.

By following the key recommendations outlined below, you can avoid common configuration errors while ensuring optimized performances.


### Get Latest PHP

Newer PHP versions often offer performance improvements and better features, so as  the first step keeping PHP up to date is crucial.


### Opcode Caching <`Opcache`>

Opcode caching is a powerful technique in PHP tuning that can significantly boost your web application's speed and efficiency. By caching the compiled PHP bytecode, opcode cache eliminates the need for recompilation on each request, resulting in faster response times

To enable and configure Opcache, follow these steps:
1. **Enable the extension**: Ensure the OPcache extension is enabled in your PHP configuration file (php.ini).
2. **Configure OPcache settings**: Fine-tune your OPcache settings in the php.ini ( or better inside `opcache.ini`) file to optimize performance.
```bash 
	....
	opcache.revalidate_freq=60  # default 2
	opcache.validate_timestamps=0 #disabled : default 1
	opcache.max_accelerated_files = 30000
	opcache.memory_consumption = 512
	opcache.interned_strings_buffer	= 64
	opcache.max_wasted_percentage = 15
	opcache.file_update_protection	= 0 #default 2 (s)
```
* **`opcache.revalidate_freq`** : controls how often OPcache checks for changes in PHP files. Set this value to 0 for development environments or a higher value (e.g., 60) for production environments to reduce disk I/O
* **`opcache.validate_timestamps`** :  If enabled, OPcache will check for updated scripts every `opcache.revalidate_freq`. When disabled, `opcache.revalidate_freq`  is ignored, and you must reset OPcache manually via **opcache_reset()**, **opcache_invalidate()** or by restarting PHP for changes to the filesystem to take effect.
* `max_accelerated_files` : 
	- defines the maximum number of PHP files that can be cached. Increase this value if your application has a large number of files. ( If this value is lower than the number of files in the app, the cache becomes less effective because it starts **thrashing**.)
	- determine approximately how many `.php`file are there  : `find . -type f -name '*.php' | wc -l`
	* set `opcache.max_accelerated_files` to a value slightly higher than the returned number. PHP automatically rounds the value up to the next highest prime number.
* `memory_consumption` : determines the amount of memory allocated for storing compiled bytecode. Increase this value if you have a large application or if you notice frequent cache evictions (If the app uses more than this, the cache starts **thrashing** and becomes less effective
* `interned_strings_buffer` : Sets the memory allocated for storing interned strings. Increasing this value can improve performance, especially for applications with many string literals
* `opcache.max_wasted_percentage` : determines the maximum percentage of "wasted" memory in the OPcache shared memory until a restart is scheduled.  "wasted memory" refers to memory allocated within the OPcache that is no longer being used to store active, cached scripts. This can occur when scripts are deleted, modified, or become otherwise invalid, but their corresponding bytecode still occupies space in the cache.
* `opcache.file_update_protection` : prevents caching files that are less than this number of seconds old. It protects from caching of incompletely updated files. You may increase performance by setting this to “0” (ensure your file update are **atomic**).
