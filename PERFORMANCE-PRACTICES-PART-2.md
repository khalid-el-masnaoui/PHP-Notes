
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

|Rule|Detail|
|---|---|
|`ERRMODE_EXCEPTION`|Always — silent failures hide bugs|
|`EMULATE_PREPARES = false`|Real server-side prepared statements — actual SQL injection protection|
|`FETCH_ASSOC` default|Less memory than `FETCH_BOTH` (default)|
|`charset=utf8mb4` in DSN|MySQL: full Unicode including emoji|
|Named params `:name`|Clearer than positional `?` for 3+ parameters|
|Transactions for multi-statement|Atomicity — all succeed or all roll back|
|`fetchAll()` caution|Loads entire result into memory — use `fetch()` in loop for large results|
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
