
# PHP Coding Guidelines & Best Practices

## Overview

**Coding Standards** are an important factor for achieving a high code quality. A common visual style, naming conventions and other technical settings allow us to produce a homogenous code which is easy to read and maintain. However, not all important factors can be covered by rules and coding standards. Equally important is the style in which certain problems are solved programmatically.



## Introduction

PHP coding guidelines favor the approach: **less magic, more types**. Should prioritize explicit, strongly-typed code to enhance clarity, IDE support, and static analysis capabilities.

Key principles:

- Minimize magic, maximize explicitness
- Leverage PHP's type system
- Optimize for **IDE** and static analyzer support

### General considerations

- Follow the PSR standard
	- PSR-12 for code standards 
	- PSR-4 for auto-loading
	- PSR-3 for logging
	- PSR-7 for HTTP interface
	- .etc
- Files should contain a `declare(strict_types=1);` statement.
- PSR-12, has a soft limit of ==120 characters== for line length, with a strong recommendation for lines to be 80 characters or less.
- Lines end with a newline `Unix LF` with no trailing white-space.

