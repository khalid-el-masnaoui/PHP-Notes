# PHP Performance Best Practices

This document revisits the essential optimized-performance practices for PHP & PHP-FPM runtime from a practical perspective.

By following the key recommendations outlined below, you can avoid common configuration errors while ensuring optimized performances.



### What exactly is a good PHP performance?

Performance and speed are not necessarily synonymous. Achieving optimal performance is often a balancing act that requires trade-offs between speed, accuracy, and scalability. For example, while building a web application, you may have to decide between prioritizing speed by writing a script that loads everything into memory up front or prioritizing scalability with a script that loads data in chunks.
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


3.  **Monitor OPcache performance**: Use monitoring tools like **opcache_get_status()** or third-party solutions like the **OPcache GUI**  or **CachTool** to review cache usage, cache hits, and other relevant metrics. Analyzing this data can help you fine-tune your OPcache settings for optimal performance.

```shell
# CachTool
php cachetool.phar opcache:status --fcgi=/var/run/php5-fpm.sock #php-fpm
php cachetool.phar opcache:status --cli #cli
```

| Name                 | Value                           |
| -------------------- | ------------------------------- |
| Enabled              | Yes                             |
| Cache full           | No                              |
| Restart pending      | No                              |
| Restart in progress  | No                              |
| Memory used          | 66.83 MiB                       |
| Memory free          | 444.8 MiB                       |
| Memory wasted (%)    | 381.68 KiB (0.072799623012543%) |
| Strings buffer size  | 48 MiB                          |
| Strings memory used  | 503.22 KiB                      |
| Strings memory free  | 47.51 MiB                       |
| Number of strings    | 10569                           |
| Cached scripts       | 59                              |
| Cached keys          | 63                              |
| Max cached keys      | 32531                           |
| Start time           | Fri, 18 Jul 2025 07:43:21 +0900 |
| Last restart time    | Never                           |
| Oom restarts         | 0                               |
| Hash restarts        | 0                               |
| Manual restarts      | 0                               |
| Hits                 | 234846874                       |
| Misses               | 86                              |
| Blacklist misses (%) | 0 (0%)                          |
| Opcache hit rate     | 99.999963380407                 |
### OPcache preloading

OPcache preloading (`PHP +7.4`) loads selected files into shared memory, making their content (functions, classes) globally available for requests when the PHP engine starts. It also removes the need to include these files later. 

* To enable preloading, add a variable that specifies a preload script in the `php.ini`:
````shell
opcache.preload=/path/to/your/preload.php
````
* Create a PHP script `preload.php` that explicitly lists and includes the files you want to preload. This script will be executed once when the PHP process starts.
```php 
<?php  
// preload.php  
opcache_compile_file(__DIR__ . '/path/to/your/important-file.php');  
opcache_compile_file(__DIR__ . '/path/to/another/important-file.php');  
// You can also use require_once or include_once for files  
// require_once __DIR__ . '/vendor/autoload.php'; // Example for Composer autoload  


## preload all php files in a specific directory
# Define the directory to preload  
$directoryToPreload = '/path/to/your/application/src'; // Replace with your target directory  
  
// Function to recursively find and preload PHP files  
function preloadDirectory($directory) {  
	$directoryIterator = new RecursiveDirectoryIterator($directory, RecursiveDirectoryIterator::SKIP_DOTS)
	$files = new RecursiveIteratorIterator($directoryIterator, RecursiveIteratorIterator::LEAVES_ONLY  
);  
  
	foreach ($files as $file) {  
		if ($file->isFile() && $file->getExtension() === 'php') {  
			opcache_compile_file($file->getPathname());  
		}  
	}  
}  
  
// Execute the preloading  
preloadDirectory($directoryToPreload);

```

### Enable Just-In-Time (JIT) Compilation

**PHP 8** introduced the JIT compiler as a core feature, offering a new avenue for PHP tuning.

* ***Upgrade to PHP 8**: Ensure your application is compatible with PHP 8 and take advantage of its new features, including the JIT compiler, improved syntax, and other performance optimizations.
* **Configure JIT settings**: Fine-tune your JIT settings in the php.ini file to optimize performance.
```shell
# php.ini

opcache.enable = 1 # opache must be enabled
opcache.jit_buffer_size =  # determines the amount of memory allocated for storing compiled machine code
opcache.jit = on  # default 'tracing/on' JIT compilation mode[check INTERNALS.md]
```

### Enable realpath_cache
The PHP realpath cache is a mechanism within PHP that stores the resolved, canonical paths of files and directories. When PHP needs to access a file, it often first needs to determine its absolute path, resolving any symbolic links, relative path components (like `.` or `..`), and directory separators. This process can be computationally intensive, especially when dealing with complex file structures or frequent file access.

- When a file path is first requested in PHP (e.g., through `include`, `require`, `file_exists()`, `realpath()`), PHP resolves its real path on the filesystem.
- This resolved path, along with other metadata like expiration time, is then stored in the `realpath` cache.
- Subsequent requests for the same file path can then retrieve the real path directly from the cache, avoiding the need for repeated filesystem lookups.

```shell
realpath_cache_size = 4M # the maximum size of the realpath cache in bytes.
realpath_cache_ttl = 300 #he time-to-live (TTL) for realpath cache entries in seconds. After this duration, an entry is considered expired and will be re-resolved on the next access.
```


### Turn off MySQL statistics in `php.ini`

Make sure on your production servers, both of these settings **`mysqlnd.collect_statistics`** and **`mysqlnd.collect_memory_statistics`** are disabled. It should always be disabled unless you have a specific reason to enable it.

You can view MySQL run-time statistics using the MySQL command line (ex. `show status;`)

```shell
mysqlnd.collect_statistics = Off
mysqlnd.collect_memory_statistics = Off
```


### output_buffering

PHP's `output_buffering` is a mechanism that controls how PHP manages the output generated by a script before it's sent to the client (e.g., a web browser). Instead of sending data to the client as it's generated, `output_buffering` allows PHP to store this output in an internal buffer.

- **Flushing:** 
    The content of the buffer is sent to the client only after the script finishes execution, or when explicitly flushed using functions like `ob_end_flush()` or `ob_implicit_flush()`.

- **Sending Headers After Output:** 
    This is a crucial benefit. HTTP headers (like `Set-Cookie`, `Location` for redirects, or `Content-Type`) must be sent before any actual content. If you generate output before setting a header, PHP will typically issue a "**headers already sent**" error. Output buffering allows you to buffer the content, set headers later in the script, and then send both together.

```shell
output_buffering = 4096 # Enables buffering with a maximum size of 4096 bytes
```

- Using `ob_start()` function: This function can be called within your PHP script to start output buffering at a specific point (even if it is not enabled in `php.ini`). It offers more granular control and allows for custom output handlers. (used with `ob_end_flush()`)

### PHP Configuration Tuning

There are several directives that can be tuned for performance like `memory_limit`,  `max_execution_time`, `upload_max_filesize`, and `post_max_size` should be configured according to the needs of your site.

example configuration : 

```shell
memory_limit = 128M
max_execution_time = 30
max_input_time = 60
post_max_size = 1.5M
upload_max_filesize = 1.1M
```


## PHP-FPM: Fine-Tuning for High Loads

##### General
PHP-FPM helps improve your app’s performance by maintaining pools of workers that can process PHP requests. This is essential when your app needs to handle a high number of simultaneous requests.  The `pm.static` configuration can offer maximum performance.


The PHP-FPM _pm static_ setting depends heavily on how much free memory your server has. If you suffer from low server memory, then pm _ondemand_ or _dynamic_ maybe be better options. On the other hand, if you have the memory available, you can avoid much of the PHP process manager (PM) overhead by setting pm _static_ to the max capacity of your server.
*  `pm.static` should be set to the max amount of PHP-FPM processes that can run _without creating memory availability or cache pressure issues_

```shell
# pool.conf
pm = static
pm.max_children = 30
pm.max_requests = 1000 # avoiding memory leaks
```

##### Adjusting child processes for PHP-FPM