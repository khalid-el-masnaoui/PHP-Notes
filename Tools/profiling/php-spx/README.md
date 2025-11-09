
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
    