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

## Stream Types

Streams can be classified into four types based on the source of the data:

- **File Streams**: Streams that read and write data to files.
- **Memory Streams**: Streams that read and write data to memory.
- **Socket Streams**: Streams that read and write data over network sockets.
- **HTTP Streams**: Streams that read and write data from HTTP requests and responses.

### File & HTTP Streams

#### Reading and Writing Modes

| Modes  | Description                                                                                                                                                      |
| ------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **r**  | **Open a file for read only**. File pointer starts at the beginning of the file                                                                                  |
| **w**  | **Open a file for write only**. Erases the contents of the file or creates a new file if it doesn't exist. File pointer starts at the beginning of the file      |
| **a**  | **Open a file for write only**. The existing data in file is preserved. File pointer starts at the end of the file. Creates a new file if the file doesn't exist |
| **x**  | **Creates a new file for write only**. Returns FALSE and an error if file already exists                                                                         |
| **r+** | **Open a file for read/write**. File pointer starts at the beginning of the file                                                                                 |
| **w+** | **Open a file for read/write**. Erases the contents of the file or creates a new file if it doesn't exist. File pointer starts at the beginning of the file      |
| **a+** | **Open a file for read/write**. The existing data in file is preserved. File pointer starts at the end of the file. Creates a new file if the file doesn't exist |
| **x+** | **Creates a new file for read/write**. Returns FALSE and an error if file already exists                                                                         |
#### Local Files

1. Writing to file streams

```php
$logFile = fopen("app_logs.txt", "a");

if ($logFile) {

    $timestamp = date("Y-m-d H:i:s");
    fwrite($logFile, "[$timestamp] User logged in\n");
    fclose($logFile);
    echo "Log entry added.\n";
} else {
    echo "Failed to open log file.\n";
}
```


2. Reading from file streams

```php

$configFile = fopen("config.ini", "r");

if ($configFile) {

    $settings = [];

    while (($line = fgets($configFile)) !== false) {

        $trimmed = trim($line);

        if ($trimmed && strpos($trimmed, "=") !== false) {
            [$key, $value] = explode("=", $trimmed, 2);
            $settings[$key] = $value;
        }
    }

    fclose($configFile);
    print_r($settings);
} else {
    echo "Failed to open config file.\n";
}
```


#### HTTP Files

##### stream_get_contents

```php
  $handle = fopen('https://example.com/api/data', 'r');
    if ($handle) {
        $contents = stream_get_contents($handle);
        fclose($handle);
        echo $contents;
    }
```

##### file_get_contents

```php
// Ensure allow_url_fopen is enabled in php.ini for this to work
$urlContent = file_get_contents('https://example.com/api/data');
if ($urlContent !== false) {
    echo $urlContent;
} else {
    echo "Error fetching URL content. Check allow_url_fopen in php.ini.";
}
```

##### Context Streams for Advanced HTTP Requests

you can customize the HTTP request by providing a stream context created with `stream_context_create()`. This allows setting options like:

- `http` wrapper options: `method` (GET, POST, etc.), `header` (custom headers), `content` (request body for POST/PUT), `timeout`, `proxy`, and more.

1. Example-1

```php
    $options = [
        'http' => [
            'method' => 'POST',
            'header' => 'Content-type: application/json',
            'content' => json_encode(['key' => 'value']),
            'timeout' => 5, // seconds
        ],
    ];
    $context = stream_context_create($options);
    $handle = fopen('https://example.com/api/submit', 'r', false, $context);
    // ... process response ...
```
