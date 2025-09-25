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