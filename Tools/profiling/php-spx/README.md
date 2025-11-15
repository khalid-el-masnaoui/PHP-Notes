
# PHP-SPX

SPX is a profiling extension for PHP that allows you to profile your PHP scripts and get detailed insights into their performance. It differentiates itself from other similar extensions by being totally free, simple to use, and capable of collecting a wide range of metrics. With SPX, you can easily profile your scripts by setting an environment variable or using a web UI, without the need for manually instrumenting your code or using a dedicated browser extension.


```
░█████████  ░██     ░██ ░█████████            ░██████   ░█████████  ░██    ░██ 
░██     ░██ ░██     ░██ ░██     ░██          ░██   ░██  ░██     ░██  ░██  ░██  
░██     ░██ ░██     ░██ ░██     ░██         ░██         ░██     ░██   ░██░██   
░█████████  ░██████████ ░█████████  ░██████  ░████████  ░█████████     ░███    
░██         ░██     ░██ ░██                         ░██ ░██           ░██░██   
░██         ░██     ░██ ░██                  ░██   ░██  ░██          ░██  ░██  
░██         ░██     ░██ ░██                   ░██████   ░██         ░██    ░██                                                                     
```


## Key Features

1. Simple, Self-Hosted Profiling
	- **Zero-Dependency:** No external SaaS service or browser extension required.
	- **Easy Activation:** Can be activated via environment variables (CLI) or a simple toggle in the built-in web UI.
	- **Self-Hosted:** Keeps all profiling data within your own infrastructure, ensuring no sensitive data leaks.
	
2. Powerful Built-in Web UI 
	- **Interactive Visualizations:** Provides a comprehensive UI with support for **Flamegraphs**, **Timelines**, and **Flat Profiles** to identify bottlenecks.
	- **Timeline Analysis:** Allows visualizing call stacks over time, handling up to millions of function calls.
	- **Live Profiling:** Supports live profiling for CLI scripts.
	
3. Detailed Performance Metrics
	- **Multi-Metric Support:** Collects 22+ metrics, including Wall Time, CPU Time, and memory usage.
	- **Resource Tracking:** Tracks Zend Engine memory allocations, free counts, I/O operations (reads/writes), and garbage collector activity.
	- **Context Preservation:** Unlike Xhprof, PHPSPX collects data without losing context, allowing for accurate Flamegraphs, rather than just aggregating by caller/callee.
    
4. Compatibility and Flexibility
	- **Environment Support:** Works with both PHP-FPM (web) and CLI scripts.
	- **Low Overhead:** Designed to have minimal impact on performance.
	- **Production Safety:** While primarily used in development, it can be used for debugging production, provided that access to the web UI is secured via its built-in IP whitelist/key mechanism.
	- **AI Integration:** A new [MCP Server](https://packagist.org/packages/codemonkey/spx-mcp-server) allows using AI to analyze SPX profiles to automatically find slow functions, memory leaks, and N+1 queries.

## Creating and analyzing profiles in web context

 You can use any PHP server (such as the built-in one, or Nginx, or ...) to start the PHP-SPX UI. Simply go to http://your-server-url/?SPX_KEY=dev&SPY_UI_URI=/ to open the web UI:

<p float="left" align="middle">
  <img src="./../../../images/spx1.png" width = "40%" />
</p>

Now, you can enable profiling for your browser session by switching the "Enabled" toggle (and you can configure lots of other things as well):


<p float="left" align="middle">
  <img src="./../../../images/spx2.png" width = "40%" />
</p>

After you have executed the web requests you want to profile in your application, you see the list at the bottom of the Profiler UI.


### The Profile Analyzer

When you select one request flow, you get the profile Analyzer UI which looks like the following screenshot.

At the top, you get the timeline sequence of all method calls, at the bottom left a summary table sorted by metrics, and at the bottom right a flame graph for the selected time frame.

**Note:** Make sure to get acquainted with the Analyzer UI, as it is really powerful.

<p float="left" align="middle">
  <img src="./../../../images/spx3.png" width = "40%" />
</p>

## Creating and analyzing profiles in CLI

You can also analyze CLI requests, by setting **SPX_ENABLED=1**, and optionally, for a live-refreshing mode, set additionally **SPX_FP_LIVE=1**. Then, after the CLI execution, you directly get a profile printed:

```php
SPX_ENABLED=1 SPX_FP_LIVE=1 php your_script.php
```

**Note** : You can use **`SPX_FP_URI`** with **SPX_FP_LIVE** for setting the URL to profile.

<p float="left" align="middle">
  <img src="./../../../images/spx4.png" width = "40%" />
</p>

By setting **SPX_REPORT=full**, the report will appear in the web UI and can be analyzed in detail:

```php
SPX_ENABLED=1 **SPX_REPORT=full php your_script.php
```



## Configurations

### Enable PHP-SPX Profiling 

To enable PHP SPX within your code scripts, you can use built-in functions to manually control the profiling range or configure it globally through settings. 

#### Manual Profiling in PHP Scripts

If you want to profile only a specific section of your code, use the following functions:



```php
// Start profiling manually
spx_profiler_start();

// Your code to profile goes here
perform_heavy_task();

// Stop profiling manually
spx_profiler_stop();
```

- **Automatic Shut-down**: You can also ensure profiling stops when the script finishes by using a [shutdown function](https://github.com/Automattic/wpenv-with-spx):
    
    ```php
    spx_profiler_start();
    register_shutdown_function('spx_profiler_stop');
    ```

#### Global and Automatic Activation

Instead of modifying your script code, you can enable SPX through environment variables or configuration files, which is often easier for debugging entire requests.

- **Command Line (CLI)**: Prefix your command with the `SPX_ENABLED` environment variable:

    ```bash
    SPX_ENABLED=1 php your_script.php
    ```
    
- **Web Request**: Access your application with the SPX Web UI parameters to enable profiling for that specific browser session:  
    `http://localhost/?SPX_KEY=dev&SPX_UI_URI=/`  
    Once the control panel opens, you can toggle **"Enabled"** and **"Automatic start"** to profile subsequent page reloads.
- **INI Configuration**: To profile _all_ incoming requests globally, set this in your `php.ini` or a dedicated `spx.ini`

    ```bash
    spx.http_profiling_enabled = 1
    ```
    
**Note:** Use this cautiously on high-traffic environments as it can quickly fill up storage with report data.
### Configure the Sampling Period (Profiling Rate)

The sampling period is controlled by the `SPX_SAMPLING_PERIOD` parameter. You can set this via the [PHP `putenv()` function](https://www.php.net/manual/en/function.putenv.php) or by setting it in your web server/shell environment.

Common sampling period values (in microseconds):

- **`500`** (500us): A balanced default for many scripts.
- **`1000`** (1ms): Lower overhead for very long-running processes.
- **`2000`** (2ms) or higher for massive datasets.
    

If you want to profile a specific part of your code (like a loop in a daemon) with sampling enabled, use `spx_profiler_start()` and `spx_profiler_stop()`.


```php
// 1. Configure sampling parameters via environment variables
putenv("SPX_ENABLED=1");
putenv("SPX_REPORT=full");
putenv("SPX_SAMPLING_PERIOD=500"); // Set sampling to 500 microseconds
putenv("SPX_AUTO_START=0");        // Disable auto-start to control via code

// 2. Instrument the specific code block
spx_profiler_start();

try {
    // Your intensive code here
    for ($i = 0; $i < 100000; $i++) {
        compute_something();
    }
} finally {
    // 3. Stop profiling and generate the report
    spx_profiler_stop();
}
```


Key Parameters for Sampling:

When configuring through code via `putenv()` or `ini_set()`, keep these settings in mind:

- **`SPX_SAMPLING_PERIOD`**: The interval (in microseconds) at which the call stack is captured. Setting this to `0` disables sampling and uses standard tracing.
- **`SPX_AUTO_START`**: Set to `0` if you want to use `spx_profiler_start()` to precisely target a code segment.
- **`SPX_REPORT`**: Usually set to `full` to ensure a detailed report is saved to the data directory for the PHP-SPX Web UI.
- -**`SPX_REPORT_DIR`** (Default: `/tmp`): Defines the directory where SPX will store generated report files.


## Profiling ONLY Specific Routes

### Query-based

Disable auto profiling:

```ini
spx.auto_start=0
```

Then trigger profiling only when needed:

```bash
http://localhost:8080/api/users?SPX_KEY=dev&SPX_PROFILE=1
```


### Route-based logic in PHP

Inside `index.php` (or your front controller):  SPX activates automatically for selected routes.

```php
$profileRoutes = [
	'/api/users',
	'/api/orders'
];

$requestUri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

if (in_array($requestUri, $profileRoutes)) 
{
    $_GET['SPX_KEY'] = 'dev';
    $_GET['SPX_PROFILE'] = 1;
}
```


### Header-based profiling

This avoids polluting URLs and works great with APIs.

### Update PHP logic:

```php
$profileRoutes = [
	'/api/users',
	'/api/orders'
];

$requestUri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$enableProfiling = in_array($requestUri, $profileRoutes) && isset($_SERVER['HTTP_X_PROFILE']) && $_SERVER['HTTP_X_PROFILE'] === '1';

if ($enableProfiling) 
{
	$_GET['SPX_KEY'] = 'dev';
	$_GET['SPX_PROFILE'] = 1;
}
```

### Trigger with curl:

```bash
curl -H "X-Profile: 1" http://localhost:8080/api/users
```


### Helper Scripts

Create a `scripts/` folder:

```bash
scripts/
├── profile.sh
├── open-spx.sh
```


1. `scripts/profile.sh`

```bash
#!/bin/bash

ROUTE=$1

if [ -z "$ROUTE" ]; then
  echo "Usage: ./scripts/profile.sh /api/users"
  exit 1
fi

echo "Profiling route: $ROUTE"

curl -H "X-Profile: 1" "http://localhost:8080$ROUTE" > /dev/null

echo "Done. Open SPX UI:"
echo "http://localhost:8080/?SPX_KEY=dev&SPX_UI=1"
```


2. `scripts/open-spx.sh`

```bash
#!/bin/bash

xdg-open "http://localhost:8080/?SPX_KEY=dev&SPX_UI=1" 2>/dev/null || \
open "http://localhost:8080/?SPX_KEY=dev&SPX_UI=1"
```

**Note**: You can pair it with other http benchmarking tools like **wrk** to profile realistic traffic

```bash
wrk -H "X-Profile: 1" http://localhost:8080/api/users
```

### k6 + SPX Setup

This is the `k6/script.js`

```js
import http from 'k6/http';
import { sleep } from 'k6';

export let options = {
  vus: 10,
  duration: '20s',
};

const enableProfiling = __ENV.PROFILE === "1";

export default function () {

  // Normal traffic (no profiling)
  http.get('http://localhost:8080/api/users');

  // Sampled profiling traffic (only 1%)
if (enableProfiling && Math.random() < 0.01) {
    http.get('http://localhost:8080/api/users', {
      headers: {
        'X-Profile': '1'
      }
    });
  }

  sleep(1);
}
```

k6 run k6/script.js

```bash
k6 run --env PROFILE=1 k6/script.js
```

- 99% requests → fast, no overhead
- 1% requests → profiled
- You get **real-world flame graphs under load**


## Profile ONLY Slow Requests (> X ms)

1. Measure request time
2. If it exceeds threshold → trigger SPX
3. Restart request with profiling enabled

### Implementation (Front Controller)

```php

$thresholdMs = 200; // profile if > 200ms
$start = microtime(true);

// ---- your app bootstrap ----
// require 'vendor/autoload.php';
// run framework / router here

register_shutdown_function(function () use ($start, $thresholdMs) {

    $durationMs = (microtime(true) - $start) * 1000;
	
    if ($durationMs > $thresholdMs && !isset($_GET['SPX_PROFILE'])) {

        // Avoid infinite loop
        if (isset($_SERVER['HTTP_X_SPX_RETRY'])) {
            return;
        }

        $url = $_SERVER['REQUEST_URI'];
        $separator = strpos($url, '?') !== false ? '&' : '?';

        $redirectUrl = $url . $separator . 'SPX_KEY=dev&SPX_PROFILE=1';

        header('X-SPX-Retry: 1');
        header('Location: ' . $redirectUrl);
    }
});
```

 Important Notes
 
- First request → normal
- If slow → redirected → profiled
- Adds 1 extra request only for slow endpoints

### Header-based retry

Avoid URL pollution:

```php
if ($durationMs > $thresholdMs && empty($_SERVER['HTTP_X_PROFILE'])) {

    header('Location: ' . $_SERVER['REQUEST_URI']);
    header('X-Profile: 1');
}
```

Paired with the above header logic activates SPX.

### Profile ONLY Slow + Sampled

Combine both strategies:

```php
$shouldSample = mt_rand(1, 100) === 1; // 1%  
  
if ($durationMs > 200 && $shouldSample) {  
	$_GET['SPX_KEY'] = 'dev';  
	$_GET['SPX_PROFILE'] = 1;  
}
```


## Makefile (Automation)

Create `Makefile` in root:

```bash
.PHONY: up down build logs shell profile spx

up:
	docker-compose up -d

build:
	docker-compose up --build -d

down:
	docker-compose down

logs:
	docker-compose logs -f

shell:
	docker exec -it php sh

profile:
	@if [ -z "$(route)" ]; then \
		echo "Usage: make profile route=/api/users"; \
	else \
		./scripts/profile.sh $(route); \
	fi

spx:
	./scripts/open-spx.sh
	
k6:  
	k6 run k6/script.js  
  
k6-profile:  
	k6 run --env PROFILE=1 k6/script.js
```


 Usage Examples

1. Start stack

```bash
make up
```

2. Profile a route

```bash
make profile route=/api/users
```

3. Open SPX UI

```bash
make spx
```


**Recommended:** 

Disable auto start:

```
spx.auto_start=0
```

And use:

- Header trigger
- Sampling
- Slow detection


### Automatic Slow Endpoint Detection

We will :
- Runs load tests
- Detects slow endpoints automatically
- Produces a **report (p95, avg, errors)**
- Optionally **fails** if thresholds are exceeded
-  Correlates with SPX profiling
