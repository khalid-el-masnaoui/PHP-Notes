
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