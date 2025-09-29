
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

**I will cover all these tools in the `Tools` folder**


## Coding Style
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


### Docblocks

- Avoid docblocks for fully type-hinted methods/functions unless a description is necessary. (visual noise)
- Use docblocks to reveal the contents of arrays and collections
- Write docblocks on one line when possible
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



# Resources
[Interactive Design Foundation(IxDF) Open Handbook](https://handbook.interaction-design.org/) <**has many great resources - check it out!**>
[Interactive Design Foundation(IxDF) Coding Standard](https://github.com/InteractionDesignFoundation/coding-standard)
[PSR Standards Recommendations](https://www.php-fig.org/psr/) 
