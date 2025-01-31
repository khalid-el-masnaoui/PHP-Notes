
# PHP & PHP-FPM Configurations

This is an example configuration `php-fpm`  which is the preferred way of serving PHP with FastCGI.

Php-fpm has the capacity to adjust the number of workers **dynamically** to the load, varying from a minimum to a specified maximum.

# Table Of Contents

- **[Configuration Directory Structure](#configuration-directory-structure)**
    - **[php.ini](#phpini)**
    - **[mods-available](#mods-available)**
- **[Basic Configurations](#basic-configurations)**
    - **[Configuration layouts](#configuration-layouts)**
    - **[php-ini](#phpini-1)**
    - **[php-fpm.conf](#php-fpmconf)**
    - **[pool.d](#poold)**
- **[Other Configurations](#other-configurations)**
	- **[Passing environment variables and PHP settings to a pool](#passing-environment-variables-and-php-settings-to-a-pool)**
	- **[Set PHP settings in nginx.conf](#-set-php-settings-in-nginxconf)**
	- **[Multiple PHP-FPM pools](#multiple-php-fpm-pools)**

## Configuration Directory Structure

Here's an overview of this PHP configuration directory structure:

```bash
#Configuration
|-- php.ini               # Your PHP Config file
|-- php-fpm.conf          # Your PHP-FPM Config file
|-- pool.d                # Your PHP-FPM resource pool Config
|   |-- app1.conf
|   |-- app2.conf
|-- mods-available        # Your extensions/modules Config
|   |-- opcache.ini
|   |-- pdo.ini
|   |-- .....
```

### php.ini
When it comes to modifying PHP configurations, it is important to understand the difference between CLI and FPM runtime environments.

- FPM (FastCGI Process Manager) is a runtime environment for HTTP servers `/etc/php/<VERSION>/fpm/php.ini`;
- CLI (Command Line Interface) is a command-line execution environment => `/etc/php/<VERSION>/cli/php.ini`

### mods-available

This is where our Available modules are stored, some that come with PHP, and some we installed ourselves, are available in `/etc/php/<VERSION>/mods-avaiable`.

We can check the `conf.d` directory:

```bash
ls -lah /etc/php/<VERSION>/{fpm,cli}/conf.d
```

We see a bunch of symlinks to the `mods-available` directory.

**Enable / Disable Modules**

To enable or disable a module for a `SAPI`, we can create or destroy a symlink in the `conf.d` directory for that `SAPI`. We'll need to restart php-fpm if we change it, but CLI-run PHP is affected immediately (since each call to `php` on the command line is starting a new process).

Note that this means your cron tasks / queue workers may have a different php.ini and set of modules than your web-run php.

We can also use the simpler `phpenmod` and `phpdismod` commands. Use the `-s` flag to define a specific `SAPI` if you don't want all of them affected.

```bash
# Disable xdebug for php-fpm
sudo phpdismod -s fpm xdebug
sudo service php8.1-fpm reload
```


## Basic Configurations

### Configuration layouts

The configuration comes in two flavors (`SAPI`):

> 1. **UNIX** : which is the **default**. It uses **UNIX domain sockets** for communication between the FCGI responder provided by php-fpm and the server or request frontend.
    
> 2. **TCP** : It uses **TCP sockets** for communication between the FCGI responder provided by php-fpm and the server or request frontend.


### php.ini

we will explain the most important parameters in the **php.ini** file, including their values and purposes. These parameters are also known as **directives**.

> **`display_errors`** : Determine if PHP error messages are displayed to users during script execution or not using the **on** and **off** value. Due to security reasons, you should use this directive only when developing your site.

> **`error_reporting`** : Set which error message is displayed to users when **display_errors** is enabled. The **error_reporting** parameter takes several [constants to display different errors](https://www.php.net/manual/en/errorfunc.constants.php).
> You may use multiple constants and exclude specific errors. For instance, to show all errors but the deprecation warning, use the following: _E_ALL &amp; ~E_DEPRECATED_

> **`error_log`** :  Specify the file where PHP will log errors for error troubleshooting. Before enabling it, ensure the web server’s users have permission to write the file.

> **`file_uploads`** :  Set whether the HTTP file uploads are enabled or not. The **on** value will allow users to upload files to your site, while **off** disables it.

> **`upload_max_filesize`** : This parameter determines the maximum uploaded file size PHP allowed on your site. Since the default value is **2 MB**, you can increase the maximum upload file size limit to enable users to upload large files.

> **`post_max_size`** : The maximum POST data size PHP can collect from HTML forms on your site. The value should be larger than the maximum file size, as it is handled with the POST function.

> **`allow_url_fopen`**: Write a PHP script to access remote files from another server. It is **off** by default, as enabling it may expose your server to a code injection attack.

> **`allow_url_include`** :This directive has a similar function as **allow_url_open**, but uses the include function To enable it, **allow_url_open** must be set to **on**.

>**`session.name`** : This directive sets the current session’s name used in cookies and URLs. You may change the default **PHPSESSID** value to any descriptive name with alphanumeric characters.

> **`session.auto_start`** : Choose whether a PHP session starts automatically or on request when users access your site. If you set the value to **0,** the session will start manually using the **session_start** script.

> **`session.cookie_lifetime`** : Specify a session cookie’s lifetime in your site’s visitors’ browsers. By default, the value is set to **0** seconds, meaning your site erases visitors’ session data after they close their browsers.

> **`memory_limit`** : Set the maximum amount of RAM a PHP script can use. Be careful when increasing the memory limit, as wrong configurations may lead to slow sites or server outages.

> **`max_execution_time`** : Determine a script’s maximum running time. You can change the default 30-second maximum execution time to any value, but setting it too high might cause performance issues.

> **`max_input_time`** : Set how long a script can parse data collected from HTML forms on your site using a POST or GET method]. The more data your site collects, the higher the **max_input_time** value should be.

> **`upload_temp_dir`** : Specify the temporary directory for storing uploaded files. All users should be able to write in the specified directory, or PHP will use the system’s default.

> **`realpath_cache_ttl`** : Set the duration for your system to cache the realpath information. We recommend increasing the value for systems with rarely changing files.

> **`arg_separator.output`** : Use this data-handling directive to separate arguments in PHP-generated URLs. Its default value is an ampersand (**&**).

> **`auto_prepend_file`** and **`auto_append_file`** : These two PHP directives perform the same function as `require()` but they do it globally on all PHP scripts,  before and after it parses the php scripts.


## php-fpm.conf

Some of the  most important parameters in the **php-fpm.conf** file.

> **`error_log`** :  Specify the file where PHP will log errors for error troubleshooting. Before enabling it, ensure the web server’s users have permission to write the file.

> **`log_level`** : Error log level. Possible values: alert, error, warning, notice, debug. Default value: notice.

> **`emergency_restart_threshold`**:  If this number of child processes exit with Segmentation, page fault, and access violation (SIGSEGV or SIGBUS) within the time interval set by emergency_restart_interval then FPM will restart

> **`emergency_restart_interval`** : nterval of time used to determine when a graceful restart will be initiated. This can be useful to work around accidental corruptions in an accelerator’s shared memory

> **`process_control_timeout`** : Time limit for child processes to wait for a reaction on signals from master.


## pool.d

Multiple pools of child processes may be started with different listening ports and different management options.  The name of the pool will be used in logs and stats. There is no limitation on the number of pools which FPM can handle. So system limit is the FPM limit.

> **`listen`** : FPM supports Unix Socket and TCP Socket, It used to mode connecting mechanism of PHP request from frontend server (like nginx, etc)

```bash
listen = 127.0.0.1:9000
listen = /run/php/php8.1-fpm.sock
```

> **`listen.backlog`** : The backlog argument defines the maximum length to which the queue of pending connections

> **`listen.owner`** and **`listen.group = www-data`** :  Set permissions for unix socket, if one is used. In Linux, read/write permissions must be set in order to allow connections from a web server.

```bash
listen.owner = www-data
listen.group = www-data
```

> **`listen.allowed_clients`** : List of IPv4 or IPv6 addresses of FastCGI clients which are allowed to connect. Makes sense only with a tcp listening socket

>**`pm`** : Define Process Manager controll mechanism of Child process

```bash
- **static**  – a fixed number (pm.max_children) of child processes
- **dynamic** – the number of child processes are set dynamically based on the following directives : `pm.max_children`, `pm.start_servers`, `pm.min_spare_servers`, `pm.max_spare_servers.. With this process management, there will be always at least 1 children
- **ondemand** – no children are created at startup. Children will be forked when new requests will connect
```

> **`pm.max_children`** : The number of child processes to be created when `pm` is set to `static` and the maximum number of child processes to be created when `pm` is set to `dynamic`. This option is mandatory.
>This option sets the limit on the number of simultaneous requests that will be served.

> **`pm.start_servers`**  : The number of child processes created on startup. Used only when `pm` is set to `dynamic`.

> **`pm.min_spare_servers`** : The desired minimum number of idle server processes. Used only when `pm` is set to `dynamic`. Also mandatory in this case.

> **`pm.max_spare_servers`**: The desired maximum number of idle server processes. Used only when `pm` is set to `dynamic`. Also mandatory in this case.

> **`pm.process_idle_timeout`** : The number of seconds after which an idle process will be killed. Used only when `pm` is set to `ondemand`.

> **`pm.max_requests`** : The number of requests each child process should execute before respawning. (avoiding the risk of memory leaks)

> **`pm.status_listen`**: The address on which to accept FastCGI status request. This creates a new invisible pool that can handle requests independently. This is useful if the main pool is busy with long running requests because it is still possible to get the [FPM status page](https://www.php.net/manual/en/fpm.status.php) before finishing the long running requests.

> **`pm.status_path`** :The URI to view the [FPM status page](https://www.php.net/manual/en/fpm.status.php). This value must start with a leading slash (/). If this value is not set, no URI will be recognized as a status page. (For PHP-FPM monitoring)

> **`access.log`** : The access log file.

> **`access.format`** : The access log format.

> **`request_slowlog_timeout`** : The timeout for serving a single request after which a PHP backtrace will be dumped to the 'slowlog' file. 

> **`slowlog`** : The log file for slow requests. 

> **`request_terminate_timeout`** : The timeout for serving a single request after which the worker process will be killed. This option should be used when the max_execution_time ini option does not stop script execution for some reason

> **`rlimit_files`** : This directive allows to override a system defined limit for Open File descriptor for PHP-FPM.


## Other Configurations

###  Passing environment variables and PHP settings to a pool

```bash
env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp

php_admin_value[sendmail_path] = /usr/sbin/sendmail -t -i -f www@my.domain.com
php_flag[display_errors] = off
php_admin_value[error_log] = /var/log/fpm-php.www.log
php_admin_flag[log_errors] = on
php_admin_value[memory_limit] = 32M
```

`php_flag` is used for booleans, `php_value` is used for everything else. Any kind of configuration directive that takes parameters other than On/Off, you can use php_value for

PHP settings passed with `php_value` or `php_flag` will overwrite their previous value.
Settings defined with `php_admin_value` and `php_admin_flag` cannot be overridden with `ini_set()`.

Only use the `php_admin_value` and `php_admin_flag` if you explicitly want to forbid that configuration directive from being changed by your application.

### Set PHP settings in nginx.conf

```nginx
set $php_value "pcre.backtrack_limit=424242";
set $php_value "$php_value \n pcre.recursion_limit=99999";
fastcgi_param  PHP_VALUE $php_value;

fastcgi_param  PHP_ADMIN_VALUE "open_basedir=/var/www/htdocs";
```

### Multiple PHP-FPM pools

Each pool operates independently, and multiple pools can coexist on the same server. PHP-FPM pools allow for better resource management, isolation, and flexibility in handling PHP requests.

Configuring PHP-FPM pools involves creating or modifying pool configuration files. Each pool can have its own set of configuration parameters, allowing you to customize the behavior of PHP-FPM for different applications or websites. These pool configuration files are stored in the `/etc/php/{VERSION}/fpm/pool.d/` directory.

**Note**: Pools are not a security mechanism, because they do not provide full separation; e.g. all pools would use a single OPcache instance.