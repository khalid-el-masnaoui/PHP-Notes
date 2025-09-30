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

### Use explanatory variables

```php
$address = 'One Infinite Loop, Cupertino 95014';
$cityZipCodeRegex = '/^[^,]+,\s*(.+?)\s*(\d{5})$/';
preg_match($cityZipCodeRegex, $address, $matches);

// BAD
saveCityZipCode($matches[1], $matches[2]);

// GOOD
[, $city, $zipCode] = $matches; 
saveCityZipCode($city, $zipCode);


// BETTER
// USE NAMED REGEX GROUPs
saveCityZipCode($matches['city'], $matches['zipCode']);
```

### Avoid nesting too deeply

```php 
// BAD
function isShopOpen($day): bool
{
    if ($day) {
        if (is_string($day)) {
            $day = strtolower($day);
            if ($day === 'friday') {
                return true;
            } elseif ($day === 'saturday') {
                return true;
            } elseif ($day === 'sunday') {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
    } else {
        return false;
    }
}

// GOOD
function isShopOpen(string $day): bool
{
    if (empty($day)) {
        return false;
    }

    $openingDays = [
        'friday', 'saturday', 'sunday'
    ];

    return in_array(strtolower($day), $openingDays, true);
}
```

### Avoid Mental Mapping

Don’t force the reader of your code to translate what the variable means. Explicit is better than implicit.


```php 
// BAD
$l = ['Austin', 'New York', 'San Francisco'];

for ($i = 0; $i < count($l); $i++) {
    $li = $l[$i];
    doStuff();
}

// GOOD
$locations = ['Austin', 'New York', 'San Francisco'];

foreach ($locations as $location) {
    doStuff();
}
```

### Don't add unneeded context

If your class/object name tells you something, don't repeat that in your variable name.

```php 
// BAD
class Car
{
    public $carMake;
    public $carModel;
    public $carColor;

    //...
}

// GOOD
class Car
{
    public $make;
    public $model;
    public $color;

    //...
}
```

### Others
- **Avoid Abbreviations and Acronyms:**  
    Only use abbreviations that are widely understood. Avoid ambiguous short names like `$tmp` or `$val`.
- **Use Nouns for Classes, Verbs for Methods:**  
    Classes represent entities or concepts (nouns), while methods perform actions (verbs). For example, `UserRepository` (class) and `fetchUser()` (method).
- **Consistency Across the Codebase:**  
    Consistent naming patterns reduce cognitive load. Decide on naming conventions as a team and document them in your style guide


## Comparison

### Use identical comparison

```php 
// BAD
if ($a != $b || $c == $d) {
    //...
}

// GOOD
if ($a !== $b || $c === $d) {
    //...
}

```

### Null coalescing & Ternary operators

```php 
// BAD
if (isset($_GET['name'])) {
    $name = $_GET['name'];
} elseif (isset($_POST['name'])) {
    $name = $_POST['name'];
} else {
    $name = 'nobody';
}

// GOOD 
$name = $_GET['name'] ?? $_POST['name'] ?? 'nobody';
```

```php
// BAD
$value = "hello";
if ($value) {
    $result = $value;
} else {
    $result = "default";
}

// GOOD 
$result = $value ? $value : "default";

// BETTER
$result = $value ?: "default";
```


## Functions

### Function arguments (3 or fewer ideally)

If you have more than two/three arguments then your function is trying to do too much. In cases where it's not, most of the time a higher-level object will suffice as an argument.

```php
// BAD
class Questionnaire
{
    public function __construct(
        string $firstname,
        string $lastname,
        string $patronymic,
        string $region,
        string $district,
        string $city,
        string $phone,
        string $email
    ) {
        // ...
    }
}

// GOOD
class Questionnaire
{
    public function __construct(Name $name, City $city, Contact $contact)
    {
        // ...
    }
}

class Name
{
    private $firstname;
    private $lastname;
    private $patronymic;

    public function __construct(string $firstname, string $lastname, string $patronymic)
    {
        $this->firstname = $firstname;
        $this->lastname = $lastname;
        $this->patronymic = $patronymic;
    }

    // getters ...
}

class City
{
    private $region;
    private $district;
    private $city;

    public function __construct(string $region, string $district, string $city)
    {
        $this->region = $region;
        $this->district = $district;
        $this->city = $city;
    }

    // getters ...
}

class Contact
{
    private $phone;
    private $email;

    public function __construct(string $phone, string $email)
    {
        $this->phone = $phone;
        $this->email = $email;
    }

    // getters ...
}
```

### Function names should say what they do

```php
// BAD
class Email
{
    //...

    public function handle(): void
    {
        mail($this->to, $this->subject, $this->body);
    }
}

// GOOD
class Email
{
    //...

    public function send(): void
    {
        mail($this->to, $this->subject, $this->body);
    }
}

```

### Don't use flags as function parameters

Flags tell your user that this function does more than one thing. Functions should do one thing. Split out your functions if they are following different code paths based on a boolean.

```php 
// BAD
function createFile(string $name, bool $temp = false): void
{
    if ($temp) {
        touch('./temp/'.$name);
    } else {
        touch($name);
    }
}

// GOOD
function createFile(string $name): void
{
    touch($name);
}

function createTempFile(string $name): void
{
    touch('./temp/'.$name);
}
```

### Avoid Side Effects

A side effect could be writing to a file, modifying some global variable..etc. For example, a function that has a side effect as writing to a file, what you want to do is to centralize where you are doing this. Don't have several functions and classes that write to a particular file. Have one service that does it. One and only one.

The main point is to avoid common pitfalls like sharing state between objects without any structure, using mutable data types that can be written to by anything, and not centralizing where your side effects occur. 

```php
// BAD
// If we had another function that used this name, now it'd be an array and it could break it.
$name = 'Ryan McDermott';

function splitIntoFirstAndLastName(): void
{
    global $name;

    $name = explode(' ', $name);
}

splitIntoFirstAndLastName();


// GOOD
function splitIntoFirstAndLastName(string $name): array
{
    return explode(' ', $name);
}

$name = 'Ryan McDermott';
$newName = splitIntoFirstAndLastName($name);
```

### Names should describe side effects

Names should describe everything that a function, variable, or class is or does. Don’t hide side effects with a name. Don’t use a simple verb to describe a function that does more than just that simple action.


```php
// BAD
public function getProfile(): Profile
{
    if ($this->profile === null) {
        $this->profile = new Profile($this);
        $this->save();
    }

    return $this->profile;
}

// GOOD
public function createOrReturnProfile(): Profile
{
    if ($this->profile === null) {
        $this->profile = new Profile($this);
        $this->save();
    }

    return $this->profile;
}
```

### Encapsulate conditionals

```php 
// BAD
if ($article->state === 'published') {
    // ...
}


// GOOD
if ($article->isPublished()) {
    // ...
}
```

### Avoid negative conditionals

```php
function isDOMNodeNotPresent(\DOMNode $node): bool
{
    // ...
}

if (!isDOMNodeNotPresent($node))
{
    // ...
}

// GOOD
function isDOMNodePresent(\DOMNode $node): bool
{
    // ...
}

if (isDOMNodePresent($node)) {
    // ...
}
```

### Avoid Conditionals (use Polymorphism)

```php
// BAD
class Airplane
{
    // ...

    public function getCruisingAltitude(): int
    {
        switch ($this->type) {
            case '777':
                return $this->getMaxAltitude() - $this->getPassengerCount();
            case 'Air Force One':
                return $this->getMaxAltitude();
            case 'Cessna':
                return $this->getMaxAltitude() - $this->getFuelExpenditure();
        }
    }
}

// GOOD
interface Airplane
{
    // ...

    public function getCruisingAltitude(): int;
}

class Boeing777 implements Airplane
{
    // ...

    public function getCruisingAltitude(): int
    {
        return $this->getMaxAltitude() - $this->getPassengerCount();
    }
}

class AirForceOne implements Airplane
{
    // ...

    public function getCruisingAltitude(): int
    {
        return $this->getMaxAltitude();
    }
}

class Cessna implements Airplane
{
    // ...

    public function getCruisingAltitude(): int
    {
        return $this->getMaxAltitude() - $this->getFuelExpenditure();
    }
}
```

Avoiding the object type checking 

```php 
// BAD
function travelToTexas($vehicle): void
{
    if ($vehicle instanceof Bicycle) {
        $vehicle->pedalTo(new Location('texas'));
    } elseif ($vehicle instanceof Car) {
        $vehicle->driveTo(new Location('texas'));
    }
}

// GOOD
function travelToTexas(Vehicle $vehicle): void
{
    $vehicle->travelTo(new Location('texas'));
}

```

### Avoid type-checking

If you are working with basic primitive values like strings, integers, and arrays, and you use PHP 7+ and you can't use polymorphism but you still feel the need to type-check, you should consider [type declaration](https://php.net/manual/en/functions.arguments.php#functions.arguments.type-declaration) or strict mode.

When working with basic primitive values like strings, integers, and arrays, polymorphism is not an option, instead you can use type-hinting and strict mode

```php
// BAD
function combine($val1, $val2): int
{
    if (!is_numeric($val1) || !is_numeric($val2)) {
        throw new \Exception('Must be of type Number');
    }

    return $val1 + $val2;
}

// GOOD
function combine(int $val1, int $val2): int
{
    return $val1 + $val2;
}
```


### Remove dead code

Dead code is just as bad as duplicate code. There's no reason to keep it in your codebase. If it's not being called, get rid of it! It will still be safe in your version history if you still need it.

```php

// BAD
function oldRequestModule(string $url): void
{
    // ...
}

function newRequestModule(string $url): void
{
    // ...
}

$request = newRequestModule($requestUrl);
inventoryTracker('apples', $request, 'www.inventory-awesome.io');


// GOOD
function requestModule(string $url): void
{
    // ...
}

$request = requestModule($requestUrl);
inventoryTracker('apples', $request, 'www.inventory-awesome.io');
```


## Classes and Objects

### Use object encapsulation

- When you want to do more beyond getting an object property, you don't have to look up and change every accessor in your codebase.
- Makes adding validation simple when doing a `set`.
- Encapsulates the internal representation.
- Easy to add logging and error handling when getting and setting.
- Inheriting this class, you can override default functionality.
- You can lazy load your object's properties, let's say getting it from a server.

```php

// BAD
class BankAccount
{
    public $balance = 1000;
}

$bankAccount = new BankAccount();

// Buy shoes...
$bankAccount->balance -= 100;

// GOOD
class BankAccount
{
    private $balance;

    public function __construct(int $balance = 1000)
    {
        $this->balance = $balance;
    }

    public function withdraw(int $amount): void
    {
        if ($amount > $this->balance) {
            throw new \Exception('Amount greater than available balance.');
        }

        $this->balance -= $amount;
    }

    public function deposit(int $amount): void
    {
        $this->balance += $amount;
    }

    public function getBalance(): int
    {
        return $this->balance;
    }
}

$bankAccount = new BankAccount();

// Buy shoes...
$bankAccount->withdraw($shoesPrice);

// Get balance
$balance = $bankAccount->getBalance();
```

### Make objects have private/protected members

- `public` methods and properties are most dangerous for changes, because some outside code may easily rely on them and you can't control what code relies on them. **Modifications in class are dangerous for all users of class.**
- `protected` modifier are as dangerous as public, because they are available in scope of any child class. This effectively means that difference between public and protected is only in access mechanism, but encapsulation guarantee remains the same. **Modifications in class are dangerous for all descendant classes.**
- `private` modifier guarantees that code is **dangerous to modify only in boundaries of single class** (you are safe for modifications, and you won't have [Jenga effect](https://www.urbandictionary.com/define.php?term=Jengaphobia&defid=2494196)).

Therefore, use `private` by default and `public/protected` when you need to provide access for external classes.


**Best Practices for Access Modifiers:**
- Favor the most restrictive visibility (start with `private`).
- Use `public` only for interface methods.
- Avoid public properties; use getters/setters.
- Use `protected` sparingly.


### Prefer composition over inheritance

You should prefer composition over inheritance where you can.

They are situations where inheritance makes more sense than composition:
1. Your inheritance represents an `is-a` relationship and not a `has-a` relationship (`Human->Animal` vs. `User->UserDetails`).
2. You can reuse code from the base classes (Humans can move like all animals).
3. You want to make global changes to derived classes by changing a base class. (Change the caloric expenditure of all animals when they move).


```php 
// BAD
class Employee
{
    private $name;
    private $email;

    public function __construct(string $name, string $email)
    {
        $this->name = $name;
        $this->email = $email;
    }

    // ...
}

// Bad because Employees "have" tax data.
// EmployeeTaxData is not a type of Employee

class EmployeeTaxData extends Employee
{
    private $ssn;
    private $salary;

    public function __construct(string $name, string $email, string $ssn, string $salary)
    {
        parent::__construct($name, $email);

        $this->ssn = $ssn;
        $this->salary = $salary;
    }

    // ...
}


// GOOD
class EmployeeTaxData
{
    private $ssn;
    private $salary;

    public function __construct(string $ssn, string $salary)
    {
        $this->ssn = $ssn;
        $this->salary = $salary;
    }

    // ...
}

class Employee
{
    private $name;
    private $email;
    private $taxData;

    public function __construct(string $name, string $email)
    {
        $this->name = $name;
        $this->email = $email;
    }

    public function setTaxData(EmployeeTaxData $taxData)
    {
        $this->taxData = $taxData;
    }

    // ...
}
```

### Prefer final classes

The `final` should be used whenever possible:

1. It prevents uncontrolled inheritance chain.
2. It encourages **composition**
3. It encourages the **Single Responsibility Pattern**
4. It encourages developers to use your public methods instead of extending the class to get access on protected ones.
5. It allows you to change your code without any break of applications that use your class.

The only condition is that your class should implement an interface and no other public methods are defined (for the **composition**)


```php 
// BAD
final class Car
{
    private $color;

    public function __construct($color)
    {
        $this->color = $color;
    }

    /**
     * @return string The color of the vehicle
     */
    public function getColor()
    {
        return $this->color;
    }
}


// GOOD
interface Vehicle
{
    /**
     * @return string The color of the vehicle
     */
    public function getColor();
}

final class Car implements Vehicle
{
    private $color;

    public function __construct($color)
    {
        $this->color = $color;
    }

    /**
     * {@inheritdoc}
     */
    public function getColor()
    {
        return $this->color;
    }
}
```


### Avoiding Unnecessary Try-Catch Blocks in Private Methods

While handling exceptions is essential, wrapping every private or helper method in try-catch blocks is usually unnecessary and leads to cluttered, harder-to-maintain code.

**`Why Avoid Try-Catch in Private Methods?`**
- **Private methods are internal implementation details.** Let exceptions bubble up to the public interface where they can be handled properly.
- Adding try-catch everywhere clutters the code, making it harder to read and maintain.
- Centralized error handling improves consistency and reduces duplication.
- Catching exceptions prematurely often leads to **silent failures** or improper error handling.

**`Best Practices`**
- Avoid placing try-catch blocks inside **private or helper methods** unless you can handle exceptions meaningfully at that level.
- Allow exceptions to **propagate to higher-level public methods** or centralized handlers.
- Use try-catch blocks in **public API methods, controllers, or middleware** to provide consistent and user-friendly error handling.
- Always **log exceptions** and avoid silently swallowing errors inside catch blocks.
- This strategy results in **cleaner, more maintainable code** and better error management.

```php
// BAD
class OrderProcessor
{
    // ❌ Wrong: try-catch inside private method - unnecessary and cluttered
    private function validateOrder(array $order): bool
    {
        try {
            if (empty($order['items'])) {
                throw new InvalidArgumentException('Order must contain items');
            }
            return true;
        } catch (InvalidArgumentException $e) {
            // ❌ Catching here but not handling properly (just rethrowing)
            throw $e;
        }
    }
}


// GOOD
class OrderProcessor
{
    // ✅ Right: No try-catch here - let exception bubble up
    private function validateOrder(array $order): bool
    {
        if (empty($order['items'])) {
            throw new InvalidArgumentException('Order must contain items');
        }
        return true;
    }

    // ✅ Right: Handle exceptions in the public method instead
    public function processOrder(array $order): bool
    {
        try {
            $this->validateOrder($order);
            // Additional order processing logic
            return true;
        } catch (InvalidArgumentException $e) {
            // Handle validation error, log or notify accordingly
            error_log($e->getMessage());
            return false;
        } catch (Exception $e) {
            // Handle unexpected errors
            error_log('Unexpected error: ' . $e->getMessage());
            return false;
        }
    }
}
```

## Tests

### Best Practices

- **Insufficient Tests :**
	How many tests should be in a test suite? Unfortunately, the metric many programmers use is “That seems like enough.” A test suite should test everything that could possibly break. The tests are insufficient so long as there are conditions that have not been explored by the tests or calculations that have not been validated.

- **Use a Coverage Tool! :**
	Coverage tools reports gaps in your testing strategy. They make it easy to find modules, classes, and functions that are insufficiently tested. Most IDEs give you a visual indication, marking lines that are covered in green and those that are uncovered in red. This makes it quick and easy to find if or catch statements whose bodies haven’t been checked.

- **Don’t Skip Trivial Tests :**
	They are easy to write and their documentary value is higher than the cost to produce them.

- **An Ignored Test Is a Question about an Ambiguity :**
	Sometimes we are uncertain about a behavioral detail because the requirements are unclear. We can express our question about the requirements as a test that is commented out, or as a test that annotated with @Ignore. Which you choose depends upon whether the ambiguity is about something that would compile or not.

- **Test Boundary Conditions :**
	Take special care to test boundary conditions. We often get the middle of an algorithm right but misjudge the boundaries.

- **Exhaustively Test Near Bugs :**
	Bugs tend to congregate. When you find a bug in a function, it is wise to do an exhaustive test of that function. You’ll probably find that the bug was not alone.

- **Patterns of Failure Are Revealing :**
	Sometimes you can diagnose a problem by finding patterns in the way the test cases fail. This is another argument for making the test cases as complete as possible. Complete test cases, ordered in a reasonable way, expose patterns.
	As a simple example, suppose you noticed that all tests with an input larger than five characters failed? Or what if any test that passed a negative number into the second argument of a function failed? Sometimes just seeing the pattern of red and green on the test report is enough to spark the “Aha!” that leads to the solution. 

- **Test Coverage Patterns Can Be Revealing :**
	Looking at the code that is or is not executed by the passing tests gives clues to why the failing tests fail.

- **Tests Should Be Fast :**
	A slow test is a test that won’t get run. When things get tight, it’s the slow tests that will be dropped from the suite. So do what you must to keep your tests fast.


```php
// Not clean (unstructured test)
function testAddition() {
    // Test logic here
}

// Clean (organized test)
function testAdditionWithPositiveNumbers() {
    // Test logic for positive numbers
}

function testAdditionWithNegativeNumbers() {
    // Test logic for negative numbers
}
```

### Principles & Design Patterns

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
Use **design patterns** where appropriate to simplify complex logic.

I cover each of these principles and design patterns, in details with PHP examples in the folder `Principles & Design Patterns`


## Best Practices

### Code should be easy to read

```php
// BAD
function x($a){$b=0;for($i=0;$i<count($a);$i++){$b+=$a[$i];}return $b;}

// GOOD
function sumArray($numbers) {
    $total = 0;
    for ($i = 0; $i < count($numbers); $i++) {
        $total += $numbers[$i];
    }
    return $total;
}
```

### Code should be efficient

Efficient code is not only about speed and performance but also about how well your code utilizes resources. Writing efficient PHP code involves understanding the cost of operations, avoiding unnecessary calculations, and using the right data structures and algorithms for the job. Remember, **premature optimization is the root of all evil**. Don’t optimize until you have a proven bottleneck.

```php
// BAD
function findElement($array, $element) {
    for ($i = 0; $i < count($array); $i++) {
        if ($array[$i] === $element) {
            return true;
        }
    }
    return false;

// GOOD
function findElement($array, $element) {
    return in_array($element, $array);
}
```