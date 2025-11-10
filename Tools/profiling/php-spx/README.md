
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
