# PHP-STREAM

Streams are a powerful feature in PHP that allows developers to read and write data from a variety of sources, including files, sockets, and HTTP requests. The PHP Streams API provides a uniform way to access and manipulate these different types of streams.

## Table Of Contents

- **[PHP-STREAM](#php-stream-1)**
   * **[Stream Basics](#stream-basics)**
   * **[PHP Streams API](#php-streams-api)**
   * **[Stream Types](#stream-types)**
      + **[File & HTTP Streams](#file-http-streams)**
         - **[Reading and Writing Modes](#reading-and-writing-modes)**
         - **[Local Files](#local-files)**
         - **[HTTP Files](#http-files)**
            * **[stream_get_contents](#stream_get_contents)**
            * **[file_get_contents](#file_get_contents)**
            * **[Context Streams for Advanced HTTP Requests](#context-streams-for-advanced-http-requests)**
            * **[file_get_contents vs stream_get_contents](#file_get_contents-vs-stream_get_contents)**
         - **[Compressed Files](#compressed-files)**
            * **[Compression Wrappers](#compression-wrappers)**
            * **[Compression Filters](#compression-filters)**
         - **[Streaming Large Files](#streaming-large-files)**
      + **[Socket Streams](#socket-streams)**
      + **[Memory Streams](#memory-streams)**
         - **[php://memory](#phpmemory)**
         - **[php://temp](#phptemp)**
      + **[Other PHP built-in streams wrappers](#other-php-built-in-streams-wrappers)**
         - **[php://stdin](#phpstdin)**
         - **[php://stdout](#phpstdout)**
         - **[php://stderr](#phpstderr)**
         - **[php://input](#phpinput)**
         - **[php://output](#phpoutput)**
      + **[Custom Stream Wrappers](#custom-stream-wrappers)**
         - **[Overview](#overview)**
         - **[Custom Stream Wrappers](#custom-stream-wrappers-1)**
            * **[Example-1 : Memory Logger Wrapper](#example-1-memory-logger-wrapper)**
            * **[Example-2 : Secure File Wrapper ](#example-2-secure-file-wrapper)**
            * **[Example 3 — Encrypted Stream Wrapper](#example-3-encrypted-stream-wrapper)**
            * **[Example-4 : API Stream Wrapper](#example-4-api-stream-wrapper)**
            * **[Example-5 : General Memory Stream Wrapper](#example-5-general-memory-stream-wrapper)**
   * **[Other Concepts](#other-concepts)**
      + **[Stream Filters](#stream-filters)**
         - **[Overview](#overview-1)**
         - **[Customer Stream Filters](#customer-stream-filters)**
      + **[Stream Contexts](#stream-contexts)**
      + **[Stream Metadata](#stream-metadata)**

# PHP-STREAM
****
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

2. Example-2

```php
$data = array('key1' => 'value1', 'key2' => 'value2');
$options = array(
    'http' => array(
        'header'  => "Content-type: application/x-www-form-urlencoded\r\n",
        'method'  => 'POST',
        'content' => http_build_query($data)
    )
);
$context  = stream_context_create($options);
$result = file_get_contents('https://example.com/api/post_data', false, $context);

if ($result !== false) {
    echo $result;
} else {
    echo "Error sending POST request.";
}
```

##### file_get_contents vs stream_get_contents

- `file_get_contents(string $filename, ...)`: 
    
    This function is designed to read the entire contents of a specified file or URL directly into a string. It handles opening, reading, and closing the resource internally. It is often preferred for its simplicity and performance when you need to read the whole content of a file or a remote resource in one go.
    
- `stream_get_contents(resource $handle, ...)`: 
    
    This function operates on an already open stream resource (e.g., a file handle opened with `fopen()`, a socket connection, or a stream filter). It reads the remaining contents of that stream into a string, optionally up to a specified `length` and starting from a given `offset`. This function is suitable when you need more control over the stream, such as reading only a portion of it, or when working with non-file-based streams.

#### Compressed Files

PHP provides several mechanisms for working with compressed files using streams, enabling both reading from and writing to compressed data. These mechanisms include compression wrappers and stream filters.

##### Compression Wrappers

PHP offers built-in stream wrappers that allow direct interaction with compressed files as if they were regular files. The `compress.zlib://` wrapper is recommended for gzip-compressed files.

1. Example-1

- This example writes to a gzip-compressed file using the `compress.zlib` wrapper, a practical approach for storing logs or data efficiently. The file `data.gz` is opened in binary write mode (`"wb"`), compressing data as it's written.

- If the stream opens, `fwrite` adds a string, which is automatically compressed, and `fclose` finalizes the file. The result is a smaller file than plain text, ideal for backups or transfers. This leverages streams for built-in compression without external tools.

```php
$archive = fopen("compress.zlib://data.gz", "wb");

if ($archive) {
    fwrite($archive, "Sensitive data: User IDs and emails\n");
    fclose($archive);
    echo "Data compressed and saved.\n";
} else {
    echo "Failed to open compressed stream.\n";
}
```

2. Example-2

```php
// Writing to a compressed file
$data = 'This is some data to be compressed.';
$fp_write = fopen('compress.zlib://output.gz', 'wb');
fwrite($fp_write, $data);
fclose($fp_write);

// Reading from a compressed file
$fp_read = fopen('compress.zlib://output.gz', 'rb');
$decompressed_data = stream_get_contents($fp_read);
fclose($fp_read);

echo $decompressed_data; // Outputs: This is some data to be compressed
```

##### Compression Filters

Stream filters provide a more flexible way to apply compression or decompression to any stream resource, including network streams. The `zlib.inflate` and `zlib.deflate` filters are used for gzip compression and decompression.

```php
// Decompressing a gzipped stream (e.g., from a network request)
$stream = fopen('https://example.com/path/to/file.gz', 'rb');
stream_filter_append($stream, 'zlib.inflate', STREAM_FILTER_READ);

$decompressed_content = stream_get_contents($stream);
fclose($stream);

// Compressing data and writing to a file
$stream = fopen('output_filtered.gz', 'wb');
stream_filter_append($stream, 'zlib.deflate', STREAM_FILTER_WRITE, ['level' => 9]); // Max compression
fwrite($stream, 'This data will be compressed by the filter.');
fclose($stream);
```


#### Streaming Large Files

Streams efficiently handle large files by reading or writing in chunks.

- This example copies a large video file (`large_video.mp4`) to a new file, a common task in media processing. Both source and destination are opened in binary mode (`"rb"` and `"wb"`) to preserve data integrity.

- The `while (!feof($source))` loop reads 8KB chunks with `fread`, writing each to the destination stream. This avoids loading the entire file into memory, making it efficient for gigabyte-sized files. After completion, both streams are closed, and success is confirmed.

```php
$source = fopen("large_video.mp4", "rb");
$dest = fopen("video_copy.mp4", "wb");

if ($source && $dest) {

    while (!feof($source)) {
        $chunk = fread($source, 8192); // 8KB chunks
        fwrite($dest, $chunk);
    }
    fclose($source);
    fclose($dest);
    echo "Video file copied successfully.\n";
} else {
    echo "Failed to open files.\n";
}
```

### Socket Streams

PHP streams provide a generalized interface for I/O operations, including network communication. When dealing with sockets, you can use stream-based functions to establish and manage connections.

Streams can handle socket communication for real-time applications.

- `stream_socket_client()`: Initiates a client-side connection to a specified address and port using a stream. It can handle various transports like TCP, UDP, SSL, and TLS.

```php
 $socket = stream_socket_client("tcp://localhost:8000", $errno, $errstr, 30);
    if (!$socket) {
        echo "$errstr ($errno)\n";
    } else {
        fwrite($socket, "Hello Server!");
        echo fread($socket, 1024);
        fclose($socket);
    }
```

- `stream_socket_server()`: Creates a server-side socket bound to a specified address and port, ready to accept incoming connections.

```php
    $server = stream_socket_server("tcp://0.0.0.0:8000", $errno, $errstr);
    if (!$server) {
        echo "$errstr ($errno)\n";
    } else {
        while ($conn = stream_socket_accept($server, -1)) {
            fwrite($conn, 'Hello Client!');
            fclose($conn);
        }
        fclose($server);
    }
```

- `stream_socket_accept()`: Accepts an incoming connection on a server socket created with `stream_socket_server()`.
- `stream_socket_pair()`: Creates a pair of connected, indistinguishable socket streams, useful for Inter-Process Communication (IPC).
- `stream_set_blocking()`: Sets the blocking mode of a stream, allowing for non-blocking operations.
- `stream_select()`: Monitors multiple streams for readability, writability, or exceptional conditions, enabling asynchronous I/O.
- `stream_socket_enable_crypto()`: Enables or disables encryption (SSL/TLS) on a stream.

**Example**

- This example connects to a local TCP server on port 8080, simulating a simple client in a networked application (e.g., a status check). The `stream_socket_client` function establishes the socket stream, with a 30-second timeout.

- If successful, an HTTP GET request is sent via `fwrite`, and `stream_get_contents` reads the response (assume the server replies with a status). The stream is closed afterward. This demonstrates streams in real-time communication, a key feature for chat or monitoring systems.
```php

$socket = stream_socket_client("tcp://localhost:8080", $errno, $errstr, 30);

if ($socket) {

    fwrite($socket, "GET /status HTTP/1.1\r\nHost: localhost\r\n\r\n");
    $response = stream_get_contents($socket);
    echo "Server response: $response\n";
    fclose($socket);
} else {
    echo "Failed to connect: $errstr ($errno)\n";
}
```

**Note**: While the "sockets" extension also provides functions for socket programming (e.g., `socket_create`, `socket_connect`), the stream-based approach is often favored for its generality and ease of use in many common scenarios.

### Memory Streams

PHP memory streams, specifically `php://memory` and `php://temp`, provide a way to handle data in memory as if it were a file. This is useful for temporary storage and manipulation of data without the overhead of writing to and reading from the file system.

#### php://memory

- This stream stores data entirely in RAM.
- It is suitable for relatively small amounts of data that can comfortably fit within the available memory limit of the PHP script.
- Data written to `php://memory` is lost when the script finishes execution or when the stream resource is closed.

```php
// Open memory stream for reading and writing.
$memoryStream = fopen('php://memory', 'rw+');

// Write to the stream.
$text = 'sometext' . time();
fwrite($memoryStream, $text);


// Rewind the stream back to the beginning.
rewind($memoryStream);

// Read the data from the stream.
while (false !== ($line = fgets($memoryStream))) {
    echo $line;
}
```


```php
$fp = fopen('php://memory', 'r+');
fwrite($fp, 'This is some data.');
fseek($fp, 0); // Rewind to the beginning
$data = fread($fp, 1024);
fclose($fp);
echo $data; // Output: This is some data.
```

#### php://temp

- This stream also starts by storing data in RAM.
- If the amount of data exceeds a certain threshold (typically 2MB, but configurable), PHP automatically spills the data to a temporary file on disk.
- This makes `php://temp` suitable for handling larger datasets where the exact size is unknown or could potentially exceed the memory limit.
- Like `php://memory`, data written to `php://temp` is temporary and is deleted when the script ends or the stream is closed.

The location of this file depends on your system, but you can find this information out by using the `sys_get_temp_dir()` function. This file will be automatically deleted when the PHP script ends.

```php
// Write to memory, or a file if more than 1028 bytes is written.
$tempStream = fopen('php://temp/maxmemory:1028', 'rw+');
```


### Other PHP built-in streams wrappers
#### php://stdin

- **Read-only:**  It can only be used to read data, not to write.
    
- **CLI-focused:**  It is primarily intended for use in PHP scripts executed via the command line, as it directly accesses the standard input stream (e.g., keyboard input, piped output from another command).
    
- **Duplicate file descriptor:**  When `php://stdin` is opened, it references a duplicate of the original standard input file descriptor. Closing the stream opened with `php://stdin` only closes this duplicate, leaving the original `STDIN` stream unaffected.
    
- Alternative to `STDIN` constant:  While `php://stdin` can be used with `fopen()`, it is generally recommended to use the `STDIN` constant directly for convenience and clarity when working with standard input in CLI scripts.

```php
// cat somelog.log | php stream.php

$stdin = fopen('php://stdin', 'r');
while (false !== ($line = fgets($stdin))) {
    echo $line;
}
```

```php
echo "Please enter your age: ";
$age = trim(fgets(STDIN)); // Read a line from standard input using the STDIN constant

echo "You are " . $age . " years old.\n";
```

#### php://stdout

- **Direct access:**  `php://stdout` allows writing directly to the same output stream that `echo` or `print` statements use.
    
- **Write-only:**  It can only be used for writing data, not for reading.
    
- **File descriptor duplication:**  When opened with `fopen('php://stdout', 'w')`, it references a duplicate of the original standard output file descriptor. Closing this opened stream only closes the copy, leaving the actual `STDOUT` stream unaffected.
    
- **Alternative to constants:**  For convenience and clarity, it is generally recommended to use the `STDOUT` constant instead of manually opening `php://stdout` with `fopen`. Both achieve the same result.

```php
// Using fopen with php://stdout
$stdout_stream = fopen('php://stdout', 'w');
fwrite($stdout_stream, "This is written to stdout using fopen.\n");
fclose($stdout_stream);

// Using the STDOUT constant (recommended)
fwrite(STDOUT, "This is written to stdout using the STDOUT constant.\n");

// Using echo or print (most common)
echo "This is written to stdout using echo.\n";
print "This is also written to stdout using print.\n";
```

#### php://stderr

- **Write-only:**  You can only write data to `php://stderr`; attempting to read from it will result in an empty stream or a hanging script.
    
- **Error output:**  It is the designated channel for error messages and similar diagnostic information. In a command-line environment, output to `php://stderr` typically goes to the console, while in a web server environment, it might be redirected to server error logs.
    
- Constant `STDERR`:  PHP provides a predefined constant `STDERR` that is a resource representing the standard error stream. It is generally recommended to use this constant directly instead of explicitly opening `fopen('php://stderr', 'w')`.

```php
// Writing to standard error using the STDERR constant
fwrite(STDERR, "This is an error message sent to standard error.\n");

// Explicitly opening php://stderr (less common but possible)
$stderr_stream = fopen('php://stderr', 'w');
if ($stderr_stream) {
    fwrite($stderr_stream, "Another error message via explicit stream.\n");
    fclose($stderr_stream);
}

```

#### php://input

- **Raw data access:** It provides the raw, unparsed data from the request body as a stream.
- **Content-Type independence:** Unlike `$_POST`, which is primarily designed for `application/x-www-form-urlencoded` and `multipart/form-data` content types, `php://input` can be used to read data from any `Content-Type`, including `application/json`, `text/xml`, or custom formats. 
- Not available with `multipart/form-data` and `enable_post_data_reading`: If the `enctype` of a POST request is `multipart/form-data` and the `enable_post_data_reading` PHP configuration option is enabled, `php://input` will not be available. In such cases, `$_POST` and `$_FILES` are used to access the data.
- **Read-only:** As a stream, you can only read from `php://input`; you cannot write to it.

```php
// curl -X POST -d "data1=thing" -d "data2=anotherthing" "http://localhost:8000/stream.php"

$input = fopen('php://input', 'r');
while (false !== ($line = fgets($input))) {
    echo $line;
}

// Outputs -> data1=thing&data2=anotherthing
```

```php
// Read the entire raw request body
$rawData = file_get_contents("php://input");

// Assuming the raw data is JSON
$data = json_decode($rawData, true);

// Process the data
if ($data) {
    echo "Received data: ";
    print_r($data);
} else {
    echo "No valid JSON data received or couldn't decode.";
}
```


#### php://output

- **Write-only:** Data can only be written to `php://output`; it cannot be read from it.
- **Accesses output buffer:** It directly interacts with PHP's internal output buffering system.
- Alternative to `echo` and `print`: While `echo` and `print` are the standard ways to output data, `php://output` offers a file-like interface for writing to the output.

```php
$handle = fopen('php://output', 'w');  
fwrite($handle, 'Hello, ');  
fwrite($handle, 'world!');  
fclose($handle);
```


When to use `php://output`:

While `echo` and `print` are generally preferred for simple output, `php://output` can be useful in scenarios where a file-like interface is required for output, such as when:

- **Working with stream functions:**  Functions designed to work with stream resources (e.g., `stream_copy_to_stream`, `stream_filter_append`) can be used with `php://output`.
    
- **Integrating with libraries:**  Libraries or components that expect a file handle for output can be provided with `php://output`.
    
- **Advanced output manipulation:**  When combined with output buffering functions (`ob_start`, `ob_flush`, etc.), `php://output` can be used for more intricate control over output.


### Custom Stream Wrappers

#### Overview

- **Stream:**  An interface that provides methods for reading from and writing to a resource. 
    
- **Wrapper:**  Additional code that tells the stream how to handle specific protocols or encodings. It essentially acts as a translator between the PHP filesystem functions and the actual data source. 
    
- **URL-style Protocols:** Wrappers are typically invoked using a `scheme://` syntax, similar to URLs, within PHP's filesystem functions..

Built-in Stream Wrappers:

PHP includes a variety of built-in wrappers for common protocols and resources:

- `file://`: Accesses local filesystem files. (This is the default and often omitted.)
- `http://` / `https://`: Accesses resources over HTTP/HTTPS.
- `ftp://` / `ftps://`: Accesses resources over FTP/FTPS.
- `php://`: Provides access to various I/O streams within PHP itself, such as `php://stdin`, `php://stdout`, `php://input`, `php://memory`, and `php://temp`.
- `data://`: Allows embedding small files directly within a script.
- `zip://`: Accesses files within ZIP archives.
- `compress.zlib://` / `compress.bzip2://`: Accesses compressed files.
- `ssh2://`: (Requires `ssh2` extension) Accesses resources over SSH.

#### Custom Stream Wrappers

- We can register our own custom stream wrappers using `stream_wrapper_register()`. 
- This involves creating a class that implements the `streamWrapper` interface, defining methods for handling operations like opening, reading, writing, seeking, and closing the stream. This allows for highly flexible and specialized data access mechanisms.

##### Example-1 : Memory Logger Wrapper

The example defines a `MemoryLogger` custom stream wrapper for in-memory logging, useful for debugging without file I/O. The wrapper stores log messages in an array, simulating a stream-like interface. It's registered as `memorylog://`.

The `stream_write` method appends data, while `stream_read` reads from the concatenated logs, tracking position. After writing an error message, `rewind` resets the position, and `fread` retrieves it. This practical wrapper shows how streams can extend beyond traditional files or networks.

```php
class MemoryLogger {
    private array $logs = [];
    private int $position = 0;

    public function stream_open(string $path, string $mode): bool {
        return true;
    }

    public function stream_write(string $data): int {
        $this->logs[] = $data;
        return strlen($data);
    }

    public function stream_read(int $count): string {
        if ($this->stream_eof()) {
            return "";
        }
        $data = implode("", $this->logs);
        $ret = substr($data, $this->position, $count);
        $this->position += strlen($ret);
        return $ret;
    }

    public function stream_eof(): bool {
        return $this->position >= strlen(implode("", $this->logs));
    }
}

stream_wrapper_register("memorylog", "MemoryLogger");

$logger = fopen("memorylog://debug", "w+");
fwrite($logger, "Error: Invalid input\n");
rewind($logger);
echo fread($logger, 1024);
fclose($logger);
```

##### Example-2 : Secure File Wrapper 

- This wrapper lets you access files through a custom scheme, so `fopen("securefile:///tmp/data.txt", "r+")` behaves like `fopen("/tmp/data.txt")`, but you can later add validation, logging, etc. (e.g., preventing access to restricted paths)

```php
class SecureFileStreamWrapper
{
    private $resource;

    public function stream_open($path, $mode, $options, &$opened_path)
    {
        // Remove the scheme (securefile://)
        $url = parse_url($path);
        $filePath = $url['path'] ?? '';

        // You could add custom security checks here
        if (strpos($filePath, '/etc') === 0) {
            trigger_error("Access denied to system directory", E_USER_WARNING);
            return false;
        }

        $this->resource = fopen($filePath, $mode);
        return $this->resource !== false;
    }

    public function stream_read($count)
    {
        return fread($this->resource, $count);
    }

    public function stream_write($data)
    {
        return fwrite($this->resource, $data);
    }

    public function stream_tell()
    {
        return ftell($this->resource);
    }

    public function stream_seek($offset, $whence)
    {
        return fseek($this->resource, $offset, $whence) === 0;
    }

    public function stream_eof()
    {
        return feof($this->resource);
    }

    public function stream_close()
    {
        fclose($this->resource);
    }

    public function stream_stat()
    {
        return fstat($this->resource);
    }
}

// Register and test it
stream_wrapper_register("securefile", "SecureFileStreamWrapper");

$fp = fopen("securefile:///tmp/demo.txt", "w+");
fwrite($fp, "This is written securely.\n");
rewind($fp);
echo fread($fp, 1024);
fclose($fp);

```

##### Example 3 — Encrypted Stream Wrapper

- This one encrypts all data before writing it to a real file, and decrypts it when reading.

```php

class EncryptedStreamWrapper
{
    private $resource;
    private $key = 'mysecretkey12345'; // Example key — use env vars in production

    public function stream_open($path, $mode, $options, &$opened_path)
    {
        $url = parse_url($path);
        $filePath = $url['path'] ?? '';
        $this->resource = fopen($filePath, $mode);
        return $this->resource !== false;
    }

    public function stream_read($count)
    {
        $encrypted = fread($this->resource, $count);
        return $this->decrypt($encrypted);
    }

    public function stream_write($data)
    {
        $encrypted = $this->encrypt($data);
        return fwrite($this->resource, $encrypted);
    }

    public function stream_close()
    {
        fclose($this->resource);
    }

    private function encrypt($data)
    {
        return openssl_encrypt($data, 'AES-128-CTR', $this->key, 0, '1234567891011121');
    }

    private function decrypt($data)
    {
        return openssl_decrypt($data, 'AES-128-CTR', $this->key, 0, '1234567891011121');
    }
}

// Register
stream_wrapper_register("enc", "EncryptedStreamWrapper");

// Example usage
$fp = fopen("enc:///tmp/encrypted.txt", "w+");
fwrite($fp, "Top secret message!");
fclose($fp);

// Read it back
$fp = fopen("enc:///tmp/encrypted.txt", "r");
echo fread($fp, 1024); // Output: Top secret message!
fclose($fp);

```

##### Example-4 : API Stream Wrapper

```php
class ApiStreamWrapper
{
    private $position;
    private $data;
    private $mode;
    private $urlBase = 'https://jsonplaceholder.typicode.com'; // Example API

    public function stream_open($path, $mode, $options, &$opened_path)
    {
        $this->mode = $mode;
        $this->position = 0;
        $this->data = '';

        $url = parse_url($path);
        $endpoint = $url['host'] . ($url['path'] ?? '');
        $apiUrl = $this->urlBase . '/' . ltrim($endpoint, '/');

        if (strpbrk($mode, 'r')) {
            // Read mode → GET request
            $this->data = $this->httpGet($apiUrl);
        } elseif (strpbrk($mode, 'w')) {
            // Write mode → prepare for later POST/PUT
            $this->data = '';
        }

        return true;
    }

    public function stream_read($count)
    {
        $chunk = substr($this->data, $this->position, $count);
        $this->position += strlen($chunk);
        return $chunk;
    }

    public function stream_write($data)
    {
        $this->data .= $data;
        return strlen($data);
    }

    public function stream_eof()
    {
        return $this->position >= strlen($this->data);
    }

    public function stream_close()
    {
        if (strpbrk($this->mode, 'w')) {
            // When closing, send the data via POST request
            $endpoint = parse_url($this->path)['host'] . (parse_url($this->path)['path'] ?? '');
            $apiUrl = $this->urlBase . '/' . ltrim($endpoint, '/');
            $this->httpPost($apiUrl, $this->data);
        }
    }

    // --- Helpers ---

    private function httpGet($url)
    {
        $context = stream_context_create(['http' => ['method' => 'GET']]);
        return @file_get_contents($url, false, $context) ?: '';
    }

    private function httpPost($url, $data)
    {
        $context = stream_context_create([
            'http' => [
                'method'  => 'POST',
                'header'  => "Content-Type: application/json\r\n",
                'content' => $data
            ]
        ]);
        return @file_get_contents($url, false, $context);
    }
}

// Register and use it
stream_wrapper_register("api", "ApiStreamWrapper");

// Example: reading data
$fp = fopen("api://posts/1", "r");
echo fread($fp, 1024);
fclose($fp);

// Example: writing (sending POST request)
$fp = fopen("api://posts", "w");
fwrite($fp, json_encode(['title' => 'Hello', 'body' => 'Stream wrappers are cool!', 'userId' => 1]));
fclose($fp);

```

##### Example-5 : General Memory Stream Wrapper

```php
class MemoryStreamWrapper
{
    private $position;
    private $data;

    /**
     * Called when a stream is opened, e.g. fopen("memory://something", "r")
     */
    public function stream_open($path, $mode, $options, &$opened_path)
    {
        $this->position = 0;
        $this->data = '';

        // You can parse the path if you want custom behavior, e.g. memory://file1
        // $url = parse_url($path);
        // $fileName = $url['host'] ?? 'default';

        return true;
    }

    /**
     * Called when reading from the stream
     */
    public function stream_read($count)
    {
        $chunk = substr($this->data, $this->position, $count);
        $this->position += strlen($chunk);
        return $chunk;
    }

    /**
     * Called when writing to the stream
     */
    public function stream_write($data)
    {
        $left = substr($this->data, 0, $this->position);
        $right = substr($this->data, $this->position + strlen($data));
        $this->data = $left . $data . $right;
        $this->position += strlen($data);
        return strlen($data);
    }

    /**
     * Called when checking end-of-file
     */
    public function stream_eof()
    {
        return $this->position >= strlen($this->data);
    }

    /**
     * Called to move the internal pointer
     */
    public function stream_seek($offset, $whence = SEEK_SET)
    {
        switch ($whence) {
            case SEEK_SET:
                if ($offset < strlen($this->data) && $offset >= 0) {
                    $this->position = $offset;
                    return true;
                }
                return false;

            case SEEK_CUR:
                if ($offset >= 0) {
                    $this->position += $offset;
                    return true;
                }
                return false;

            case SEEK_END:
                if (strlen($this->data) + $offset >= 0) {
                    $this->position = strlen($this->data) + $offset;
                    return true;
                }
                return false;

            default:
                return false;
        }
    }

    /**
     * Optional: report stream statistics
     */
    public function stream_stat()
    {
        return [];
    }
}

// Register your custom wrapper
stream_wrapper_register("memory", "MemoryStreamWrapper");

// Example usage
$fp = fopen("memory://example", "w+");
fwrite($fp, "Hello, custom stream!");
rewind($fp);

echo fread($fp, 1024);  // Output: Hello, custom stream!

fclose($fp);

```

## Other Concepts

### Stream Filters

#### Overview

PHP stream filters provide a mechanism to process data as it is being read from or written to a stream. This allows for on-the-fly manipulation of data without needing to load the entire content into memory first.


- **Stream Filters:**  These are small programs that modify data flowing through a stream. They can be applied to various types of streams, including files, network connections, and standard I/O.
    
- `php://filter` Wrapper:  This is a meta-wrapper specifically designed to apply filters to streams during their opening. It allows you to specify one or more filters to be applied to a resource before its content is accessed, particularly useful with functions like `file_get_contents()` or `readfile()`.
    
- **Built-in Filters:** 
    
    PHP provides several built-in filters, including:
    
    - **String Filters:** `string.rot13`, `string.toupper`, `string.tolower`, `string.strip_tags`
    - **Conversion Filters:** `convert.base64-encode`, `convert.base64-decode`, `convert.quoted-printable-encode`, `convert.quoted-printable-decode` 
    - **Compression Filters:** `zlib.deflate`, `zlib.inflate` (if zlib support is enabled)
    
- **Custom Filters:**  You can create your own custom stream filters by extending the `php_user_filter` class and implementing its required methods. This allows for highly specific data manipulation tailored to your application's needs.

```php
//example-1
        $filteredContent = file_get_contents('php://filter/read=string.rot13/resource=myfile.txt');


//example-2
$fp = fopen('myfile.txt', 'r');  
stream_filter_append($fp, 'string.toupper');  
$content = fread($fp, filesize('myfile.txt'));  
fclose($fp);
```


Use Cases:
- **Data Transformation:** Encoding/decoding data (e.g., Base64), compressing/decompressing data, changing character casing.
- **Security:** Sanitizing input data from untrusted sources, removing potentially harmful tags.
- **Logging:** Adding timestamps or other metadata to log entries as they are written.
- **Debugging:** Intercepting and inspecting data flow within an application.

#### Customer Stream Filters

Creating custom stream filters in PHP involves defining a class that extends `php_user_filter` and registering it with `stream_filter_register()`. This allows you to process data as it is read from or written to a stream.

```php
class MyCustomFilter extends php_user_filter {
    public $stream; // The underlying stream resource

    function onCreate() {
        // Optional: Perform initialization tasks here
        return true;
    }

    function onClose() {
        // Optional: Perform cleanup tasks here
    }

    function filter($in, $out, &$consumed, $closing) {
        while ($bucket = stream_bucket_make_writeable($in)) {
            // Modify the data in $bucket->data
            $bucket->data = strtoupper($bucket->data); // Example: Convert to uppercase
            $consumed += $bucket->datalen;
            stream_bucket_append($out, $bucket);
        }
        return PSFS_PASS_ON; // Indicates that the filter processed the data
    }
}
```

- `$in`: A resource representing the input bucket brigade.
- `$out`: A resource representing the output bucket brigade.
- `&$consumed`: A reference to a variable that should be incremented by the number of bytes consumed by the filter.
- `$closing`: A boolean indicating whether the stream is being closed.

`filter()` method return values:
- `PSFS_PASS_ON`: Indicates that the filter processed the data and wants it passed on to the next filter or the underlying stream.
- `PSFS_FEED_ME`: Indicates that the filter needs more data to process.
- `PSFS_ERR_FATAL`: Indicates a fatal error occurred in the filter.

```php
//Register the Filter
stream_filter_register("mycustomfilter", "MyCustomFilter");

//Apply the Filter to a Stream:
$fp = fopen("data.txt", "r+"); // Open a file stream  
stream_filter_append($fp, "mycustomfilter");  
  
// Now, any data read from or written to $fp will be processed by MyCustomFilter  
$data = fread($fp, 1024);  
fwrite($fp, "some data");  
  
fclose($fp);
```


### Stream Contexts

A stream context is a set of parameters and wrapper-specific options that modify or enhance the behavior of a stream.

Stream contexts allow you to configure options for streams, such as HTTP headers or SSL settings.


```php
   $context = stream_context_create([
        'http' => [
            'method' => 'POST',
            'header' => 'Content-type: application/x-www-form-urlencoded',
            'content' => 'foo=bar&baz=qux',
            'timeout' => 5, // 5-second timeout
        ],
        'ssl' => [
            'verify_peer' => false, // Disable SSL certificate verification (for testing, not recommended in production)
            'allow_self_signed' => true,
        ],
    ]);
    
    
	$result = file_get_contents('http://example.com/api', false, $context);

```


- **Customizing HTTP requests:**  Setting custom headers, changing the request method (POST, PUT, DELETE), sending request bodies, or configuring timeouts for `http://` or `https://` streams.
    
- **Controlling SSL/TLS behavior:**  Disabling SSL certificate verification for self-signed certificates (though generally not recommended for production), or specifying client certificates for authentication.
    
- **Interacting with FTP servers:**    Setting FTP transfer modes, specifying authentication credentials, or controlling directory listings.
    
- **Implementing custom stream wrappers:**  If you create your own stream wrappers, you can define and use context options and parameters specific to your wrapper's functionality.

### Stream Metadata

Stream metadata refers to information associated with a stream resource, providing details about its state and characteristics. This metadata can be retrieved using the `stream_get_meta_data()` function.

The `stream_get_meta_data()` function takes a stream resource as an argument and returns an associative array containing various pieces of information, such as:

- `timed_out`: A boolean indicating if the stream timed out during a read/write operation.
- `blocked`: A boolean indicating if the stream is in blocking mode.
- `eof`: A boolean indicating if the end-of-file has been reached.
- `unread_bytes`: The number of bytes currently in the stream's internal buffer, waiting to be read.
- `stream_type`: The type of stream (e.g., "tcp_socket", "plainfile").
- `wrapper_type`: The type of stream wrapper used (e.g., "plainfile", "http", "ftp").
- `wrapper_data`: Any wrapper-specific data, which can vary greatly depending on the wrapper. For example, with an HTTP stream, this might contain header information.
- `mode`: The mode in which the stream was opened (e.g., "r", "w", "a").
- `seekable`: A boolean indicating if the stream is seekable.
- `uri`: The URI or path used to open the stream.

```php
$fp = fopen('php://temp', 'r+'); // Open a temporary in-memory stream
fwrite($fp, 'Hello, world!');
fseek($fp, 0);

$meta = stream_get_meta_data($fp);

echo "Stream Type: " . $meta['stream_type'] . "\n";
echo "Wrapper Type: " . $meta['wrapper_type'] . "\n";
echo "Mode: " . $meta['mode'] . "\n";
echo "Seekable: " . ($meta['seekable'] ? 'Yes' : 'No') . "\n";
echo "URI: " . $meta['uri'] . "\n";

fclose($fp);
```