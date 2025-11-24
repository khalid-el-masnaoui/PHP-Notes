
# PHP Performance Best Practices

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