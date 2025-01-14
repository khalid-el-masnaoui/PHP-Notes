# PHP Benchmarking

Some Techniques to help bench-marking php applications to compare raw performance across servers, php versions and different run-times (php-fpm,swoole...)


# Table Of Contents

- **[Benchmarking](#Benchmarking)**
    - **[Overview](#overview)**
    - **[Why Benchmark?](#why-becnhmark-?)**
- **[Tools And Techniques](#tools-and-techniques)**
	- **[K6](#k6)**
	- **[Visualizing Results](#visualizing-results)**



# Benchmarking

## Overview 
When developing applications in any language, writing tests is only part of the equation; understanding how to measure performance can offer trans-formative insights into your code’s efficiency.

Benchmarking involves measuring the time taken by functions or operations to determine their speed under certain conditions. This practice helps identify bottlenecks and optimize them for better performance.

## Why Benchmark?

- Uncover slow-running code paths.
- Compare different implementation strategies.
- Verify the impact of changes over time.


## Tools and Techniques

### K6

k6 is **a high-performing load testing tool, scriptable in JavaScript**.

The k6 client command line allows you to generate many users directly from the client. This means that the k6 client acts as a controller (component orchestrating the test ) and a load generator (component sending the traffic to your application under test).

k6 can generate results like the below :

```log
scenarios: (100.00%) 1 scenario, 500 max VUs, 1m0s max duration (incl. graceful stop):

* default: 500 looping VUs for 30s (gracefulStop: 30s)

  
  

running (0m30.5s), 000/500 VUs, 15000 complete and 0 interrupted iterations

default ✓ [======================================] 500 VUs 30s

  

data_received..................: 1.2 GB 39 MB/s

data_sent......................: 1.2 MB 39 kB/s

http_req_blocked...............: avg=492.12µs min=2.29µs med=5.64µs max=50.06ms p(90)=8.7µs p(95)=17.95µs

http_req_connecting............: avg=452.39µs min=0s med=0s max=49.96ms p(90)=0s p(95)=0s

http_req_duration..............: avg=10.07ms min=921.3µs med=2.93ms max=138.15ms p(90)=35.3ms p(95)=49.24ms

{ expected_response:true }...: avg=10.07ms min=921.3µs med=2.93ms max=138.15ms p(90)=35.3ms p(95)=49.24ms

http_req_failed................: 0.00% ✓ 0 ✗ 15000

http_req_receiving.............: avg=532.76µs min=131.8µs med=495.17µs max=19.35ms p(90)=741.11µs p(95)=818.23µs

http_req_sending...............: avg=113.89µs min=8.65µs med=22.06µs max=42.12ms p(90)=43.54µs p(95)=52.35µs

http_req_tls_handshaking.......: avg=0s min=0s med=0s max=0s p(90)=0s p(95)=0s

http_req_waiting...............: avg=9.42ms min=703.98µs med=2.32ms max=98.57ms p(90)=34.45ms p(95)=48.5ms

http_reqs......................: 15000 491.048934/s

iteration_duration.............: avg=1.01s min=1s med=1s max=1.15s p(90)=1.03s p(95)=1.05s

iterations.....................: 15000 491.048934/s

vus............................: 500 min=500 max=500

vus_max........................: 500 min=500 max=500
```

You can read more about this awesome tool by reading [the official documentations](https://k6.io/docs/)

## phpbench

PHPBench is an open-source benchmark runner for PHP analogous to _PHPUnit_ but for performance rather than correctness.

You can simply write your test classes , like you do with unit testing and run the tests like below:

```bash
vendor/bin/phpbench run tests/Benchmark --report=aggregate
```

You get something like :

```bash
PHPBench (1.2.15) running benchmarks...
with configuration file: laravel-10/phpbench.json
with PHP version 8.1.24, xdebug ✔, opcache ✔

\Tests\Benchmark\ComputeServiceBench

benchIterate............................I0 - Mo360.000μs (±0.00%)

Subjects: 1, Assertions: 0, Failures: 0, Errors: 0

+---------------------+--------------+-----+------+-----+----------+-----------+--------+
| benchmark | subject | set | revs | its | mem_peak | mode | rstdev |
+---------------------+--------------+-----+------+-----+----------+-----------+--------+
| ComputeServiceBench | benchIterate | | 1 | 1 | 6.743mb | 360.000μs | ±0.00% |
+---------------------+--------------+-----+------+-----+----------+-----------+--------+
```

Check the [github repository](https://github.com/phpbench/phpbench) for this tool 


