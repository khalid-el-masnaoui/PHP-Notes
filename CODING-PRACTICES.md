
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
- Leverage opcache for production environments
- Use `stripos()` instead of `strpos()` with `strtolower()` for case-insensitive string searches
- Consider using `array_column()` for extracting specific columns from multidimensional arrays


## Dependency Management

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
