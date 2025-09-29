
# PHP Coding Guidelines & Best Practices

## Overview

**Coding Standards** are an important factor for achieving a high code quality. A common visual style, naming conventions and other technical settings allow us to produce a homogenous code which is easy to read and maintain. However, not all important factors can be covered by rules and coding standards. Equally important is the style in which certain problems are solved programmatically.


## Introduction

PHP coding guidelines favor the approach: **less magic, more types**. Should prioritize explicit, strongly-typed code to enhance clarity, IDE support, and static analysis capabilities. Embrace consistent coding standards

Key principles:

- Minimize magic, maximize explicitness
- Leverage PHP's type system
- Optimize for **IDE** and static analyzer support (extensions and rule-sets!)
- Prioritize Security
- Optimize Performance
### General considerations

- **Follow the PSR standard**
	- PSR-12 for code standards 
	- PSR-4 for auto-loading
	- PSR-3 for logging
	- PSR-7 for HTTP interface
	- .etc
- Files should contain a `declare(strict_types=1);` statement.
- PSR-12, has a soft limit of ==120 characters== for line length, with a strong recommendation for lines to be 80 characters or less.
- Lines end with a newline `Unix LF` with no trailing white-space.
-  **Adopt PHP 8.x and Beyond**
	- Union Types
	- Attributes
	- Named Arguments
	- .etc

### Tools

Should be using automated tools to check our code and enforce these guidelines (can be integrated in a CD/CI pipeline)

+ **PHP-CS-Fixer**
+ **PHPCS**
+ **Psalm**
+ **PHPStan**
+ **Rector**
+ **Deptrac**
+ **composer-dependency-analyser**
+ and more ...

**I will cover all these tools in the `Tools` folder with their rule-sets for enforcing these guides**


## Coding Style

### Naming

- **Classes:** Class names must be declared in `PascalCase` (also known as `StudlyCaps`).
- **Properties & Methods:** Method names must be declared in `camelCase`.
- **Constants:** Class constants must be declared in all uppercase with underscores separating words.
-  **Files & Folders :**
	- Lowercase, hypen-delimited names for general files and folders.
	- Class files matching their respective `PascalCase` class names (for PSR-4 auto-loading).
	- The folder structure must mirror the namespace structure, using subdirectories for each namespace level. (PSR-4)
### Types

#### Strict types

Use `declare(strict_types=1);` in all files. This catches type-related bugs early and promotes more thoughtful code, resulting in increased stability.

#### Type declarations

- Always specify property types (when possible)
- Always specify parameter types (when possible)
- Always use return types (when possible)
    - Use `void` for methods that return nothing
    - Use `never` for methods that always throw an exception

#### Type-casting

Prefer type-casting over dedicated methods for better performance:

```php
// GOOD
$score = (int) '7';
$hasMadeAnyProgress = (bool) $this->score;

// BAD
$score = intval('7');
$hasMadeAnyProgress = boolval($this->score);
```


### Comments

#### Follow a convention

The convention of PHP is a simple one and quite a standard one:

1. Use `/* */` for **documenting** code. Documenting means to describe the purpose of a file, a function, a class, a method and so on. 
2. Use `//` for **explaining** code. Explaining here means to tell what a statement, or group of statements, does, and maybe even how it does it.
3. Break long comments into multiple lines.
4. Don't comment everything : **_less is more!_**
#### Docblocks

- Avoid docblocks for fully type-hinted methods/functions unless a description is necessary. (visual noise)
- Use docblocks to reveal the contents of arrays and collections
- Always use fully qualified class names in docblocks

```php
// GOOD
final class Foo
{
    /** @var list<string> */
    private array $urls;

    /** @var \Illuminate\Support\Collection<int, \App\Models\User> */
    private Collection $users;
}
```

Use **`PHPDoc`** for docblocks

### Inheritance and @inheritDoc

- Use `@inheritDoc` for classes and methods to make inheritance explicit
- For properties, copy the docblock from the parent class/interface instead of using `@inheritDoc`

### Traversable Types

Use advanced PHPDoc syntax to describe traversable types:



``` php
/** @return list<string> */
/** @return array<int, Type> */
/** @return Collection<TKey, TValue> */
/** @return array{foo: string, optional?: int} */
```


### Generic Types and Templates

Use Psalm (or PHPstan) template annotations for generic types:

```php
/**
 * @template T of \Illuminate\Notifications\Notification
 * @param class-string<T> $notificationFQCN
 * @return T
 */
protected function initialize(string $notificationFQCN): Notification
{
    // Implementation...
}
```

### OOP Practices
#### Final by default

Use `final` for classes and `private` for methods by default. This encourages **composition, dependency injection, and interface use over inheritance**. Consider the long-term maintainability, especially for public APIs.

#### Class name resolution

Use `ClassName::class` instead of hard-coded fully qualified class names.

```php
// GOOD
use App\Modules\Payment\Models\Order;
echo Order::class;

// BAD
echo 'App\Modules\Payment\Models\Order';
```

#### Use `self` keyword

Prefer `self` over the class name for return type hints and instantiation within the class.

```php
public static function createFromName(string $name): self
{
    return new self($name);
}
```


#### Named constructors

Use named static constructors to create objects with valid state:

```php
public static function createFromSignup(AlmostMember $almostMember): self
{
    return new self(
        $almostMember->company_name,
        $almostMember->country
    );
}
```

Reason: have a robust API that does not allow developers to create objects with invalid state (e.g. missing parameter/dependency).

#### Domain-specific operations

Encapsulate domain logic in specific methods rather than using generic setters:

```php
// GOOD
public function confirmEmailAwaitingConfirmation(): void
{
    $this->email = $this->email_awaiting_confirmation;
    $this->email_awaiting_confirmation = null;
}

// BAD
public function setEmail(string $email): self;
```

This approach promotes rich domain models and thin controllers/services

#### Enums

- Use singular names
- Use PascalCase for case names

```php
enum Suit
{
    case Hearts;
    case Diamonds;
    case Clubs;
    case Spades;
}
```


### Strings

**=> :** interpolation > `sprintf` > concatenation

Prefer string interpolation above `sprintf` and the concatenation `.` operator whenever possible. Always wrap the variables in curly-braces `{}` when using interpolation.


```php
// GOOD
$greeting = "Hi, I am {$name}.";

// BAD (hard to distinguish the variable)
$greeting = "Hi, I am $name.";
// BAD (less readable)
$greeting = 'Hi, I am '.$name.'.';
$greeting = 'Hi, I am ' . $name . '.';
```

For more complex cases when there are a lot of variables to concat or when it’s not possible to use string interpolation, please use `sprintf` function:

```php
$debugInfo = sprintf('Current FQCN is %s. Method name is: %s', self::class, __METHOD__);
```


### Exception Naming

Avoid the "Exception" suffix in exception class names. This encourages more descriptive naming.
* `UserNotFoundException` : The suffix brings absolutely no value. Even worse, it makes the (perfectly valid) sentence more obscure: `UserNotFound` is everything we need.

### Regular Expressions

Prioritize regex readability. For guidance, refer to [Writing better Regular Expressions in PHP](https://php.watch/articles/php-regex-readability).
Use [Regex101](https://regex101.com/) for testing patterns.

### SQL statements

Use an upper case for SQL keywords and functions:

```sql
# GOOD
SELECT MAX(sent_at) last_sent_at, notification_class FROM notification__notification_log GROUP BY notification_class

# BAD
select max(sent_at) last_sent_at, notification_class from notification__notification_log group by notification_class
```
### Others

- Prefer type-casting over type conversion functions (e.g., `(int)$value` instead of `intval($value)`)
- Use `isset()` or `array_key_exists()` instead of `in_array()` for large arrays when checking for key existence
- Use `stripos()` instead of `strpos()` with `strtolower()` for case-insensitive string searches
- Consider using `array_column()` for extracting specific columns from multidimensional arrays

## Best Practices
### Error & Exception Handling

#### Error Types 
- Parse Errors (Syntax Errors)
- Fatal Errors (e.g undefined function)
- Warning Errors
- Notice Errors

#### Basic Error Handling in PHP
At a basic level, you can manage errors using functions such as `error_reporting()`, `trigger_error()`, and `set_error_handler()`.

```php
/**
 * Custom error handler function.
 *
 * @param int    $errno   The level of the error raised.
 * @param string $errstr  The error message.
 * @param string $errfile The filename where the error was raised.
 * @param int    $errline The line number where the error was raised.
 *
 * @return bool True if the error has been handled.
 */
function custom_error_handler($errno, $errstr, $errfile, $errline) {
    echo "Error [$errno]: $errstr in $errfile on line $errline";
    # error_log(...)
    return true;
}

// Set custom error handler.
set_error_handler('custom_error_handler');

// Trigger an error.
echo $undefined_variable;

```

for a long time (since around PHP5.3), errors and exceptions were quite different animals. However, since version 7.0, they've been brought closer together under the umbrella of the `Throwable` interface.

While functions like `trigger_error` are kept in the language to maintain backward compatibility, Exceptions or `Error` objects should be preferred.
#### Advanced Error Handling Strategies
 Techniques such as **custom exception classes**, **unified error logging**, and **error propagation** across different layers of the application. These techniques help handle unexpected situations gracefully while providing clear diagnostics.

There are basically two operations that can be done once an Exception is thrown:

1. Handle it.
2. Let it propagate.
3. Throw it again.

The basic answer to the question (**Do you handle or propagate exceptions?**) is that you should handle an exception at the point in the program where something useful can be done to recover from the problem.
 
4. **Using Custom Exception Classes**
```php
/**
 * Custom DatabaseException class.
 */
class DatabaseException extends Exception {
    /**
     * Custom error message for database errors.
     *
     * @return string Error message.
     */
    public function error_message() {
        return "Database error on line {$this->getLine()} in {$this->getFile()}: {$this->getMessage()}";
    }
}

try {
    // Simulate a database error.
    throw new DatabaseException( 'Unable to connect to the database.' );
} catch ( DatabaseException $e ) {
    echo $e->error_message();
}
```

2. **Catching Multiple Exceptions**
```php
try {
    // Some code that may throw different types of exceptions.
} catch ( DatabaseException $e ) {
    // Handle database-specific errors.
} catch ( FileNotFoundException $e ) {
    // Handle file-specific errors.
} catch ( Exception $e ) {
    // Handle generic errors.
}
```

#### Best Practices

1. **Do Not Display Errors in Production**
	To prevent critical information from being exposed, display_errors should always be disabled in production situations.

2. **Use Logging Extensively**
	Unexpected exceptions and serious mistakes should always be recorded. You may use this to find problems in a production setting.

3. **Use Exception Handling for Complex Errors**
	To deal with failures in complicated systems, utilize exceptions. This results in improved control and more transparent error flows.

4. **Fail Gracefully**
	Provide user-friendly notifications or fallback behavior to ensure your program can handle problems gracefully without breaking the system as a whole.

5. **Regularly Monitor and Review Logs**
	Regular monitoring of error logs is necessary to make sure that no serious problems are overlooked.
	Errors should be detected and raised immediately when they occur to avoid "swallowing" the root cause or leading to a more complex issue later on
	
6. **Avoid Bad Practices**
- Do not use the error control operator (`@`): to suppress errors, as it can hide critical issues and make debugging difficult.
* Do not ignore exceptions; always log or handle them appropriately.
* Avoid logging and re-throwing the same exception: without adding new context; instead, consider chaining exceptions if more context is needed at a higher level.
### Principals & Design Patterns

There are numerous ways to structure the code and project for your web application, and you can put as much or as little thought as you like into architecting. But it is usually a good idea to follow common patterns because it will make your code easier to manage and easier for others to understand.

Coding principles and design patterns are essential for developing robust, scalable, and maintainable applications.

Benefits of using principles and patterns:
- **Improved Code Maintainability:** Easier to understand, modify, and extend.
- **Enhanced Re-usability:** Solutions can be applied across different projects.
- **Better Communication:** Provides a common vocabulary for developers.
- **Increased Flexibility and Scalability:** Applications can adapt to changing requirements more easily.

#### Coding Principles
1. **SOLID**
	- `Single Responsibility Principle (SRP)`
	- `Open/Closed Principle (OCP)`
	- `Liskov Substitution Principle (LSP)`
	- `Interface Segregation Principle (ISP)`
	- `Dependency Inversion Principle (DIP)`
2. **DRY (Don't Repeat Yourself)**
3. **YAGNI (You Aren't Gonna Need It)**

#### Design patterns

Design patterns are established, reusable solutions to commonly occurring problems in software design. They are not specific pieces of code that can be directly copied and pasted, but rather blueprints or templates that guide developers in structuring their code to achieve specific design goals.

Design patterns are typically categorized into three main types based on their intent:

- **Creational Patterns:**
    Focus on object creation mechanisms, aiming to create objects in a way that decouples the client from the concrete classes being instantiated. Examples include Factory Method, Abstract Factory, Singleton, and Builder.
    
- **Structural Patterns:** 
    Deal with the composition of objects and classes, simplifying the design by identifying relationships between entities. Examples include Adapter, Bridge, Composite, Decorator, Facade, and Proxy.
    
- **Behavioral Patterns:** 
    Address the communication and interaction between objects, defining how objects collaborate to achieve a task. Examples include Chain of Responsibility, Command, Iterator, Mediator, Observer, Strategy, and State.


I will cover each of these principals and design patterns, in details with PHP examples in my repository `Principals & Design Patterns`
### PHP Clean Code

### Testing

### Dependency Management

- Use Composer for managing PHP dependencies
- Keep `composer.json` and `composer.lock` in version control
- Specify exact versions or version ranges for production dependencies
- Use `composer update` sparingly in production environments
- Regularly update dependencies and review `changelogs`
- Leverage tools to check for unused and shadow dependencies (`composer-dependency-analyser` or `composer-unused` + `composer-require-checker`)
- Consider using [`composer-normalize`](https://github.com/ergebnis/composer-normalize) for consistent `composer.json` formatting
- Use private repositories or artifact repositories for internal packages
- Implement a dependency security scanning tool in your CI pipeline (e.g., `Snyk`, `parse`; add `composer audit` to your CI pipeline)
# Resources
[Interactive Design Foundation(IxDF) Open Handbook](https://handbook.interaction-design.org/) <**has many great resources - check it out!**>
[PSR Standards Recommendations](https://www.php-fig.org/psr/) 
[Flow Framework Coding Guidelines](https://flowframework.readthedocs.io/en/stable/TheDefinitiveGuide/PartV/CodingGuideLines/PHP.html)
[Gist PHP Style Guide](https://gist.github.com/ryansechrest/8138375)
