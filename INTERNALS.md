# PHP INTERNALS

Notes about PHP , PHP internals (code execution flow), what is and how PHP-FPM works and other PHP related concepts.

## Introduction

#### How does PHP work with HTTP-Servers?

In general HTTP servers have a very clear responsibility: provide hypermedia content using the HTTP Protocol. This means that **http servers would receive a request, fetch a string content from somewhere, and respond with this string** based on the HTTP Protocol.

PHP came to make this hypermedia content dynamic, allowing developers to provide more than simple, static `.html` files.

As a scripting language, on a scripting context, PHP isolates every execution. Meaning that it doesn't share memory or other resources among executions.

On the web context we have two different ways to execute php code. One can attach PHP to http servers using a _CGI-like connection_ OR as a _module_ to http the server. The main difference between both is that **http modules share resources with the HTTP server** while as a **CGI, php has a fresh execution on every request**.

Using it as a module used to be very popular back in the days, as the communication between the http server and code execution has less friction. Meanwhile the CGI mode would, for example, rely on network communication between http server and code execution.

With PHP-FPM  a web server like nginx or Apache can easily execute php code as if it was a CLI script. Where every request is 100% isolated from each other.

This also means that the HTTP Server can scale independently from the PHP code executor. This **enables vertical scaling**.

The way php works (with FPM) is basically: **HTTP Server ⇨ PHP-FPM (Server) ⇨ PHP**.

You can read more about [Fast-CGI Protocol](https://github.com/khalid-el-masnaoui/Nginx-Notes/blob/main/ARCHITECTURE.md#nginx-fastcgi) which PHP-FPM relies on.

#### PHP-FPM

###### Introduction

PHP-FPM is a simple and robust _FastCGI Process Manager_ for PHP (PHP FastCGI implementation). It works as a process manager, managing PHP processes and handling PHP requests separately from the web server. By doing so, it can efficiently handle multiple PHP requests concurrently, leading to a significant reduction in latency and improved overall performance.

Internally, PHP-FPM is organized as a **_master process_** managing pools of individual **_worker processes_**.

PHP-FPM's primary focus is on improving the **performance** of PHP-based applications.By maintaining separate PHP worker processes, it can handle a larger number of concurrent requests more efficiently (minimizing the overhead of process creation and destruction each time a request is received). It is also **Resource efficient** since it can control the number of active PHP processes based on the server's resources and the incoming request load. Providing a **stable and secure** environment for running PHP applications. If one PHP process encounters an error or becomes unresponsive, it won't affect other active processes. This isolation ensures that individual requests are isolated and do not impact the overall system stability.