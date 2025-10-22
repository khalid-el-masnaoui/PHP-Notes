
# PHP Xdebug Profiler

Profiling is the first step when optimizing any application. Profiling tools record important details like the time it takes for statements and functions to execute, the number of times they are called, and so on. The output can be analyzed to understand where the bottlenecks are.




## Xdebig Profiler 

Xdebug's profiler is a tool for analyzing PHP code performance. It helps identify bottlenecks and slow areas within a PHP script by collecting detailed information about function calls, execution times, and memory usage.

### Configurations

```ini
# 99-xdebug.ini
zend_extension=xdebug.so
xdebug.mode=profile
xdebug.profiler_output_dir = /tmp/xdebug_profiles  
xdebug.profiler_output_name = cachegrind.out.%R.%t
#xdebug.log=/var/log/xdebug.log
```

