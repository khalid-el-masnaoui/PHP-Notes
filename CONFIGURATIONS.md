
# PHP & PHP-FPM Configurations

This is an example configuration `php-fpm`  which is the preferred way of serving PHP with FastCGI.

Php-fpm has the capacity to adjust the number of workers **dynamically** to the load, varying from a minimum to a specified maximum.


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