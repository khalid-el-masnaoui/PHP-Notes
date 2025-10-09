
# PHP Refactoring and Upgrading

## Overview 

As a software engineer, you should always look for ways to improve your code.Applications must be regularly updated and maintained.

Refactoring and Upgrading  are distinct but often **intertwined** processes aimed at improving the quality, maintainability, and performance of a PHP application.

## Table Of Contents

* **[PHP Refactoring](#php-refactoring)**
  + **[Introduction ](#introduction)**
  + **[When to refactor](#when-to-refactor)**
  + **[Starting With Refactoring Guideline](#starting-with-refactoring-guideline)**
	 - **[1. Incremental Refactoring : The one-step-at-a-time approach ](#1-incremental-refactoring-the-one-step-at-a-time-approach)**
	 - **[2. Consider the importance of business](#2-consider-the-importance-of-business)**
	 - **[3. Upgrade your PHP version](#3-upgrade-your-php-version)**
	 - **[4. Update your libraries](#4-update-your-libraries)**
	 - **[5. Try out the Strangler Fig Pattern](#5-try-out-the-strangler-fig-pattern)**
		* **[How to use the Strangler Fig Pattern?](#how-to-use-the-strangler-fig-pattern)**
	- **[6. Testing in Conjunction with Refactoring](#6-testing-in-conjunction-with-refactoring)**
  + **[Techniques for Refactoring PHP Code](#techniques-for-refactoring-php-code)**
	 - **[1. Extracting Functions and Methods](#1-extracting-functions-and-methods)**
	 - **[2. Replace Conditional Logic with Polymorphism](#2-replace-conditional-logic-with-polymorphism)**
	 - **[3. Be Expressive](#3-be-expressive)**
	 - **[4. Return Early](#4-return-early)**
	 - **[6. Coding best practices and clean code](#6-coding-best-practices-and-clean-code)**
- **[Tools](#tools)**
* **[Reminder](#reminder)**
* **[Resources](#resources)**

## PHP Refactoring

### Introduction 

Refactoring is a systematic process of restructuring and improving code without changing its external behavior. The main goal of refactoring is to make the code more maintainable, easier to understand, and less prone to bugs.

You may want to refactor a legacy code-base (involving upgrading as well), or a modern co-debase using best practices and clean code guidelines.

Key aspects of PHP refactoring include:

- **Improving Readability:** 
    Using clear variable and function names, consistent formatting, and reducing code complexity.
    
- **Reducing Duplication:** 
    Identifying and consolidating repetitive code blocks into reusable functions or classes.
    
- **Enhancing Modularity:** 
    Breaking down large, complex classes or functions into smaller, more focused units.

+ **Extendability** 
	Making it easier to add new features and functionality

- **Applying Design Patterns:** 
    Implementing established design patterns to address common architectural challenges and improve code structure.

- **Improving Performance (Indirectly):** 
    While not the primary goal, refactoring can sometimes lead to performance improvements by optimizing algorithms or reducing unnecessary computations.

**The main purpose of refactoring is to fight technical debt. It transforms a mess into clean code and simple design.**

### When to refactor

#### Rule of Three
1. When you’re doing something for the first time, just get it done.

2. When you’re doing something similar for the second time, cringe at having to repeat but do the same thing anyway.

3. When you’re doing something for the third time, start refactoring.

#### When adding a feature

- Refactoring helps you understand other people’s code. If you have to deal with someone else’s dirty code, try to refactor it first. Clean code is much easier to grasp. You will improve it not only for yourself but also for those who use it after you.
    
- Refactoring makes it easier to add new features. It’s much easier to make changes in clean code.

#### When fixing a bug

- Bugs in code behave just like those in real life: they live in the darkest, dirtiest places in the code. Clean your code and the errors will practically discover themselves.

- Managers appreciate proactive refactoring as it eliminates the need for special refactoring tasks later.

#### During a code review

- The code review may be the last chance to tidy up the code before it becomes available to the public.

- It’s best to perform such reviews in a pair with an author. This way you could fix simple problems quickly and gauge the time for fixing the more difficult ones.

### Starting With Refactoring Guideline

The "rewrite everything" approach is tempting for several reasons. **Starting fresh means freedom from technical debt** and outdated design patterns

However, rewrites **consistently take longer than initially estimated**, often by factors of 2-3x. **Critical business logic and edge cases** can be buried in the old code and easily overlooked. Users expect all existing functionality to work, including obscure features you may not even know exist. Fresh codebases introduce their own bugs, sometimes replacing old problems with new ones.

A complete refactoring comes with its problems as well:
> **The primary cause of refactoring problems is fragmentation or lack of proper project knowledge on the application’s business model and more.**

A more balanced approach recognizes the value in both preserving what works and improving what doesn't. `=>` **Incremental Refactoring**

For optimal results, refactoring efforts should be performed concurrently with producing business knowledge. You can analyze each and every area of a module individually over an extended period of time while shaping a **repeatable refactoring process for the whole app**.

I will be discussing how we can reduce /eliminate such problems with some intuitive well known strategies that we can use to reshape our  **repeatable refactoring process** 

#### 1. Incremental Refactoring : The one-step-at-a-time approach 

Try to improve the code by making small changes.If you spot **poorly name variables** – correct them! If you find out that the **structure of a given class is incorrect** – change it! Are there **missing types** somewhere? Add them!

The point is not to spend too much time on it. By making a couple of small positive changes at a time, you gradually improve the codebase. If you get your teammates to do the same thing, the result is even better. Over time, you can even refactor the whole app using the process.

With incremental improvements, **the system remains operational throughout the process**. Changes can be introduced gradually, allowing for course correction as you go. Developers gain deeper understanding of business logic while refactoring existing code.

#### 2. Consider the importance of business

From the perspective of developers themselves, business knowledge is also crucial. Once you know which modules of the system are most important from a business perspective, you can plan your refactoring process better. 

Personally, **I like to start with the smallest and least important modules**. That way, you can get the hang of the system and the style of its code by working with the least essential parts of it. The probability of breaking the entire system and having to revert entirely to the old codebase shrinks.

#### 3. Upgrade your PHP version

One of the first things I do as part of refactoring is update my PHP version. Not only will it speed up the app, but will also make it easier to spot outdated code. This is extremely important, as some of the outdated pieces of your software might lead to security issues that may be exploited

There are some handy tools that can assist you in upgrading your PHP version. [Rector](https://github.com/rectorphp/rector) is the standout there , it is covered in detail in the folder `Tools`

Once PHP is updated, errors removed, obsolete functions rewritten, and other problematic pieces of code simplified, you can move to another stage of refactoring that has to do with libraries.

#### 4. Update your libraries

When you are in the early stages of PHP refactoring, inspecting all of the libraries in your project is a must.

> **If your system is large and old, chances are that some of your libraries are not only outdated but entirely abandoned by their authors.**

Updating is quite straightforward. The composer tool detects outdated/abandoned ones. Such libraries often recommend how best to update or replace them. The difficult part is finding all the pieces of code affected by the libraries (you can use your IDE to assist in that).

#### 5. Try out the Strangler Fig Pattern

What is the Strangler Fig Pattern? It is all about building a new system around the old one (strangling the old one with the new one) until the latter is not needed anymore

Let's say we have an old CakePHP, CodeIgniter, Yii, or plain PHP project and you want to upgrade to Symfony or Laravel. You start by isolating part of the project, e.g. invoicing, and wrap it with Symfony or Laravel controller.

 - **The system always works :**
	The new system in development shouldn’t collide with the existing one. As the new one matures, its individual modules can gradually replace the old system.
- **Monitoring is easy :**
	As the tasks are being transferred to the new system, it’s easy to monitor and compare their performance. You can gradually eliminate all the problems should they arise.

##### **How to use the Strangler Fig Pattern?**
 1. **Define the interface of what you want to move :**
	It’s an essential step because the interface includes directions on how the new code and modules are supposed to work.

2. **Delegate tasks from the old system to the new one :**
	If there is a piece of code in your new system that can replace a piece of code from the old system, make the switch as soon as possible. 
	
3. **Define a new single source of truth :**
    A well-designed system has a single source of truth (SSOT). It should have all data required by your system’s modules. As you move to the new system, make sure not to compromise your SSOT.

4. **Add all the new functionalities in the new system only :**
    It should go without saying, but unfortunately, it doesn’t always happen. If you continue to expand your old codebase, you delay the moment when the new system takes over completely and risk having to write the same functionality twice.

5. **Turn off the old code altogether when the time comes :**
    Once all the functionalities are moved to the new system, turn off or remove the old code.

#### 6. Testing in Conjunction with Refactoring

Tests, particularly unit tests, are crucial when refactoring. They act as a safety net, ensuring that the refactoring process does not introduce regressions or break existing functionality.

We already mentioned that refactoring doesn't change the functionality of your code. This comes handy when running tests, because they should work after refactoring too. This is why I only start to refactor my code, when there are tests. They will assure that I don't unintentionally change the behaviour of my code. So don't forget to write tests or even go TDD.
### Techniques for Refactoring PHP Code

Several techniques can be applied to refactor PHP code. Some of the most common methods include:

#### 1. Extracting Functions and Methods

One common problem in PHP code is long functions or methods that perform multiple tasks. This can make the code difficult to understand and maintain. To refactor this code, you can extract smaller functions or methods from the existing code.

For example, consider the following PHP code:

```php
// BEFORE
protected function handle()
{
    $url = $this->option('url') ?: $this->ask('Please provide the URL for the import:');
    
    $importResponse =  $this->http->get($url);

    $bar = $this->output->createProgressBar($importResponse->count());
    $bar->start();

    $this->userRepository->truncate();
    collect($importResponse->results)->each(function (array $attributes) use ($bar) {
        $this->userRepository->create($attributes);
        $bar->advance();
    });

    $bar->finish();
    $this->output->newLine();

    $this->info('Thanks. Users have been imported.');
    
    if($this->option('with-backup')) {
        $this->storage
            ->disk('backups')
            ->put(date('Y-m-d').'-import.json', $response->body());

        $this->info('Backup was stored successfully.');
    }
  
}
```


This function does multiple tasks, making it difficult to understand and maintain. We can refactor it by extracting smaller functions for each task:

```php
// AFTER
protected function handle()
{
    $url = $this->option('url') ?: $this->ask('Please provide the URL for the import:');
    
    $importResponse =  $this->http->get($url);
    
    $this->importUsers($importResponse->results);
    
    $this->saveBackupIfAsked($importResponse);
}

protected function importUsers($userData): void
{
    $bar = $this->output->createProgressBar(count($userData));
    $bar->start();

    $this->userRepository->truncate();
    collect($userData)->each(function (array $attributes) use ($bar) {
        $this->userRepository->create($attributes);
        $bar->advance();
    });

    $bar->finish();
    $this->output->newLine();

    $this->info('Thanks. Users have been imported.');
}

protected function saveBackupIfAsked(Response $response): void
{
    if($this->option('with-backup')) {
        $this->storage
            ->disk('backups')
            ->put(date('Y-m-d').'-import.json', $response->body());

        $this->info('Backup was stored successfully.');
    }
}
```


#### 2. Replace Conditional Logic with Polymorphism

Conditional logic can make your code difficult to understand and maintain. One way to refactor this kind of code is to use polymorphism, a concept in object-oriented programming that allows objects of different classes to be treated as objects of a common superclass. This can help you eliminate complex conditional logic and improve code readability.

```php
// BEFORE
class Animal {
    public function makeSound($animalType) {
        if ($animalType === 'dog') {
            return 'woof';
        } elseif ($animalType === 'cat') {
            return 'meow';
        } elseif ($animalType === 'bird') {
            return 'chirp';
        }
    }
}
```

We can refactor this code using polymorphism as follows:

```php
// AFTER
interface Animal {
    public function makeSound();
}

class Dog implements Animal {
    public function makeSound() {
        return 'woof';
    }
}

class Cat implements Animal {
    public function makeSound() {
        return 'meow';
    }
}

class Bird implements Animal {
    public function makeSound() {
        return 'chirp';
    }
}
```

#### 3. Be Expressive

This might be an easy tip, but writing expressive code can improve it a lot. Always make your code self-explaining so that you, your future self or any other developers who stumble over your code knows what is going on

```php
// BEFORE
$status = $user->status('pending');

// AFTER
$isUserPending = $user->isStatus('pending');
```


#### 4. Return Early

The concept of `early returns` refers to a practice where we try to avoid nesting by breaking a structure down to specific cases. In return, we will get a more linear code, which is much easier to read and grasp. Every case is separated and good to follow. Don't be afraid of using multiple return statements.

```php
// BEFORE
public function calculateScore(User $user): int
{
    if ($user->inactive) {
        $score = 0;
    } else {
        if ($user->hasBonus) {
            $score = $user->score + $this->bonus;
        } else {
            $score = $user->score;
        }
    }

    return $score;
}

// AFTER
public function calculateScore(User $user): int
{
    if ($user->inactive) {
        return 0;
    }

    if ($user->hasBonus) {
        return $user->score + $this->bonus;
    }

    return $user->score;
}

```

#### 6. Coding best practices and clean code

You should be able to apply and use the best practices and principles of clean coding in PHP in your refactoring process , refer to my two guides [Coding-Practices](https://github.com/khalid-el-masnaoui/PHP-Notes/blob/main/CODING-PRACTICES.md) and [Coding-Clean](https://github.com/khalid-el-masnaoui/PHP-Notes/blob/main/CODING-CLEAN.md)


## Code Smells

Code smells are indicators of potential problems or design flaws in software code. They often manifest as repetitive patterns, inconsistencies, or inefficient practices. These smells can range from simple issues like unused variables or long methods to more complex problems like tight coupling or god objects.

While code smells may not always lead to immediate errors, they can make code harder to understand, maintain, and extend. Ignoring code smells can result in increased technical debt, reduced code quality, and potential bugs, ultimately hindering the development and evolution of software projects.

Simply put : A Code Smell is that feeling after a first glance at a piece of code that immediately makes you think there’s something wrong. You might not have a better solution yet, but the more you look at a chunk of code, the more you think it’s just not right.


### Bloaters

Bloaters are a type of code smell that refers to code elements (code, methods and classes) that are excessively large or complex. Usually these smells don’t crop up right away, rather they accumulate over time as the program evolves.
They can significantly impact code readability, maintainability, and performance.


1. **`Long Method`** : A method contains too many lines of code. Generally, any method longer than ten lines should make you start asking questions.

2. **`Large Class`** : A class contains many fields/methods/lines of code.

3. **`Primitive Obsession`** :  
	- Use of primitives instead of small objects for simple tasks (such as currency, ranges, special strings for phone numbers, etc.)
	- Use of constants for coding information (such as a constant USER_ADMIN_ROLE = 1 for referring to users with administrator rights.)
	- Use of string constants as field names for use in data arrays.

4. **`Long Parameter List`** : More than three or four parameters for a method.

5. **`Data Clumps`** : Sometimes different parts of the code contain identical groups of variables (such as parameters for connecting to a database). These clumps should be turned into their own classes.

#### Long Method

Something is always being added to a method but nothing is ever taken out. Since it’s easier to write code than to read it, this “smell” remains unnoticed until the method turns into an ugly, oversized beast.

Mentally, it’s often harder to create a new method than to add to an existing one: “But it’s just two lines, there’s no use in creating a whole method just for that...” Which means that another line is added and then yet another, giving birth to a tangle of spaghetti code.

Long method violates the Single Responsibility Principle

**`Solution:`**
Break down the method into smaller, more focused functions with meaningful names.

```php
class OrderProcessor {
    public function processOrder($order) {
        $this->validateOrder($order);
        $this->calculateTotal($order);
        $this->applyDiscount($order);
        // ... other specific tasks ...
    }

    private function validateOrder($order) {
        // validation logic
    }

    private function calculateTotal($order) {
        // calculation logic
    }

    private function applyDiscount($order) {
        // discount logic
    }
}
```

**`Performance:`** 
- Does an increase in the number of methods hurt performance, as many people claim? In almost all cases the impact is so negligible that it’s not even worth worrying about.

- Plus, now that you have clear and understandable code, you’re more likely to find truly effective methods for restructuring code and getting real performance gains if the need ever arises.

#### Large Class
A class that contains many fields/methods/lines of code.
Classes usually start small. But over time, they get bloated as the program grows.

As is the case with long methods as well, programmers usually find it mentally less taxing to place a new feature in an existing class than to create a new class for the feature.

A large class violates Single Responsibility Principle (**SRP**)

**`Solution :`**
Divide the class into smaller, more focused classes, each responsible for a specific aspect of functionality.

```php
class Order {
    private $processor;
    private $calculator;

    public function __construct(OrderProcessor $processor, OrderCalculator $calculator) {
        $this->processor = $processor;
        $this->calculator = $calculator;
    }

    public function process() {
        $this->processor->processOrder($this);
    }

    public function calculateTotal() {
        $this->calculator->calculateTotal($this);
    }
}
```

**Note** :  In many cases, splitting large classes into parts avoids duplication of code and functionality.

## Primitive Obsession

Primitive obsession is a code smell that occurs when a class or method relies excessively on primitive data types (like int, float, boolean, String, etc.) instead of creating custom data structures.

- **Lack of encapsulation:** By using primitive types directly, you’re not encapsulating related data and behavior within a cohesive object. This can make your code harder to understand, maintain, and reuse.
- **Increased coupling:** Using primitive types can lead to tighter coupling between different parts of your code, making it more difficult to make changes without affecting other areas.

Like most other smells, primitive obsessions are born in moments of weakness. “Just a field for storing some data!” the programmer said. Creating a primitive field is so much easier than making a whole new class, right? And so it was done. Then another field was needed and added in the same way.

**`Example`** 

```php
class Employee {
    private string $name;
    private int $age;
    private string $addressLine1;
    private string $addressLine2;
    private string $city;
    private string $state;
    private string $zipCode;
    private bool $isAdmin;

    public function __construct(string $name, int $age, string $addressLine1, string $addressLine2, 
                                string $city, string $state, string $zipCode, bool $isAdmin) {
        $this->name = $name;
        $this->age = $age;
        $this->addressLine1 = $addressLine1;
        $this->addressLine2 = $addressLine2;
        $this->city = $city;
        $this->state = $state;
        $this->zipCode = $zipCode;
        $this->isAdmin = $isAdmin;
    }

    public function getAddress(): string {
        return $this->addressLine1 . ", " . $this->addressLine2 . ", " . $this->city . ", " . $this->state . " " . $this->zipCode;
    }

    public function isAdult(): bool {
        return $this->age >= 18;
    }

    public function isEligibleForAdministrativeRole(): bool {
        return $this->isAdmin && $this->isAdult();
    }
}
```

**`Solution`**

- If you have a large variety of primitive fields, it may be possible to logically group some of them into their own class. Even better, move the behavior associated with this data into the class too. For this task, try Replace Data Value with Object. (`Value Objetc`, `enums`....)

```php 

class Employee {
    private string $name;
    private Age $age;
    private Address $address;
    private Role $role;

    public function __construct(string $name, Age $age, Address $address, Role $role) {
        $this->name = $name;
        $this->age = $age;
        $this->address = $address;
        $this->role = $role;
    }

    public function getAddress(): string {
        return $this->address->__toString();
    }

    public function isEligibleForAdministrativeRole(): bool {
        return $this->role->isAdmin() && $this->age->isAdult();
    }
}

class Address {
    private string $line1;
    private string $line2;
    private string $city;
    private string $state;
    private string $zipCode;

    public function __construct(string $line1, string $line2, string $city, string $state, string $zipCode) {
        $this->line1 = $line1;
        $this->line2 = $line2;
        $this->city = $city;
        $this->state = $state;
        $this->zipCode = $zipCode;
    }

    public function __toString(): string {
        return $this->line1 . ", " . $this->line2 . ", " . $this->city . ", " . $this->state . " " . $this->zipCode;
    }
}

class Age {
    private int $value;

    public function __construct(int $value) {
        $this->value = $value;
    }

    public function isAdult(): bool {
        return $this->value >= 18;
    }
}

enum Role: string {
    case ADMIN = 'ADMIN';
    case NON_ADMIN = 'NON_ADMIN';

    public function isAdmin(): bool {
        return $this === self::ADMIN;
    }
}
```


#### Long Parameter List

More than three or four parameters for a method.

- **Reduced Readability:**  A long list of arguments makes the function signature difficult to read and understand at a glance.
    
- **Increased Complexity:**  It suggests the function might be doing too many things, violating the Single Responsibility Principle.
    
- **Maintenance Challenges:** Adding or removing parameters requires modifying the function signature and all its call sites, leading to more changes and potential errors.
    
- **Tight Coupling:**  It can indicate that the function is too dependent on specific data, making it harder to reuse or test independently.

**`Solution`**

- `Introduce Parameter Object:`
    - Encapsulate related parameters into a dedicated class or data transfer object (DTO).
    - Pass an instance of this object as a single parameter to the function.

- `Refactor into Smaller Methods:`
	- If the long parameter list is a symptom of a function doing too much, break down the function into smaller, more focused methods, each with fewer parameters.
	
- Use `array` or `stdClass` for Optional Parameters (with caution):
    - For a set of optional or configuration parameters, passing an associative array or an `stdClass` object can reduce the number of explicit parameters.
    - This should be used judiciously, as it can reduce type safety and make it harder to understand expected inputs without proper documentation.

```php
    // Before
    function createUser(string $firstName, string $lastName, int $age, string $email, string $address): User
    {
        // ...
    }

    // After (with a UserData object)
    class UserData
    {
        public string $firstName;
        public string $lastName;
        public int $age;
        public string $email;
        public string $address;
    }

    function createUser(UserData $userData): User
    {
        // ...
    }
```


#### Data Clumps 

Represents a code smell where a group of related data items are consistently passed around together as separate parameters or fields, rather than being encapsulated within a dedicated object (such as parameters for connecting to a database).

**`Example`**

```php
function processOrder(string $itemName, int $quantity, string $street, string $city, string $zipCode, string $country) {
    // ... logic using address details ...
}
```

Here, `$street`, `$city`, `$zipCode`, and `$country` form a data clump because they are always used together to represent an address.

**`Solution`**

```php
function processOrder(string $itemName, int $quantity, Address $address) {
	// ... logic using $address->getStreet(), $address->getCity(), etc. ...
}

 class Address {
        private string $street;
        private string $city;
        private string $zipCode;
        private string $country;

        public function __construct(string $street, string $city, string $zipCode, string $country) {
            $this->street = $street;
            $this->city = $city;
            $this->zipCode = $zipCode;
            $this->country = $country;
        }

        // Getters for address properties
        public function getStreet(): string { return $this->street; }
        public function getCity(): string { return $this->city; }
        public function getZipCode(): string { return $this->zipCode; }
        public function getCountry(): string { return $this->country; }
    }
```

This refactoring makes the code more cohesive, reduces the number of parameters in the `processOrder` function, and **clearly defines the `Address` concept within the application**.

**Note** : When to Ignore
-  Passing an entire object in the parameters of a method, instead of passing just its values (primitive types), may create an undesirable dependency between the two classes.

### Object-Orientation Abusers

OOAs are code elements that violate or misuse object-oriented principles, such as encapsulation, inheritance, polymorphism, and abstraction

All these smells are incomplete or incorrect application of object-oriented programming principles.

- **Switch Statements:** Overuse of switch statements to determine behavior based on object types, which can lead to tight coupling and lack of polymorphism.
- **Temporary Field :** Temporary fields get their values (and thus are needed by objects) only under certain circumstances. Outside of these circumstances, they’re empty.
- **Refused Bequest:** Inheritance hierarchies that are too deep or where subclasses inherit unnecessary methods or attributes.
- **Alternative Classes with Different Interfaces** : Two classes perform identical functions but have different method names.

#### Switch Statements

**Violation of Open/Closed Principle:**  A large switch statement often needs modification every time a new condition or type is introduced, violating the Open/Closed Principle

As a rule of thumb, when you see `switch` you should think of **polymorphism**.

**`Example`**

- The `PaymentProcessor` class uses a switch statement to determine payment processing logic
- Addition of new payment types requires modifying the switch statement

```php

enum PaymentType: string {
    case CREDIT_CARD = 'CREDIT_CARD';
    case PAYPAL = 'PAYPAL';
    case BANK_TRANSFER = 'BANK_TRANSFER';
}

class Payment {
    private PaymentType $type;

    public function __construct(PaymentType $type) {
        $this->type = $type;
    }

    public function getType(): PaymentType {
        return $this->type;
    }
}

class PaymentProcessor {
    public function processPayment(Payment $payment): void {
        switch ($payment->getType()) {
            case PaymentType::CREDIT_CARD:
                $this->processCreditCardPayment($payment);
                break;
            case PaymentType::PAYPAL:
                $this->processPayPalPayment($payment);
                break;
            case PaymentType::BANK_TRANSFER:
                $this->processBankTransferPayment($payment);
                break;
            default:
                throw new Exception("Unsupported payment type");
        }
    }

    private function processCreditCardPayment(Payment $payment): void {
        // credit card payment logic
    }

    private function processPayPalPayment(Payment $payment): void {
        // paypal payment logic
    }

    private function processBankTransferPayment(Payment $payment): void {
        // bank transfer payment logic
    }
}
```

**`Solution`**

- Using **polymorphism**

```php

interface PaymentProcessorStrategy {
    public function processPayment(Payment $payment);
}

class CreditCardPaymentProcessor implements PaymentProcessorStrategy {
    public function processPayment(Payment $payment) {
        // credit card payment logic
    }
}

class PayPalPaymentProcessor implements PaymentProcessorStrategy {
    public function processPayment(Payment $payment) {
        // paypal payment logic
    }
}

class BankTransferPaymentProcessor implements PaymentProcessorStrategy {
    public function processPayment(Payment $payment) {
        // bank transfer payment logic
    }
}

class PaymentProcessor {
    private array $strategies;

    public function __construct() {
        $this->strategies = [
            PaymentType::CREDIT_CARD => new CreditCardPaymentProcessor(),
            PaymentType::PAYPAL => new PayPalPaymentProcessor(),
            PaymentType::BANK_TRANSFER => new BankTransferPaymentProcessor(),
        ];
    }

    public function processPayment(Payment $payment): void {
        $type = $payment->getType();
        if (isset($this->strategies[$type])) {
            $this->strategies[$type]->processPayment($payment);
        } else {
            throw new Exception("Unsupported payment type");
        }
    }
}
```

#### Temporary Field

The `Temporary Field` is a code smell that occurs when a class has an instance variable that is only used under specific circumstances or within a particular method or algorithm, and remains empty or unused at other times.

**Unpredictable Object State:**  The value of the temporary field is only set and relevant when a specific method or sequence of operations is being executed. Outside of these conditions, it might be null, empty, or contain outdated information, making the object's state inconsistent and harder to reason about.

**`Solution`**
- **`Extract Method Object`:** If the temporary field is part of a complex algorithm, extract that algorithm and its associated temporary fields into a new, dedicated "method object" class. This object would encapsulate the temporary state and the logic that uses it.

```php
    // Before: Temporary field in a class
    class ReportGenerator {
        private $data;
        private $temporaryResult; // Temporary field

        public function generateReport() {
            // ... calculations using $this->data and setting $this->temporaryResult
            // ... using $this->temporaryResult
        }
    }

    // After: Extract Method Object
    class ReportGenerator {
        private $data;

        public function generateReport() {
            $reportCalculation = new ReportCalculation($this->data);
            $reportCalculation->execute();
            // ... use the result from reportCalculation
        }
    }

    class ReportCalculation {
        private $data;
        private $temporaryResult; // Now a field of the method object

        public function __construct($data) {
            $this->data = $data;
        }

        public function execute() {
            // ... calculations using $this->data and setting $this->temporaryResult
        }

        public function getResult() {
            return $this->temporaryResult;
        }
    }
```


- `Move Field (to a more appropriate scope):` If the temporary field is truly only needed by a single method, refactor the code to make it a local variable within that method.

```php 
    // Before: Temporary field in a class
    class Processor {
        private $input;
        private $intermediateValue; // Temporary field

        public function processData() {
            // ... uses $this->input to calculate $this->intermediateValue
            // ... uses $this->intermediateValue
        }
    }

    // After: Move Field to local variable
    class Processor {
        private $input;

        public function processData() {
            $intermediateValue = $this->calculateIntermediateValue(); // Local variable
            // ... uses $intermediateValue
        }

        private function calculateIntermediateValue() {
            // ... calculations using $this->input
            return $calculatedValue;
        }
    }
```


- `Introduce Null Object` and integrate it in place of the conditional code which was used to check the temporary field values for existence.
	- Eliminates Null Checks: Reduces repetitive `if ($object !== null)` checks in client code.


```php
interface Logger
{
	public function log(string $message);
}
    
class FileLogger implements Logger
{
	public function log(string $message)
	{
		// Logic to write the message to a file
		echo "Logging to file: " . $message . PHP_EOL;
	}
}

class NullLogger implements Logger
{
	public function log(string $message)
	{
		// Do nothing
	}
}


//Usage
function getLogger(bool $enableLogging): Logger
{
	if ($enableLogging) {
		return new FileLogger();
	} else {
		return new NullLogger();
	}
}
    
```

#### Refused Bequest

A Refused Bequest occurs when a subclass inherits behavior or properties from its superclass that it doesn’t need or want.

- **Empty or trivial method overrides:** A subclass might override a method from its parent, but the implementation is empty or performs minimal, irrelevant actions.

- **Violation of the Liskov Substitution Principle (LSP):**  The subclass cannot be seamlessly substituted for the parent class without unexpected behavior, as it fundamentally "refuses" parts of the parent's contract.

**`Solution`**

- `Rethink the hierarchy:`  If the "is-a" relationship is not strong, consider alternative design patterns.
    
- `Favor composition over inheritance:`  Instead of inheriting, the subclass can contain an instance of the parent class and delegate specific tasks to it.
    
- `Extract shared logic:`  If only a subset of the parent's functionality is truly needed, extract that into a separate interface or trait that the subclass can implement or use.
    
- `Remove dead code:` If inherited methods or properties are truly never used, and the inheritance is not serving a valid purpose, consider removing the inheritance entirely or refactoring the parent class.

#### Alternative Classes with Different Interfaces

Occurs when two or more classes perform substantially the same functions but have different public interfaces (i.e., different method names or signatures). This makes the code less readable, harder to maintain, and increases coupling as client code needs to understand multiple abstractions for similar tasks.

- Client code that interacts with these classes needs to know the specific class type to call the correct method, leading to `if/else` or `switch` statements based on class type.


**`Reasons`** 
- A new class was created without realizing a functionally equivalent one already existed.
- Different developers implemented similar functionality independently, leading to variations in naming conventions.
- Over time, functionality was moved or refactored, but the interfaces were not unified.

**`Solution`**

- Introduce a Common Interface or Abstract Superclass:
    - `Interface:` If the classes share only behavior (methods), define a common interface that both classes implement. This forces them to adhere to a consistent contract.
    - `Abstract Class:` If the classes also share common state (properties) or default implementations, create an abstract superclass that defines the common methods and potentially provides default implementations. The alternative classes then extend this abstract class.
    - `Extract Method/Class:` If only parts of the classes' functionality are duplicated, extract the common logic into a new method or even a separate class, and then delegate to it from the original classes.

```php
    // Original code smell:
    class FileLogger {
        public function logMessage(string $message) { /* ... */ }
    }

    class DatabaseLogger {
        public function writeLog(string $logEntry) { /* ... */ }
    }

    // Refactored with an Interface:
    interface LoggerInterface {
        public function log(string $message);
    }

    class FileLogger implements LoggerInterface {
        public function log(string $message) {
            // Implementation for logging to a file
        }
    }

    class DatabaseLogger implements LoggerInterface {
        public function log(string $message) {
            // Implementation for logging to a database
        }
    }
```


### Change Preventers

Change Preventers are a type of code smell that make it difficult to modify code without introducing unintended side effects.

Change Preventers are code elements that make it difficult to change code in one place without making many changes elsewhere. They often introduce tight coupling and dependencies that make the codebase brittle and hard to maintain.


- **Divergent Changes:** When different parts of the codebase are evolving independently, making it difficult to merge changes and maintain consistency.

- **Shotgun Surgery:** Making any modifications requires that you make many small changes to many different classes.

- **Parallel Inheritance Hierarchies:** Whenever you create a subclass for a class, you find yourself needing to create a subclass for another class.

#### Divergent Change

You find yourself having to change many unrelated methods when you make changes to a class. For example, when adding a new product type you have to change the methods for finding, displaying, and ordering products.

Code smell that occurs when a single class has multiple reasons to change, meaning that changes to different parts of the system require modifications within the same class. This violates the Single Responsibility Principle, which states that a class should have only one reason to change.

**`Example`**

A `Product` class that handles both product data storage and display formatting:

```php
class Product {
    private $id;
    private $name;
    private $price;
    private $description;

    public function __construct($id, $name, $price, $description) {
        $this->id = $id;
        $this->name = $name;
        $this->price = $price;
        $this->description = $description;
    }

    public function saveToDatabase() {
        // Logic to insert/update product in the database
        // e.g., using PDO or an ORM
    }

    public function getFormattedPrice() {
        // Logic to format the price for display
        return '$' . number_format($this->price, 2);
    }

    public function getHtmlDescription() {
        // Logic to format description for HTML display
        return '<p>' . htmlspecialchars($this->description) . '</p>';
    }

    // ... other methods related to product data and display
}
```

the `Product` class exhibits Divergent Change:

- Changes to how products are stored (e.g., switching database systems) would require modifying `saveToDatabase()`.
- Changes to how prices are displayed (e.g., adding currency symbols or different formatting rules) would require modifying `getFormattedPrice()`.
- Changes to how descriptions are presented in HTML would require modifying `getHtmlDescription()`.

**`Solution`**

The primary solution is to apply the **Extract Class** refactoring technique, separating the distinct responsibilities into their own classes. 
For instance, in the example above, you could create a 
- `ProductRepository` for database operations 
- `ProductFormatter` for display logic. 
This ensures that each class has a single, well-defined responsibility and changes to one concern do not affect others.


#### Shotgun Surgery

Making any modifications requires that you make many small changes to many different classes.

> _Shotgun Surgery_ resembles **Divergent Change** but is actually the opposite smell. _Divergent Change_ is when many changes are made to a single class. _Shotgun Surgery_ refers to when a single change is made to multiple classes simultaneously.


- **Scattered Responsibility:**  A specific piece of functionality or a business rule is implemented across several classes, rather than being encapsulated within a single, cohesive unit.
    
- **Ripple Effect of Changes:**  A seemingly minor change to one aspect of the system requires modifications in many different, seemingly unrelated files.
    
- **Increased Maintenance Effort:**  Adding new features or fixing bugs becomes time-consuming and prone to errors because changes need to be applied consistently in multiple locations.
    
- **Difficulty in Testing:**  Testing becomes more complex as changes in one area can have unforeseen impacts on other parts of the system.

**`Example`**

- If the logging mechanism or the email sending method needs to change (e.g., switching from `echo` to a file-based logger or a different email service), you would need to modify `logActivity` and `sendNotificationEmail` in both `OrderProcessor` and `PaymentProcessor`, and potentially other classes.

```php
class OrderProcessor
{
    public function processOrder(array $orderData)
    {
        // ... some order processing logic ...

        $this->logActivity("Order processed: " . $orderData['orderId']);
        $this->sendNotificationEmail("Order processed successfully for " . $orderData['customerEmail']);
        $this->updateInventory($orderData['items']);
    }

    private function logActivity(string $message)
    {
        // Logging logic specific to OrderProcessor
        echo "LOG: " . $message . "\n";
    }

    private function sendNotificationEmail(string $message)
    {
        // Email sending logic specific to OrderProcessor
        echo "EMAIL: " . $message . "\n";
    }

    private function updateInventory(array $items)
    {
        // Inventory update logic specific to OrderProcessor
        echo "INVENTORY: Updated for items: " . implode(", ", array_keys($items)) . "\n";
    }
}

class PaymentProcessor
{
    public function processPayment(array $paymentData)
    {
        // ... some payment processing logic ...

        $this->logActivity("Payment processed: " . $paymentData['transactionId']);
        $this->sendNotificationEmail("Payment confirmation for " . $paymentData['customerEmail']);
    }

    private function logActivity(string $message)
    {
        // Duplicated logging logic
        echo "LOG: " . $message . "\n";
    }

    private function sendNotificationEmail(string $message)
    {
        // Duplicated email sending logic
        echo "EMAIL: " . $message . "\n";
    }
}

// Imagine similar logging/notification logic in other classes like ShippingProcessor, etc.

```

**`Solution`**

- The responsibilities for logging, notifications, and inventory management are extracted into dedicated classes (`Logger`, `Notifier`, `InventoryManager`). Now, if the logging mechanism needs to change, only the `Logger` class needs modification, demonstrating a reduction in coupling and eliminating the Shotgun Surgery smell.

```php
class Logger
{
    public function log(string $message)
    {
        // Centralized logging logic
        echo "GLOBAL LOG: " . $message . "\n";
    }
}

class Notifier
{
    public function sendEmail(string $recipient, string $subject, string $body)
    {
        // Centralized email sending logic
        echo "GLOBAL EMAIL to " . $recipient . ": " . $subject . " - " . $body . "\n";
    }
}

class InventoryManager
{
    public function update(array $items)
    {
        // Centralized inventory update logic
        echo "GLOBAL INVENTORY: Updated for items: " . implode(", ", array_keys($items)) . "\n";
    }
}

class OrderProcessorRefactored
{
    private Logger $logger;
    private Notifier $notifier;
    private InventoryManager $inventoryManager;

    public function __construct(Logger $logger, Notifier $notifier, InventoryManager $inventoryManager)
    {
        $this->logger = $logger;
        $this->notifier = $notifier;
        $this->inventoryManager = $inventoryManager;
    }

    public function processOrder(array $orderData)
    {
        // ... some order processing logic ...

        $this->logger->log("Order processed: " . $orderData['orderId']);
        $this->notifier->sendEmail($orderData['customerEmail'], "Order Confirmation", "Your order has been processed.");
        $this->inventoryManager->update($orderData['items']);
    }
}

class PaymentProcessorRefactored
{
    private Logger $logger;
    private Notifier $notifier;

    public function __construct(Logger $logger, Notifier $notifier)
    {
        $this->logger = $logger;
        $this->notifier = $notifier;
    }

    public function processPayment(array $paymentData)
    {
        // ... some payment processing logic ...

        $this->logger->log("Payment processed: " . $paymentData['transactionId']);
        $this->notifier->sendEmail($paymentData['customerEmail'], "Payment Confirmation", "Your payment has been confirmed.");
    }
}
```

### Parallel Inheritance Hierarchies

A code smell that occurs when you have two separate class hierarchies that mirror each other, and for every class in one hierarchy, there's a corresponding class in the other. This often happens when one hierarchy depends on the other through composition. The key characteristic is that when you add a new class to one hierarchy, you almost always need to add a corresponding new class to the other.


**`Example`**

- We have a hierarchy of `Shape` classes (e.g., `Circle`, `Square`, `Triangle`) and a parallel hierarchy of `ShapeRenderer` classes (e.g., `CircleRenderer`, `SquareRenderer`, `TriangleRenderer`).



```php
// Shape Hierarchy
abstract class Shape {
    abstract public function getArea(): float;
}

class Circle extends Shape {
    public function __construct(private float $radius) {}
    public function getArea(): float { return M_PI * $this->radius * $this->radius; }
}

class Square extends Shape {
    public function __construct(private float $side) {}
    public function getArea(): float { return $this->side * $this->side; }
}

// ShapeRenderer Hierarchy
abstract class ShapeRenderer {
    abstract public function render(Shape $shape): string;
}

class CircleRenderer extends ShapeRenderer {
    public function render(Shape $shape): string {
        if (!($shape instanceof Circle)) {
            throw new InvalidArgumentException("Expected Circle instance.");
        }
        return "Rendering a circle with radius " . $shape->getRadius(); // Assuming getRadius() exists in Circle
    }
}

class SquareRenderer extends ShapeRenderer {
    public function render(Shape $shape): string {
        if (!($shape instanceof Square)) {
            throw new InvalidArgumentException("Expected Square instance.");
        }
        return "Rendering a square with side " . $shape->getSide(); // Assuming getSide() exists in Square
    }
}
```


**`Solution`**

- **Consolidate Hierarchies:**  Merge the responsibilities of the parallel hierarchies into a single hierarchy. For instance, move the rendering logic directly into the `Shape` classes.
    
- **Introduce a Strategy Pattern:**  Decouple the rendering logic from the `Shape` classes by using a strategy pattern where `Shape` objects are composed with a `Renderer` interface, allowing different rendering strategies to be injected.
    
- **Reduce One Hierarchy:**  If one hierarchy is significantly simpler, consider reducing it to a single class that can handle different types from the other hierarchy (e.g., a single `Renderer` class that uses `instanceof` checks or a visitor pattern to handle different `Shape` types).


### Dispensables

Dispensable code elements are those that can be removed without affecting the functionality of the application. They often include:

- **Unnecessary Comments:** Comments that don’t add value or are outdated.
- **Duplicate Code:** Code that is repeated in multiple places.
- **Lazy Class:** Understanding and maintaining classes always costs time and money. So if a class doesn’t do enough to earn your attention, it should be deleted.
- **Data Class:** A data class refers to a class that contains only fields and crude methods for accessing them (getters and setters). These are simply containers for data used by other classes. These classes don’t contain any additional functionality and can’t independently operate on the data that they own.
- **Dead Code:** Methods, variables, or classes that are never used.
- **Speculative Generality:** There’s an unused class, method, field or parameter.
- **Magic Numbers:** Hard-coded numerical values that are not defined as constants.

#### Comments
A method is filled with explanatory comments.
> The best comment is a good name for a method or class.


If you feel that a code fragment can’t be understood without comments, try to change the code structure in a way that makes comments unnecessary.


**`When to Ignore`**

Comments can sometimes be useful:

- When explaining **why** something is being implemented in a particular way.
    
- When explaining complex algorithms (when all other methods for simplifying the algorithm have been tried and come up short).

### Duplicate Code

A code smell indicating the presence of identical or very similar code segments in multiple locations. This can manifest in various ways, from direct copy-pasting to repetitive code structures or parallel inheritance hierarchies.

- **Increased Maintenance Burden:**  Any change or bug fix needs to be applied in every instance of the duplicated code, increasing the risk of errors and inconsistencies.
    
- **Reduced Readability:**  Repeated logic makes the codebase longer and harder to follow, hindering understanding.
    
- **Higher Bug Potential:**  More code means more opportunities for bugs to be introduced, and changes in one duplicated section might not be reflected in others, leading to unexpected behavior.
    
- **Violation of DRY Principle:**  It goes against the "Don't Repeat Yourself" (DRY) principle, a fundamental concept in software development.

**`Solution`**

- **Extract Method/Function:** Encapsulate the duplicated logic into a reusable function or method, and then call this function/method from all locations where the logic is needed.

```php
    // Original code with duplication
    $totalApplesPrice = $quantityApples * $priceApple - 5;
    $totalBananasPrice = $quantityBananas * $priceBanana - 5;

    // Refactored using a function
    function calculateTotalPrice($quantity, $price) {
        return $quantity * $price - 5;
    }

    $totalApplesPrice = calculateTotalPrice($quantityApples, $priceApple);
    $totalBananasPrice = calculateTotalPrice($quantityBananas, $priceBanana);
```

- **Pull Up Method/Field:**  If duplicate code exists in subclasses, move the common method or field to a common superclass.
    
- **Form Template Method:**  If the duplicate code is similar but not entirely identical, consider using the Template Method design pattern to define the overall algorithm in a base class and allow subclasses to override specific steps.
    
- **Use Traits:**  PHP traits can be used to group methods and properties that can be included in multiple classes, providing a mechanism for code reuse without requiring inheritance.

### Lazy Class

Refers to a class that does not pull its weight or provide enough value to justify its existence. It typically represents a class with minimal responsibilities or functionality, often acting as a mere data holder or having very few methods.

- **Few Methods or Responsibilities:**  The class has a very limited number of methods, often just simple getters and setters, and doesn't perform complex operations or encapsulate significant logic.
    
- **Data Class:**  It primarily serves as a container for data, with little to no behavior or operations performed on that data within the class itself. Other classes manipulate its data.
    
- **Empty Constructor or Trivial Initialization:**  The constructor might be empty or perform only basic property assignments without any significant setup or resource allocation.
    
- **Simple Delegation:**  The class might simply delegate calls to another class without adding any unique value or transformation.
    
- **Low Cohesion:**  The few methods it does have are not strongly related or don't form a cohesive unit of responsibility.

**`Example`**

- The `Address` class is a potential "Lazy Class." While it encapsulates address details, its primary function is merely to store and format address information. If the application's needs for address management are consistently simple and don't involve complex operations, validations, or multiple behaviors related to addresses, then the `Address` class might be considered lazy.

```php

class Address
{
    private string $street;
    private string $city;
    private string $zipCode;

    public function __construct(string $street, string $city, string $zipCode)
    {
        $this->street = $street;
        $this->city = $city;
        $this->zipCode = $zipCode;
    }

    public function getFullAddress(): string
    {
        return "{$this->street}, {$this->city} {$this->zipCode}";
    }
}

class User
{
    private string $name;
    private string $email;
    private Address $address; // The Address class is used here

    public function __construct(string $name, string $email, Address $address)
    {
        $this->name = $name;
        $this->email = $email;
        $this->address = $address;
    }

    public function getUserDetails(): string
    {
        return "Name: {$this->name}, Email: {$this->email}, Address: {$this->address->getFullAddress()}";
    }
}
```

**`Solution`**

- The address details are directly managed within the `User` class, eliminating the need for a separate `Address` class if its responsibilities are truly minimal. This reduces the number of classes and potentially simplifies the codebase if the `Address` class offers no significant independent value.


### Data Class

When a class primarily serves as a container for data, exposing its internal state through public properties or simple getters and setters, but lacks significant behavior or methods that operate on that data. This often indicates a violation of the "**Tell, Don't Ask**" principle of object-oriented programming.

- **Lack of Behavior:**  The class has few or no methods that perform operations or encapsulate logic related to its data.
    
- **Excessive Getters and Setters:**  it primarily consists of public properties or simple getter and setter methods to access and modify its internal state.
    
- **External Manipulation:**  Other classes frequently access and manipulate the data within the data class, leading to tight coupling and potential for inconsistent state.
    
- **Violation of Encapsulation:**  The internal data is not adequately protected, and its structure is exposed to the outside world.

**`Example`**

```php
class UserData // Data Class Smell
{
    public $id;
    public $firstName;
    public $lastName;
    public $email;

    public function __construct($id, $firstName, $lastName, $email)
    {
        $this->id = $id;
        $this->firstName = $firstName;
        $this->lastName = $lastName;
        $this->email = $email;
    }
}
```

**`Solution`

- **Encapsulate Behavior:**  Move methods and logic that operate on the data into the data class itself.
    
- **Apply "Tell, Don't Ask":**  Instead of getting data and then acting on it, tell the object to perform the action.
    
- **Consider Value Objects:**  If the class represents a simple immutable value, consider making it a Value Object with no setters and with methods that return new instances upon modification.
    
- **Refactor to Richer Objects:**  Identify opportunities to create more meaningful objects that encapsulate both data and behavior.

```php
class User // Richer Object
{
    private int $id;
    private string $firstName;
    private string $lastName;
    private string $email;

    public function __construct(int $id, string $firstName, string $lastName, string $email)
    {
        $this->id = $id;
        $this->firstName = $firstName;
        $this->lastName = $lastName;
        $this->email = $email;
    }

    public function getFullName(): string
    {
        return $this->firstName . ' ' . $this->lastName;
    }

    public function getEmail(): string
    {
        return $this->email;
    }

    // Other methods related to user behavior
    // public function changeEmail(string $newEmail): void { ... }
}
```


### Dead Code

Dead code is a prominent code smell, It refers to code segments, such as variables, parameters, methods, or even entire classes, that are no longer used or reachable within the application's execution flow.

- **Unused variables or parameters:**  Variables declared but never read, or function parameters that are passed but never referenced inside the function body.
    
- **Unreachable code blocks:**  Code within conditional statements (e.g., `if`, `else if`, `switch`) where the condition is always `false` or a preceding `return` or `exit` statement prevents execution.
    
- **Obsolete methods or classes:**  Functions or classes that were part of older functionality but are no longer called or instantiated by any active part of the codebase.
    
- **Unused files:**  Entire PHP files containing code that is no longer included or required by the application.

**`Impact`**

- **Codebase clutter:**  Dead code makes the codebase larger and more difficult to navigate and understand.
    
- **Increased maintenance burden:**  Developers might waste time analyzing or trying to understand dead code during debugging or feature development.
    
- **Potential for confusion:**  Dead code can lead to confusion for new contributors or even for the original developers if they revisit the code after a long time.
    

**`Solution`**

- **Deletion:**  The most straightforward solution is to simply remove the dead code.
    
- **IDE features:**  Modern IDEs often highlight unused variables, methods, or parameters, making detection easier.
    
- **Static analysis tools:**  Tools like PHP Mess Detector (PHPMD) or PHPStan can identify potential dead code and other code smells.
    
- **Code reviews:**  Peer code reviews can help identify dead code that might have been missed by automated tools or individual developers.
    
- **Test coverage analysis:**  Tools like xdebug profiler can show which parts of the code are actually being executed during testing, highlighting potentially dead sections.

### Speculative Generality

Refers to code written "just in case" for anticipated future needs that may never materialize. This leads to unnecessary complexity, making the code harder to understand, maintain, and support.


- **Unused classes, methods, fields, or parameters:**  You might find classes, methods, or properties defined with the intention of being used later for a more generic purpose, but they remain unutilized.
    
- **Overly abstract or complex designs for simple tasks:**  A simple operation might be implemented with multiple layers of abstraction (interfaces, abstract classes, factories) when a direct, simpler approach would suffice.
    
- **Excessive use of design patterns where not strictly needed:**  While design patterns are valuable, their over-application, especially for speculative future features, can lead to Speculative Generality.
    
- **Code that is difficult to understand or modify due to its generic nature:**  The code might be designed to handle many different scenarios, but in practice, only a few are ever used, making the code unnecessarily complex for its actual purpose.

**`Example`***

```php
// Speculative Generality: Creating a highly generic logging interface
// and multiple implementations when only a simple file logger is needed
// and no other logging mechanisms are anticipated in the near future.

interface LoggerInterface
{
    public function log(string $message, string $level = 'info'): void;
}

class FileLogger implements LoggerInterface
{
    private string $filePath;

    public function __construct(string $filePath)
    {
        $this->filePath = $filePath;
    }

    public function log(string $message, string $level = 'info'): void
    {
        file_put_contents($this->filePath, "[{$level}] {$message}\n", FILE_APPEND);
    }
}

class DatabaseLogger implements LoggerInterface
{
    // ... potentially complex database logging logic, but currently unused
    public function log(string $message, string $level = 'info'): void
    {
        // Not implemented or used yet
        // echo "Logging to database: [{$level}] {$message}\n";
    }
}

```


**`Solution`**

- **Remove unused code:**  Delete any classes, methods, fields, or parameters that are not currently used and are not definitively planned for immediate future use.
    
- **Simplify abstractions:**  If a simpler design can achieve the current requirements without sacrificing maintainability, refactor overly complex or generic structures to be more direct.
    
- **Apply refactoring techniques like Inline Class, Inline Method, or Remove Parameter:**  These can help reduce unnecessary indirection and complexity introduced by speculative design.
    
- **Prioritize YAGNI (You Ain't Gonna Need It):**  Only implement features and abstractions when they are actually required, rather than anticipating future needs prematurely.


### Couplers

Couplers are code elements that create a tight coupling between different parts of your application.

- **Feature Envy:** A method accesses the data of another object more than its own data.

- **Inappropriate Intimacy:** One class uses the internal fields and methods of another class.

- **Message Chains:** In code you see a series of calls resembling `$a->b()->c()->d()`

- **Middle Man:** If a class performs only one action, delegating work to another class, why does it exist at all?


#### Feature Envy

Is a code smell where a method in one class appears to be more interested in the data or behavior of another class than its own. This often manifests as a method frequently accessing or manipulating the properties and methods of an external object.


- **Excessive Use of Another Object's Data:**  A method within one class repeatedly accesses properties or calls methods belonging to a different class instance.
    
- **Violation of the Law of Demeter:**  This smell often violates the Law of Demeter ("Don't talk to strangers"), which suggests that an object should only interact with its immediate friends and not navigate through a chain of objects to access data or functionality.
    
- **High Coupling:**  It leads to tight coupling between classes, making the code harder to understand, test, and maintain. Changes in the "envied" class might require changes in the "envious" class, even if the core functionality of the envious class hasn't changed.
    
- **Reduced Encapsulation:**  It can indicate a breakdown in encapsulation, as the internal details of one object are being directly manipulated by another.


**`Example`**

- The `calculateTotal` method in `OrderProcessor` exhibits Feature Envy because it extensively accesses the `items` and `taxRate` from the `Order` object to perform its calculation.

```php
class Order
{
    private array $items;
    private float $taxRate;

    public function __construct(array $items, float $taxRate)
    {
        $this->items = $items;
        $this->taxRate = $taxRate;
    }

    public function getItems(): array
    {
        return $this->items;
    }

    public function getTaxRate(): float
    {
        return $this->taxRate;
    }
}

class OrderProcessor
{
    public function calculateTotal(Order $order): float
    {
        $total = 0;
        foreach ($order->getItems() as $item) { // Feature Envy: Accessing Order's items
            $total += $item['price'] * $item['quantity'];
        }
        $total += $total * $order->getTaxRate(); // Feature Envy: Accessing Order's taxRate
        return $total;
    }
}
```


**`Solution`**

The `Order` class itself should ideally be responsible for calculating its own total.

- **Move Method:**  The most common solution is to move the "envious" method, or parts of it, to the class whose data it is primarily using. In the example above, the `calculateTotal` method could be moved into the `Order` class.
    
- **Extract Method:**  If only a portion of a method exhibits Feature Envy, extract that part into a new method and then move the new method to the appropriate class.
    
- **Introduce Middle Man (or Delegate):**  If direct access to internal data is necessary but moving the entire method is not feasible, consider introducing a middleman object or delegating the responsibility to the appropriate class.


#### Inappropriate Intimacy

Inappropriate Intimacy is a code smell that describes a situation where two classes are excessively and mutually dependent on each other, often leading to tight coupling and reduced modularity. This means they know too much about each other's internal workings, rather than interacting through well-defined interfaces.


- **Bi-directional dependency:**  Both classes rely heavily on the methods and/or fields of the other.
    
- **Encapsulation violation:**  One or both classes may directly access the internal state (private or protected members) of the other, bypassing public methods.
    
- **Difficulty in maintenance and modification:**  Changes in one class often necessitate changes in the other, making refactoring and evolution challenging.
    
- **Reduced reusability and testability:**  The tight coupling makes it difficult to reuse or test either class in isolation.


**`Example`**

- Consider a `Customer` class and an `Order` class, where the `Customer` class directly manipulates the internal `items` array of an `Order` object, and the `Order` class directly accesses the `email` property of a `Customer` object for notification purposes.


```php 
class Customer {
    private $email;
    // ... other properties and methods

    public function __construct(string $email) {
        $this->email = $email;
    }

    public function getEmail(): string {
        return $this->email;
    }

    // This method exhibits inappropriate intimacy
    public function placeOrder(Order $order, array $items) {
        // Directly manipulating the order's internal state
        foreach ($items as $item) {
            $order->addItem($item); // Assuming addItem is public, but still intimate if it reveals too much
        }
        echo "Order placed by " . $this->email . "\n";
    }
}

class Order {
    private $items = [];
    private $customer; // Reference to Customer

    public function __construct(Customer $customer) {
        $this->customer = $customer;
    }

    public function addItem(string $item) {
        $this->items[] = $item;
    }

    // This method exhibits inappropriate intimacy
    public function notifyCustomer() {
        // Directly accessing customer's private property or relying on a getter for a specific purpose
        echo "Notifying customer at " . $this->customer->getEmail() . " about order details.\n";
    }
}
```

**``Solution**


- **Move Method/Field:**  Relocate methods or fields to the class where they are more appropriately used.
    
- **Extract Class:**  Create a new class to encapsulate the shared or highly coupled functionality.
    
- **Change Bidirectional Association to Unidirectional:**  Restructure the relationship so that one class depends on the other, but not vice versa, or introduce an intermediary.
    
- **Introduce an Interface:**  Define a clear contract for interaction between the classes, promoting loose coupling.




#### Message Chains

Refers to a sequence of method calls where a client requests an object, that object requests another, and so on, creating a long chain of dependencies to reach a final object or piece of data. This typically looks like `objectA->getObjectB()->getObjectC()->getData()`.


- **Tight Coupling:**  The client code becomes tightly coupled to the internal structure and relationships of several intermediate objects. Any change in the intermediate object relationships or their methods requires modification in the client code.
    
- **Reduced Robustness:**  If any object in the chain returns `null` or an unexpected value, the entire chain can break, leading to runtime errors.
    
- **Lower Testability:**  Testing code with message chains can be more complex as it requires setting up multiple interconnected objects and their states.



**`Example`**

- In this example, the `Employee` class needs to access a setting from the `Config` class, but it does so through `EmployeeConfig`, creating a message chain.

```php
class Config
{
    public function getSetting(string $key): string
    {
        return "value_for_" . $key;
    }
}

class EmployeeConfig
{
    private Config $config;

    public function __construct(Config $config)
    {
        $this->config = $config;
    }

    public function getEmployeeSetting(string $key): string
    {
        return $this->config->getSetting($key);
    }
}

class Employee
{
    private EmployeeConfig $employeeConfig;

    public function __construct(EmployeeConfig $employeeConfig)
    {
        $this->employeeConfig = $employeeConfig;
    }

    public function getPayrollData(): string
    {
        // Message chain: Employee -> EmployeeConfig -> Config
        return $this->employeeConfig->getEmployeeSetting("payroll");
    }
}

// Usage
$config = new Config();
$employeeConfig = new EmployeeConfig($config);
$employee = new Employee($employeeConfig);
$payrollData = $employee->getPayrollData();
echo $payrollData;
```

**`Solution`**

- **Hide Delegate:**  Encapsulate the chain within one of the intermediate objects, exposing only the necessary functionality directly to the client.
    
- **Move Method:**  Move the method that needs the data closer to the data itself, potentially eliminating intermediate calls.
    
- **Extract Method:**  Extract the logic involving the message chain into a new, well-named method within one of the involved classes, improving clarity and potentially enabling further refactoring.
    
- **Introduce Parameter Object:**  If the chain is used to pass multiple related values, consider encapsulating them in a dedicated parameter object.


#### Middle Man

 Refers to a class that primarily serves as a delegate, passing calls to other objects without adding significant value or logic itself. This class acts as an unnecessary intermediary, increasing complexity and making the code harder to understand and maintain.

- A class whose methods largely consist of simply calling methods on another object.
- It adds a layer of indirection without providing any meaningful abstraction or transformation of data or behavior.
- Changes in the underlying delegated class often require changes in the Middle Man, creating an unnecessary dependency.

**`Example`**

- Consider a scenario where an `OrderController` class directly calls a method on an `OrderService` class:

```php
class OrderService
{
    public function processOrder(array $data)
    {
        // Logic to process the order
        echo "Order processed: " . json_encode($data) . "\n";
    }
}

class OrderController
{
    private OrderService $orderService;

    public function __construct(OrderService $orderService)
    {
        $this->orderService = $orderService;
    }

    public function handleOrderRequest(array $requestData)
    {
        // The OrderController simply delegates to OrderService
        $this->orderService->processOrder($requestData);
    }
}

// Usage
$orderService = new OrderService();
$orderController = new OrderController($orderService);
$orderController->handleOrderRequest(['item' => 'Book', 'quantity' => 1]);
```

-  if `handleOrderRequest` in `OrderController` does nothing more than call `processOrder` on `OrderService`, then `OrderController` is acting as a Middle Man.


**`Solution`**

By removing the `OrderController` as a Middle Man, the code becomes more straightforward and easier to understand, as the client directly interacts with the service responsible for processing orders. This reduces indirection and improves the clarity of the code's intent.


```php
class OrderService
{
    public function processOrder(array $data)
    {
        // Logic to process the order
        echo "Order processed: " . json_encode($data) . "\n";
    }
}

// Client code directly uses OrderService
$orderService = new OrderService();
$orderService->processOrder(['item' => 'Book', 'quantity' => 1]);
```


## PHP 5,  PHP 7, PHP 8 

PHP 5, PHP 7, and PHP 8 represent significant evolutionary steps in the PHP language, each introducing new features and performance improvements.

It is important to know each major version specific features!

### PHP 5 (PHP 5.6):

- **Object-Oriented Programming (OOP) improvements:** Introduced features like `abstract classes`, `interfaces`, `final keywords`, and improved `object cloning`.
- **Namespaces:** Provided a way to organize code and prevent naming conflicts.
- **Generators:** Allowed for easier iteration over large datasets without loading them entirely into memory.
- **Improved error handling:** Introduced `try-catch` blocks for exceptions.
- **Built-in JSON support:** Offered native functions for encoding and decoding JSON data.


### PHP 7 (PHP 7.4):

- **Significant performance improvements (PHPNG engine):** Made PHP applications considerably faster and more memory-efficient than PHP 5.
- **Scalar type declarations:** Allowed for type hinting of scalar types (`int, float, string, bool`) for function parameters and return values.


## Tools

There are several tools available that can help you refactor PHP code more efficiently. Some of the most popular tools include:

- **PhpStorm**: A popular IDE for PHP development that includes built-in refactoring tools and code analysis features.
- **PHPStan**: A static analysis tool that can help you find bugs and unused code in your PHP code.
- **PHP_CodeSniffer**: A tool that can detect violations of a defined coding standard and help you fix them (with its version compatibility checker).
- **PHPCPD** (PHP Copy/Paste Detector) can help identify duplicate code segments within a PHP project.
- **PHPMD** :  PHP Mess Detector, static analysis designed to identify "code smells" and potential problems within a PHP codebase without executing the code.
- **Rector**: A PHP refactoring tool that can automatically fix code issues and apply best practices.
- `F2` key in `VsCode`: it renames all local variables, constants, functions, classes ... in the whole project
- Using **AI** to assist you in the refactoring process

These tools are covered in details in the folder `Tools`
## Reminder

Despite favoring refactoring in most cases, complete rewrites can be justified when **the technology stack is truly obsolete** (e.g., PHP 5.3 or earlier), business requirements have fundamentally changed, the application needs to serve dramatically different purposes, or the current architecture simply cannot support essential new features. 


## Resources
[Refactoring PHP](https://christoph-rumpel.com/category/php)
[PHP Code Refactoring](https://tsh.io/blog/php-code-refactoring/)
[Rewriting Vs Refactoring Legacy PHP](https://sensiolabs.com/blog/2025/rewriting-vs-refactoring-legacy-php)
