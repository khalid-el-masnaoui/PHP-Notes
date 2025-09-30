## Overview

Writing clean code in PHP isn’t just about making it look good — it’s about making it **easier to read, maintain, and scale**, it is not a style guide. It's a guide to producing readable, reusable, and re-factorable software in PHP.  Clean code leads to fewer bugs, faster development, and a smoother experience overall.

Poorly written code can quickly become a nightmare to maintain, leading to bugs, security vulnerabilities, and wasted time.

It also helps automated tools — such as static analyzers, linters, and code quality tools — identify potential issues early, ensuring your project remains robust and reliable.

Not every principle herein has to be strictly followed, and even fewer will be universally agreed upon. These are guidelines and nothing more.
## Variables

### Use meaningful and pronounceable variable names

```php 
// BAD
$ymdstr = $moment->format('y-m-d');

// GOOD
$currentDate = $moment->format('y-m-d');
```

### Use the same vocabulary for the same type of variable

```php 
//BAD
getUserInfo();
getUserData();
getUserRecord();
getUserProfile();

// GOOD
getUser();
```

### Avoid Magic Numbers

```php
// BAD
$result = $serializer->serialize($data, 448);

// GOOD
$json = $serializer->serialize($data, JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

```

```php 
// BAD 
if ($status == 1) {  
// Handle active status  
}  
  
// GOOD  
const ACTIVE_STATUS = 1;  
  
if ($status == ACTIVE_STATUS) {  
// Handle active status  
}

```
