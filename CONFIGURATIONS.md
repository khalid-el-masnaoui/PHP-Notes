
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
|-- mods-available         # Your extensions/modules Config
|   |-- opcache.ini
|   |-- pdo.ini
|   |-- .....
```
