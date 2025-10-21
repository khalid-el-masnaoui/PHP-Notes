
# PHP Xdebug


Debugging is an essential part of PHP development, and using Visual Studio Code with XDebug can greatly enhance your workflow. This guide will walk you through setting up XDebug, enabling breakpoints, stepping through code, using stack traces, and troubleshooting common issues.


## Table Of Contents

- [PHP Xdebug](#php-xdebug)
   * [Xdebug ](#xdebug)
      + [Overview](#overview)
      + [Key Features](#key-features)
      + [Installation & Set-Up](#installation-set-up)
         - [Installation and Configuration](#installation-and-configuration)
      + [Setting Up VSCode for XDebug](#setting-up-vscode-for-xdebug)
   * [Xdebug Docker](#xdebug-docker)
      + [Dev-Only PHP Docker Image With Xdebug](#dev-only-php-docker-image-with-xdebug)
         - [Building the image](#building-the-image)
         - [Creating configuration files](#creating-configuration-files)
         - [Creating the docker compose setup](#creating-the-docker-compose-setup)
      + [Wiring everything together with VSCode tasks](#wiring-everything-together-with-vscode-tasks)
- [Resources](#resources)

## Xdebug 

### Overview

Xdebug is a powerful PHP extension designed to enhance the PHP development experience, primarily through debugging and profiling capabilities.

Xdebug is a PHP extension that helps developers debug and smoothen the development of their projects to watch for errors and resolve them. It upgrades PHP’s `var_dump()` function and adds stack traces for notices, warnings, errors, and exceptions.


### Key Features

- **Step Debugging:**  This allows developers to execute PHP code line by line, inspect variable values, and control program flow during execution within an Integrated Development Environment (IDE) like PhpStorm or Visual Studio Code.
    
- **Improved Error Reporting:**  Xdebug provides more detailed error messages, including stack traces for various error types (Notices, Warnings, Errors, and Exceptions), and an enhanced `var_dump()` function for better variable inspection.
    
- **Profiling:**  Xdebug's profiler analyzes the performance of PHP applications, identifying bottlenecks and areas for optimization. It generates Cachegrind-compatible files that can be visualized with tools like KCacheGrind or QCacheGrind.
    
- **Tracing:**  This feature records every function call, including arguments and invocation locations, to a file for later analysis.
    
- **Code Coverage:**  Xdebug can generate reports indicating which parts of the code have been executed during testing, aiding in the assessment of test suite effectiveness.

### Installation & Set-Up

#### Installation and Configuration

1. You can install it using pecl or your package manager

```shell
# using pecl
sudo pecl install xdebug

# using debian apt package manager
sudo apt install php-xdebug;
```

2. Add Xdebug configurations 

```ini
# 99-xdebug.ini
zend_extension=xdebug.so
xdebug.mode=debug
xdebug.client_host=127.0.0.1
xdebug.client_port=9003
#xdebug.log=/var/log/xdebug.log
```

- `xdebug.start_with_request=yes` : we are not adding this configuration by default , we will only enable Xdebug when needed (when using vscode debugger)

- `99-xdebug.ini`  : PHP loads ini files consequently, alphabetically. Numbers are an explicit way to tell PHP which extensions should be loaded last. For instance, XDebug conflicts with OPcache, if loaded before. The “99” guarantees that XDebug is loaded in the end.


### Setting Up VSCode for XDebug

1. Install the PHP Debug Extension (installed by default if you are using the devsense tool extension)

2. Configure VSCode Debugger

- Find where your `99-xdebug.ini`is located

```shell
# in linux debian, mostly it is here (cli or php-fpm")
/etc/php/8.1/cli/conf.d/99-xdebug.ini
```

- We export this path, open `.bashrc`

```shell
# manually
export PHP_CONF_D=/etc/php/8.1/cli/conf.d/

# automatically with the php version
export PHP_VER_SHORT=$(php -r "echo substr(PHP_VERSION, 0, 3);")  
export PHP_CONF_D=/etc/php/$PHP_VER_SHORT/cli/conf.d

# => save and reload via command : source ~/.bashrc
```

- Add VSCode tasks for enabling/disabling Xdebug

		Just another way to automate actions sequences. Simply putting, these are just CLI commands that are issued on a command from VSCode.
		There are two types of tasks in VSCode: workspace-related and global ones. Having these actions in the global task would simplify the initial setup of every future PHP project, that's what we are going to be using


```json
// Open the command palette of VSCode and type: `Tasks: Open User Tasks`
        {
            "label": "Enable XDebug",
            "type": "shell",
            "command": "echo 'xdebug.start_with_request=yes' >> $PHP_CONF_D/99-xdebug.ini",
            "presentation": {
                "reveal": "never",
                "clear":true,
                "close": true
            }
        },
        {
            "label": "Disable XDebug",
            "type": "shell",
            "command": "sed -i.bu '/xdebug.start_with_request=yes/d' $PHP_CONF_D/99-xdebug.ini",
            "presentation": {
                "reveal": "never",
                "clear": true,
                "close": true
            }
        },
        {
            "label": "Kill PHP built-in server",
            "type": "shell",
            "command": "kill $(ps aux | grep php | awk '{print $2}')"
        }
// This way of managing a single setting turns XDebug on and off for every request that is served with your system installation of PHP.
```

- Creating the launch pattern at VSCode

```json
	// go to debugging panel in vscode and add configurations --> Open your project in VSCode.
- Go to the Run and Debug panel (`Ctrl+Shift+D`).
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Launch built-in server and Debug",
            "type": "php",
            "request": "launch",
            "noDebug": false,
            "port": 9003,
            "runtimeArgs": [
		        "-dxdebug.mode=debug",
		        "-dxdebug.start_with_request=yes",
		        "-S",
		        "localhost:8080"
		    ],
            "cwd": "${workspaceRoot}/src",
            "serverReadyAction": {  
				"pattern": "Development Server \\(http://localhost:([0-9]+)\\) started",
				"uriFormat": "http://localhost:%s",  
				"action": "openExternally"  
			},
            "postDebugTask": "Kill PHP built-in server",

        },
        {
            "name": "Listen for Xdebug",
            "type": "php",
            "request": "launch",
            "port": 9003,
		    "preLaunchTask": "Enable XDebug",
		    "postDebugTask": "Disable XDebug",
	        "cwd": "${workspaceRoot}/src"
            //"postDebugTask": "Kill PHP built-in server",
        }
    ]
```


3. Debugging Features

- Start the Debugger : 
	- Click the green Start Debugging button or press `F5`.
	- Ensure XDebug is running and listening on port 9003.

- Setting Breakpoints
	- Click in the left margin next to a line number or press `F9` to set a **breakpoint**.
	- Run the debugger (`F5`) and execute the PHP script in your browser.
	- The script execution will pause at the breakpoint.

- Stepping Through Code
	- Step Over (`F10`) -- Move to the next line of code.
	- Step Into (`F11`) -- Enter into function calls.
	- Step Out (`Shift+F11`) -- Exit the current function.
	- Continue (`F5`) -- Resume execution until the next breakpoint.

- Add variables/expressions to the Watch panel
    - Click the "+" icon next to "WATCH" to add a new watch expression.
    - Type the name of the variable (e.g., `$myVariable`) or an expression (e.g., `$myArray['key']`, `$myVariable > 1`) you want to monitor and press Enter.
    - Alternatively, you can select a variable in your code, right-click, and choose "Add to Watch.  
    - As you step through your code (using controls like `F10` for "Step Over" or `F11` for "Step Into"), the values of the watched variables and expressions will update in the Watch panel, reflecting their state at each point of execution.

- Learn to Use Stack Trace
	- The Call Stack panel in VSCode shows the sequence of function calls leading up to the breakpoint.
	- Helps trace errors in deeply nested functions.
	- Click on any function in the stack to inspect its execution.

## Xdebug Docker

Starting from 20.10 version, Docker Engine supports talking to the host machine via the special flag:

```shell
--add-host=host.docker.internal:host-gateway
```

The same thing is valid for Docker Compose system with `extra_hosts` directive:

```yaml
version: '3.9'  
  
services:  
  some-service:  
    image: awesome-service:latest  
    extra_hosts:  
      - "host.docker.internal:host-gateway"
```

 With this feature, we can now make our apps talk to the host system’s XDebug modules. Happily, such module is shipped with VSCode’s `xdebug.php-debug` extension. All together, this enables us for creating a dev-only PHP docker image.

### Dev-Only PHP Docker Image With Xdebug

#### Building the image
Create the following file (Dockerfile) under the root of the project:

```yaml
#Taking the core image as base
FROM php:8.2-fpm AS base

#Install and enable xdebug extension
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug

#Tag the image for the future conveniency
FROM base AS runner
```

Since this is a dev-only Docker image, we don’t actually copy files. Instead, we’ll map whole directories inside. This is a non-production approach, however it might be really helpful at the development time.

#### Creating configuration files

We will need two elements of the setup to be configured:

- nginx
- xdebug (inside of the docker container)

```ini
# xdebug.ini in the root folder
xdebug.mode=debug
xdebug.client_host=host.docker.internal
xdebug.client_port=9003
```

Please notice this line: `xdebug.client_host=host.docker.internal`.  This makes XDebug report not to localhost but to the address of the host machine.

#### Creating the docker compose setup

Two services are fairly enough for the test. Please, create the following file in the root of the project:

```yml
version: "3.9"  
  
services:  
  fpm:  
    build: . #going to use the dockerfile we'  
    volumes:    
      - ./src:/var/www/html #mapping actual files into the image  
      - ./xdebug.ini:/usr/local/etc/php/conf.d/99-xdebug.ini #enable xdebug debugging, load in the end  
    extra_hosts:  
      - host.docker.internal:host-gateway #attach the host machine as the internal DNS addres  
  nginx:  
    image: nginx:latest  
    volumes:  
      - ./src:/var/www/html #again map the whole file structure  
      - ./nginx.conf:/etc/nginx/conf.d/default.conf #sample nginx config  
    ports:  
      - 8080:80     
```

### Wiring everything together with VSCode tasks

Let’s create a project-level tasks file, alongside `launch.json` . It’s required to call it `tasks.json` .

```json
// tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Start with XDebug",
      "type": "shell",
      "command": [
        "echo 'xdebug.start_with_request=yes' >> ${workspaceRoot}/xdebug.ini",
        "&&",
        "docker compose up -d"
      ],
      "presentation": {
        "reveal": "never",
        "clear": true,
        "close": true
      }
    },
    {
      "label": "Stop with XDebug",
      "type": "shell",
      "command": [
        "sed -i.bu '/xdebug.start_with_request=yes/d' ${workspaceRoot}/xdebug.ini",
        "&&",
        "docker compose down"
      ],
      "presentation": {
        "reveal": "never",
        "clear": true,
        "close": true
      }
    }
  ]
}
```

Two tasks: the first modifies `xdebug.ini` to enable the debugging and starts the compose setup, the second does the opposite, switches everything off.

```json
// launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Listen for Xdebug",
      "type": "php",
      "request": "launch",
      "preLaunchTask": "Start with XDebug",
      "postDebugTask": "Stop with XDebug",
      "port": 9003,
      "cwd": "${workspaceRoot}/src",
      "pathMappings": {
        "/var/www/html": "${workspaceRoot}/src"
      }
    }
  ]
}
```

**Note** : The same approach would work with the code launched remotely at some server. This would let you debug the code at other environments than your local one using an SSH tunnel (reverse port forwarding)

```shell
ssh -R 9003:localhost:9003 <username>@<remote_host> -p <port>
```
# Resources

[Article-1](https://medium.com/@nikitades/debug-php-in-vscode-like-a-pro-2659576021b9)

[Article-2](https://dev.to/phpcontrols/debugging-php-with-vscode-and-xdebug-a-step-by-step-guide-4296)

[Article-3](https://medium.com/@nikitades/debugging-php-in-vscode-like-a-pro-part-2-vscode-php-in-docker-66ca75cf8b33)