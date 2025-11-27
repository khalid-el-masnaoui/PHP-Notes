
# PHP Performance Best Practices Part 2

## Overview

Optimizes PHP applications by configuring OPcache, JIT, and database connections while implementing high-performance coding patterns.

This document provides expert guidance for accelerating PHP applications, covering everything from low-level engine tuning like **OPcache** and **JIT (PHP 8.0+)** to application-level strategies such as **Redis/Memcached caching** and **PDO optimization**. It helps developers identify bottlenecks, choose faster function alternatives, **manage memory efficiently** in long-running processes, and leverage specialized **SPL data structures** to reduce resource consumption in high-traffic environments.
## Monitoring & Management

```php
// Check cache health
$status = opcache_get_status();
$hitRate = $status['opcache_statistics']['opcache_hit_rate'];  // target: >98%
$wasted = $status['memory_usage']['current_wasted_percentage'];
$full = $status['cache_full'];

// Reset cache (deploy hook)
opcache_reset();  // clears entire in-memory cache

// Invalidate single file
opcache_invalidate('/path/to/file.php', true);  // force=true ignores mtime
```

|Indicator|Healthy|Action if unhealthy|
|---|---|---|
|Hit rate|>98%|Increase `max_accelerated_files` or `memory_consumption`|
|Wasted memory|<5%|Restart PHP-FPM or increase `max_wasted_percentage`|
|`cache_full`|false|Increase `memory_consumption`|
|`oom_restarts`|0|Increase memory — OOM caused forced restarts|


## Database (PDO)

```php
// Recommended PDO configuration
$pdo = new PDO('mysql:host=localhost;dbname=app;charset=utf8mb4', $user, $pass, [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,   // throw exceptions
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,         // assoc arrays
    PDO::ATTR_EMULATE_PREPARES   => false,                    // real prepared statements
]);

// Named parameters — clearer for multiple params
$stmt = $pdo->prepare('SELECT * FROM users WHERE email = :email AND active = :active');
$stmt->execute(['email' => $email, 'active' => 1]);
$user = $stmt->fetch();

// Transactions
$pdo->beginTransaction();
try {
    $pdo->prepare('UPDATE accounts SET balance = balance - ? WHERE id = ?')->execute([$amount, $from]);
    $pdo->prepare('UPDATE accounts SET balance = balance + ? WHERE id = ?')->execute([$amount, $to]);
    $pdo->commit();
} catch (\Throwable $e) {
    $pdo->rollBack();
    throw $e;
}
```

| Rule                             | Detail                                                                    |
| -------------------------------- | ------------------------------------------------------------------------- |
| `ERRMODE_EXCEPTION`              | Always — silent failures hide bugs                                        |
| `EMULATE_PREPARES = false`       | Real server-side prepared statements — actual SQL injection protection    |
| `FETCH_ASSOC` default            | Less memory than `FETCH_BOTH` (default)                                   |
| `charset=utf8mb4` in DSN         | MySQL: full Unicode including emoji                                       |
| Named params `:name`             | Clearer than positional `?` for 3+ parameters                             |
| Transactions for multi-statement | Atomicity — all succeed or all roll back                                  |
| `fetchAll()` caution             | Loads entire result into memory — use `fetch()` in loop for large results |
## Caching (Redis / Memcached)

```php
// Redis — cache-aside pattern
$redis = new Redis();
$redis->connect('127.0.0.1', 6379);

$key = 'user:' . $userId;
$cached = $redis->get($key);
if ($cached !== false) {
    return json_decode($cached, true);
}
$data = $db->fetchUser($userId);
$redis->setex($key, 3600, json_encode($data));  // TTL 1 hour
return $data;

// Memcached
$mc = new Memcached();
$mc->addServer('127.0.0.1', 11211);
$mc->set('key', $value, 3600);
$value = $mc->get('key');
```

- **PHP Caching Layers**

| Layer             | Tool                           | When                                             |
| ----------------- | ------------------------------ | ------------------------------------------------ |
| Bytecode          | OPcache                        | Always — eliminates recompilation                |
| Application data  | Redis / Memcached              | DB query results, API responses, computed values |
| HTTP              | Reverse proxy (Varnish, Nginx) | Full page / fragment caching                     |
| Preloading (7.4+) | `opcache.preload`              | Framework classes loaded at startup              |

| Pattern              | Detail                                          |
| -------------------- | ----------------------------------------------- |
| Cache-aside          | Check cache → miss → fetch → store → return     |
| Invalidate on write  | Clear/update cache when data changes            |
| TTL expiration       | Set appropriate time-to-live per data type      |
| Cache stampede       | Use locking or probabilistic early refresh      |
| `fetchAll()` + cache | Load once, cache result, avoid repeated queries |

## SPL Data Structures

| Class                                   | Use for                         | vs Array                          |
| --------------------------------------- | ------------------------------- | --------------------------------- |
| `SplFixedArray`                         | Large fixed-size numeric arrays | ~50% less memory                  |
| `SplStack`                              | LIFO stack (push/pop)           | Enforces stack semantics          |
| `SplQueue`                              | FIFO queue (enqueue/dequeue)    | Enforces queue semantics          |
| `SplPriorityQueue`                      | Priority-based processing       | Built-in priority ordering        |
| `SplHeap` / `SplMinHeap` / `SplMaxHeap` | Heap operations                 | O(log n) insert/extract           |
| `SplDoublyLinkedList`                   | Efficient insert/remove at ends | Better for frequent head/tail ops |
| `SplObjectStorage`                      | Map objects to data             | Object identity as key            |

**Note:** You can check bench-marking for spl data structures to arrays [here](https://github.com/elazar/spl-benchmarks) and [here](https://gist.github.com/andrewdalpino/492bbf4261d31dad5f847f9f4c42cbf9)
## Micro-Optimizations

## Function Choices — Prefer Faster Alternatives

| Slower                          | Faster                                           | Why                                                                          |
| ------------------------------- | ------------------------------------------------ | ---------------------------------------------------------------------------- |
| `array_key_exists($k, $a)`      | `isset($a[$k])`                                  | Language construct, no function call (but returns `false` for `null` values) |
| `in_array($v, $arr)` (repeated) | `isset($flipped[$v])`                            | O(1) hash lookup vs O(n) linear scan — flip once with `array_flip()`         |
| `count($arr)` in loop condition | `$len = count($arr)` before loop                 | Avoid recalculating each iteration                                           |
| `strpos($h, $n) !== false`      | `str_contains($h, $n)`                           | Cleaner, same speed (PHP 8.0+)                                               |
| `substr($s, 0, 3) === 'foo'`    | `str_starts_with($s, 'foo')`                     | Purpose-built, clearer (PHP 8.0+)                                            |
| `intval($v)` / `settype()`      | `(int) $v`                                       | Direct cast — no function call overhead                                      |
| `floatval($v)`                  | `(float) $v`                                     | Direct cast                                                                  |
| `strval($v)`                    | `(string) $v`                                    | Direct cast                                                                  |
| `sprintf()` for simple join     | `.` concatenation or `implode()`                 | `sprintf()` parses format string                                             |
| `array_push($a, $v)`            | `$a[] = $v`                                      | Language construct, no function call                                         |
| `==` comparison                 | `===` comparison                                 | No type juggling overhead                                                    |
| `array_merge()` in loop         | `$result[] = $items` + `array_merge(...$result)` | Single merge at end                                                          |

### Strings & Arrays

| Pattern                         | Detail                                                 |
| ------------------------------- | ------------------------------------------------------ |
| String building in loops        | Collect in array, `implode()` at end (not `.=`)        |
| `array_column($rows, 'id')`     | Extract column from 2D array — faster than foreach     |
| `array_map()` for transforms    | Clean for simple callbacks; foreach for complex logic  |
| `array_filter()` preserves keys | Use `array_values()` to reindex if needed              |
| Generators for large data       | `yield` instead of building arrays in memory           |
| `SplFixedArray`                 | Pre-sized array for large fixed-size datasets          |
| `in_array()` strict mode        | Always `in_array($v, $a, true)` — avoids type juggling |
### Memory Management

```php
// Monitor memory usage
echo memory_get_usage(true);      // real OS allocation
echo memory_get_peak_usage(true); // max during script

// Free large variables explicitly
unset($largeArray);

// Force garbage collection in long-running processes
gc_collect_cycles();
```

|Rule|Detail|
|---|---|
|`unset()` large variables|Frees memory when no other references exist|
|`gc_collect_cycles()`|Manual GC for long-running CLI scripts|
|Generators over arrays|Process items one-by-one instead of loading all into memory|
|Streaming file reads|`fgets()` / `SplFileObject` — never `file_get_contents()` on large files|
|Typed properties|Enable engine optimizations and reduce memory|
|`memory_get_peak_usage(true)`|Track high-water mark during profiling|
### Loops

```php
// Cache count outside loop
$len = count($items);
for ($i = 0; $i < $len; $i++) { }

// foreach is idiomatic for arrays — use it
foreach ($items as $key => $value) { }

// Unset reference after foreach by-reference
foreach ($items as &$item) { $item = transform($item); }
unset($item);  // CRITICAL — prevents bugs from lingering reference

// array_map for simple transforms
$names = array_map(fn($u) => $u->name, $users);
```

| Pattern                 | Best for                                       |
| ----------------------- | ---------------------------------------------- |
| `foreach`               | Default for iterating arrays — idiomatic, fast |
| `for` with cached count | Index-based access, early break by position    |
| `array_map()`           | Simple 1:1 transforms with clean callback      |
| `array_filter()`        | Filtering with predicate                       |
| `array_walk()`          | Modify in-place by reference (less common)     |
| `while` + `fgets()`     | Line-by-line file processing                   |
| Generator + `foreach`   | Lazy iteration over large datasets             |

## More On PHP Memory

### Key Concepts in PHP Memory Management:

|Concept|Description|
|---|---|
|**References**|Variables are referenced by their values. When a variable is assigned to another variable or passed to a function, it creates a reference.|
|**Zval**|Each variable in PHP is stored as a `zval` (Zend value), which contains the variable's value and metadata (like type, reference count, etc.).|
|**Reference Counting**|PHP uses **reference counting** to track how many variables point to a particular `zval`. When the count reaches zero, the memory is freed.|

###  The Reference Counting Mechanism

At its core, PHP uses reference counting as its primary memory management strategy. Every PHP variable is stored as a zval (Zend value) container, which includes:

- The variable’s type
- The actual value
- Reference count
- Is_ref flag for reference tracking  

When you create a variable, PHP initializes a zval with a reference count of 1

```php
// Creates new zval, refcount = 1
$a = "Hello World";
// Increases refcount to 2
$b = $a;
// Decreases refcount to 1
unset($a);
```

### Circular References and the Garbage Collector

While reference counting works well for simple scenarios, it falls short when dealing with circular references. Consider this example:

```php
class Parent {
     public $child;
}
class Child {
     public $parent;
}
$parent = new Parent();
$child = new Child();
$parent->child = $child;
$child->parent = $parent;
unset($parent);
unset($child);
```

Even after unsetting both variables, the objects remain in memory because they reference each other. This is where PHP’s cycle-collecting garbage collector comes into play.
### How Does PHP Garbage Collection Work?

1. **Reference Counting**: PHP keeps track of how many variables reference each `zval`.
2. **Finalizers and Cyclic References**: If an object has a cyclic reference (e.g., `A` references `B`, and `B` references `A`), the GC may not be able to free it until PHP’s garbage collector is run explicitly.
3. **Garbage Collection in PHP**:
    - PHP automatically runs the GC at certain intervals.
    - You can also call the garbage collector manually using `gc_collect_cycles()`.


PHP’s garbage collector operates in three phases:

1. **Root Buffer Collection:** PHP stores possible circular reference candidates in a root buffer.
2. **Cycle Detection:** The collector analyzes the buffer to identify genuine circular references.
3. **Cleanup:** Identified cycles are broken and memory is freed.  
    

**Configuring Garbage Collection**

You can fine-tune garbage collection behavior through several PHP.ini settings:

```ini
zend.enable_gc = 1 ; Enable/disable garbage collection
gc_probability = 1 ; Probability of GC running
gc_divisor = 100 ; Combined with gc_probability
gc_maxlifetime = 1440 ; Maximum lifetime of sessions
```

### Memory Leaks

A memory leak occurs when a PHP script or application continuously consumes memory without releasing it after it is no longer needed. Over time, this leads to growing memory usage, resulting in performance degradation, application crashes, and even server reboots.

Unlike languages like C or C++, PHP is a garbage-collected language, meaning it automatically reclaims memory. However, certain coding patterns, resource mismanagement, or misconfigured extensions can bypass the garbage collector, leading to memory that remains allocated and unfreed.

Memory leaks are particularly dangerous in long-running scripts (e.g., workers or Laravel queues) or persistent environments like **PHP-FPM**, where scripts don't reset after each request.

**Avoid Memory Leaks**

- Do not leave long-running processes or large data structures in memory unnecessarily.
- Close database connections, file handles, and other resources when they are no longer needed.
- Use `unset()` to free up memory when variables are no longer needed.
- **Data Serialization and Deserialization**:  Avoid unnecessary serialization and deserialization of large objects or arrays, as this can increase memory usage. If you need to serialize data, try to keep the data structure minim
### Best Practices for Memory Management

1. **Release Resources Explicitly:** Close file handles, database connections, and other resources when no longer needed