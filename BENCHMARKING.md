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