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
    

PHP includes many built-in wrappers, and you can also register custom wrappers.

- **Filters:**  Stream filters allow you to process data as it flows through a stream. You can apply filters to modify data during reading or writing, such as converting text to uppercase or performing encryption/decryption. Filters can be stacked, allowing for multiple transformations.
    
- **Contexts:**  Stream contexts provide a way to configure the behavior of streams and wrappers. You can set options for timeouts, HTTP headers, authentication credentials, and other parameters specific to the wrapper being used.
    
- **Efficiency:**  Streams are particularly beneficial when dealing with large files or real-time data transfers, as they enable incremental processing of data rather than loading everything into memory at once. This helps optimize memory usage and performance.

PHP provides [some built-in wrappers](https://www.php.net/manual/en/wrappers.php), protocols, and filters. To know which wrappers are installed on our machine we can use:

```php
print_r(stream_get_transports());
print_r(stream_get_wrappers());
print_r(stream_get_filters());
```

## PHP Streams API

The PHP Streams API provides a set of functions that can be used to open, read, write, and close streams. Some of the most commonly used functions in the PHP Streams API are:

- **fopen()**: Opens a file or URL and returns a stream resource.
- **fread()**: Reads a specified number of bytes from a stream.
- **fwrite()**: Writes a string to a stream.
- **fclose()**: Closes an open stream
