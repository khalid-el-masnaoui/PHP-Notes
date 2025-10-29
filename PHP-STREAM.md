Streams are a powerful feature in PHP that allows developers to read and write data from a variety of sources, including files, sockets, and HTTP requests. The PHP Streams API provides a uniform way to access and manipulate these different types of streams.


# PHP-STREAM

## Stream Basics

A stream is referenced as `<scheme>://<target>`. `<scheme>` is the name of the wrapper, and `<target>` will vary depending on the wrapper’s syntax.

The default wrapper is `file://` which means we use a stream every time we access the filesystem. We can either write `readfile('/path/to/somefile.txt')` for example or `readfile('file:///path/to/somefile.txt')` and obtain the same result. If we instead use `readfile('http://google.com/')` then we’re telling PHP to use the HTTP stream wrapper.

- **Abstraction and Uniformity:**  Streams abstract away the underlying details of data handling. Whether you're reading from a local file, a remote URL, or a compressed archive, you use the same set of functions (e.g., `fopen()`, `fread()`, `fwrite()`, `fclose()`).
    
- **Streamable Behavior:**  A stream is essentially a resource object that can be read from or written to in a linear fashion. Many streams also support seeking to arbitrary positions within the data using `fseek()`.
    
- **Wrappers:**  Each stream is associated with a "wrapper," which is responsible for handling the specific protocol or encoding of the data source. For example:
    - `file://` for local files.
    - `http://` or `https://` for web resources.
    - `ftp://` for FTP connections.
    - `compress.zlib://` for compressed data.
    
