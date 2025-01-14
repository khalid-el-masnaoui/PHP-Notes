
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