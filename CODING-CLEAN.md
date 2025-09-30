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

