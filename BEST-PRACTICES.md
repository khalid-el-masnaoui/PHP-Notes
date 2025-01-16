# PHP Best Practices

## Overview

This document revisits the essential security and optimized-performance configurations for PHP & PHP-FPM runtime from a practical perspective.

By following the key recommendations outlined below, you can avoid common configuration errors and prevent security vulnerabilities as well as ensuring optimized performances.



## Security 

### Get Latest PHP

New versions of PHP are released regularly with security fixes and improvements. By using the latest version, you’ll have the benefit of these fixes and improvements as well as any new features that might be helpful for your application.

### Use Up to date code dependencies and third party components

In addition to using the latest version of PHP, you should also keep your code up to date. This includes any third-party libraries or frameworks that you’re using. Outdated software is often the target of attacks because hackers know that it is more likely to have vulnerabilities that can be exploited.

### Secure your server

Your web server should be configured properly to protect your website from attacks. This includes ensuring that all unnecessary services are disabled and that file permissions are set correctly. You should also use a firewall to block unwanted traffic and an intrusion detection/prevention system (IDS/IPS) to monitor for suspicious activity.

**Note** : We discuss servers/network security in depth on my repository