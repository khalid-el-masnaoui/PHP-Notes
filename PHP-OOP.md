# PHP OOP

## Overview 

Object-Oriented Programming (OOP) in PHP is a programming paradigm that organizes code around objects rather than functions and logic. Exploring some PHP specific OOP implementations.

## Table Of Contents


- **[PHP Specific OOP implementations](#php-specific-oop-implementations)**
   * **[Classes & Objects](#classes-objects)**
   * **[Namespaces](#namespaces)**
   * **[Traits](#traits)**
   * **[Magic Methods](#magic-methods)**
   * **[`$this`, `self`, and `static` keywords](**#this-self-and-static-keywords)**
      + **[`$this`](#this)**
      + **[`self`](#self)**
      + **[`static`](#static)**
      + **[Summary](#summary)**
   * **[Overloading](#overloading)**
   * **[Anonymous Classes](#anonymous-classes)**
   * **[Object Comparison ](#object-comparison)**
      + **[Comparison Operator (`==`)](#comparison-operator-)**
      + **[Identity Operator (`===`)](#identity-operator-)**
   * **[Covariance, Contravariance, Invariance](#covariance-contravariance-invariance)**
      + **[Covariance](#covariance)**
      + **[Contravariance](#contravariance)**
      + **[Invariance](#invariance)**
   * **[Readonly Properties](#readonly-properties)**
   * **[Class & Object Functions](#class-object-functions)**
      + **[`class_exists`](#class_exists)**
      + **[`method_exist`](#method_exist)**
      + **[`property_exists`](#property_exists)**
      + **[Class Name](#class-name)**
         - **[`get_class()`](#get_class)**
         - **[`_CLASS_` magic constant](#class-magic-constant)**
         - **[`::class`](#class)**
         - **[ReflectionClass](#reflectionclass)**
   * **[Auto-loading](#auto-loading)**
      + **[`spl_autoload_register`](#spl_autoload_register)**
      + **[Composer and PSR-4](#composer-and-psr-4)**
   * **[Attributes](#attributes)**
      + **[Define](#define)**
      + **[Apply](#apply)**
      + **[Retrieve](#retrieve)**
   * **[Reflection Class](#reflection-class)**


# PHP Specific OOP implementations
## Classes & Objects

- **Classes:** A blueprint or template for creating objects. It defines properties (data/attributes) and methods (functions/behaviors) that objects of that class will possess.

- **Objects:** An instance of a class. When a class is defined, no memory is allocated until an object of that class is created.


```php 
class Car {
    // Properties
    public $brand;
    public $model;
    public $year;

    // Methods
    public function startEngine() {
        echo "The " . $this->brand . " " . $this->model . " engine is starting.<br>";
    }

    public function getDetails() {
        return $this->brand . " " . $this->model . " (" . $this->year . ")";
    }
}

// Creating an object (instantiation)
$myCar = new Car();

// Setting object properties
$myCar->brand = "Toyota";
$myCar->model = "Camry";
$myCar->year = 2023;

// Accessing object methods
$myCar->startEngine(); // Output: The Toyota Camry engine is starting.
echo "Car details: " . $myCar->getDetails() . "<br>"; // Output: Car details: Toyota Camry (2023)

// Creating another object
$anotherCar = new Car();
$anotherCar->brand = "Honda";
$anotherCar->model = "Civic";
$anotherCar->year = 2022;

$anotherCar->startEngine(); // Output: The Honda Civic engine is starting.
echo "Another car details: " . $anotherCar->getDetails() . "<br>"; // Output: Another car details: Honda Civic (2022)
```

## Namespaces

Namespaces prevent name conflicts when you use multiple classes with the same name.

```php
namespace App\Models;

class User {
    public function getInfo() {
        echo "the info for the user";
    }
}

 
$user = new \App\Models\User();
$user->getInfo();
```


## Traits

Traits allow code reuse in multiple classes without using inheritance.

```php
trait Logger {
	public function log($message) {
		echo "Logging: " . $message;
	}
}

class User {
	use Logger;
	public function createUser() {
		$this->log('User created.');
	}
}

$user = new User();
$user->createUser();
```


## Magic Methods

PHP provides several **magic methods** which add dynamic behaviors to objects.  They are special methods that are called automatically when certain conditions are met.  Every magic method starts with a double underscore (  __ ).


- `__construct` :  This method executes  when an object is created
- `__destruct` : This method executes  when an object is no longer needed.
- `__call($name,$parameter)`: This method executes when a method is called which is not non-existent or inaccessible.
- `__callStatic($name,$parameter)` : This method executes when a **static**  method is called which is not non-existent or inaccessible.
- `__toString` : This method is called when we need to convert the object into a string.
- `__get($name)` : This method is called when an inaccessible variable or non-existing variable is used.
- `__set($name , $value)` : This method is called when an inaccessible variable or non-existing variable is written.
- `__isset($name)` : Invoked when the `isset()` or `empty()` functions are used on an inaccessible or non-existent property of an object.
- `__unset($name)` : Invoked when the `unset()` function is used on an inaccessible or non-existent property of an object.
- `__invoke(...$name)` : Allows an object to be called as if it were a function.
- `__wakeup` : Automatically executed after using `unserialize()` function on the object ( e.g re-establish the database connection after un-serialization)
- `__clone()` : Invoked whenever an object is cloned using the `clone` keyword. Its purpose :
	- **Deep Copying:** (object properties)
	- **Reassigning Properties**
	- **Cleanup or Initialization**


```php
class Address {
	private string $street;
	public function __construct(string $street) {
		$this->street = $street;
	}
}

class User {

	private string $firstName;
    private string $lastName;
    
    private Address $address;


    public function __construct(string $firstName, string $lastName, Address $address) {
	    $this->firstName = $firstName;  
		$this->lastName = $lastName;
		$this->address = $address;
        echo "User object created";
    }

    public function __destruct() {
        echo "User object deleted";
    }
    
    public function __call(string $name, array $arguments) {
        echo "Attempted to call method: '{$name}'\n";
        echo "Arguments passed: " . implode(', ', $arguments) . "\n";

        if ($name === 'greet') {
            return "Hello, " . $arguments[0] . "!";
        } else {
            throw new BadMethodCallException("Method '{$name}' does not exist.");
        }
    }
    
      public static function __callStatic(string $method, array $arguments) {
        echo "Attempted to call static method '{$method}' with arguments: ";
        print_r($arguments);
        // You can implement custom logic here, like redirecting to another method,
        // dynamically creating the method, or throwing an exception.
    }
    
    public function __toString(): string{
        return "User: {$this->firstName} {$this->lastName}";
    }
    
    public function __get(string $name): mixed {
	    if ($name === 'fullName') {
            return "{$this->firstName} {$this->lastName}";
        }
        // Handle non-existent/inaccessible property
        trigger_error("Attempt to access non-existent or inaccessible property: $name", E_USER_WARNING);
        return null;
    }
    
     public function __set(string $name, mixed $value): void {
        // Example: Implementing a property alias
        if ($name === 'fullName') {
	        $fullName = explode(' ', $name, 2);
            $this->firstName = $fullName[0];
            $this->lastName = $fullName[1] ?? '';
        }
    }
    
    public function __isset($name){
        return isset($name);
    }
    
   public function __unset($name) {
		echo "Attempting to unset '$name'\n";
		unset($this->$name); // Unset the property from the internal array
	}
	
	public function __invoke($name)
    {
        return "Hello, " . $name . "!";
    }
    
    public function __clone() {
		// Deep copy the Address object
		$this->address = clone $this->address;
    }
}
$address = new Address("123 Main St");
$user = new User("khalid", "malidkha", $address); // Output => User object created

// This will trigger __call()  
echo $user->greet('World') . "\n";  
  
// This will also trigger __call() and then the custom exception  
try {  
	$user->unknownMethod('param1', 'param2');  
} catch (BadMethodCallException $e) {  
	echo $e->getMessage() . "\n";  
}


user::nonExistentMethod('value1', 123);
// Output => Attempted to call static method 'nonExistentMethod' with arguments: Array  (  [0] => value1  [1] => 123  )

echo $user; // Output => User: khalid malidkha

echo $user->fullName; // Output => khalid malidkha
echo $user->city; // Triggers a warning and outputs: null

$user->fullName = 'malidkha el'; // Calls __set
  
echo $user->fullName; // Outputs => malidkha el  

var_dump(isset($user->firstName)); // Calls __isset, returns true
var_dump(isset($user->fullName)); // Calls __isset, returns false

try {
	unset($user->email); // Throws an exception
} catch (Exception $e) {
	echo $e->getMessage();
}

echo $greet("malidkha"); // Output => Hello, malidkha!

$clonedUser = clone $user;
// Modifying the cloned user's address will not affect the original
$clonedUser->address->street = "456 Oak Ave";

echo $user->address->street; // Output => 123 Main St
echo $clonedUser->address->street;   // Output => 456 Oak Ave

```


## `$this`, `self`, and `static` keywords

### `$this`

- Refers to the **current instance** of the class.
- Used to access non-static properties and methods of that specific object.
- Cannot be used within static methods as static methods are not tied to a specific object instance.


### `self`

- Refers to the **current class** itself, not a specific object instance.
- Used to access static properties and methods within the same class. 
- Accessed using the scope resolution operator (`::`), for example, `self::$staticProperty` or `self::staticMethod()`.
- Does not account for inheritance and will always refer to the class in which it is written, even if a child class overrides the static member.

### `static`

- Also refers to the **current class**, similar to `self`, but with a key difference in inheritance.
- Used for **late static binding**, meaning it refers to the class that was called at **runtime**, not necessarily the class where the `static` keyword is written.
- Allows for **polymorphic** behavior with static members, where a child class's overridden static property or method will be used when called through the child class.
- Accessed using the scope resolution operator (`::`), for example, `static::$staticProperty` or `static::staticMethod()`.

### Summary

- Use `$this` for **instance-level** (non-static) members.
- Use `self` for static members when you want to explicitly refer to the current class and ignore potential overrides in child classes.
- Use `static` for static members when you want to leverage late static binding and allow for polymorphic behavior in child classes.


## Overloading

Overloading refers to the ability to dynamically create properties and methods in a class, which are then handled by **magic methods**.

- **Property Overloading:**
    - `__set($name, $value)`
    - `__get($name)`
    - `__isset($name)`
    - `__unset($name)`

- **Method Overloading:**
    - `__call($name, $arguments)`
    - `__callStatic($name, $arguments)`


## Anonymous Classes

An anonymous class is a class that is defined and instantiated at the same time, without being assigned a specific name, useful for creating simple, one-off objects where a full class definition in a separate file would be unnecessary or add overhead.

- **Use Cases:**
    - **Testing and Mocking:** Creating simple mock objects for unit tests without needing to define a separate class file.
    - **Callbacks and Event Handlers:** Providing quick, inline implementations for interfaces or abstract classes required by a callback or event listener.
    - **Simple, Temporary Objects:** When a small, self-contained object is needed for a very specific, local purpose and will not be reused elsewhere.

```php
interface LoggerInterface
{
    public function log(string $message);
}

// Using an anonymous class to implement LoggerInterface
$logger = new class implements LoggerInterface {
    public function log(string $message)
    {
        echo "LOG: " . $message . PHP_EOL;
    }
};

$logger->log("This is a test message.");

// Anonymous class extending another class
class BaseClass
{
    protected string $name;

    public function __construct(string $name)
    {
        $this->name = $name;
    }

    public function getName(): string
    {
        return $this->name;
    }
}

$extendedObject = new class('Anonymous Extension') extends BaseClass {
    public function greet(): string
    {
        return "Hello from " . $this->getName();
    }
};

echo $extendedObject->greet() . PHP_EOL;
```


## Object Comparison 

In PHP, objects can be compared using two main operators: the comparison operator (`==`) and the identity operator (`===`).


### Comparison Operator (`==`)

When using the `==` operator to compare two objects, PHP determines if the objects are "equal" based on the following criteria:

- **Same Class:** Both objects must be instances of the same class.
- **Same Attributes and Values:** Both objects must have the same attributes (properties) with the same values. The values themselves are compared using `==`.

```php
class MyClass {
    public $prop1;
    public $prop2;

    public function __construct($p1, $p2) {
        $this->prop1 = $p1;
        $this->prop2 = $p2;
    }
}

$obj1 = new MyClass("valueA", 123);
$obj2 = new MyClass("valueA", 123);
$obj3 = new MyClass("valueB", 456);

if ($obj1 == $obj2) {
    echo "obj1 and obj2 are equal (==)\n"; // This will be true
}

if ($obj1 == $obj3) {
    echo "obj1 and obj3 are equal (==)\n"; // This will be false
}
```

### Identity Operator (`===`)

The `===` operator performs a stricter comparison, checking for "identity." Two object variables are considered identical if: 

- **Same Instance:** They refer to the exact same instance of the same class in memory. This means they are essentially two different names pointing to the same object.

```php
class MyClass {
    public $prop1;

    public function __construct($p1) {
        $this->prop1 = $p1;
    }
}

$objA = new MyClass("data");
$objB = new MyClass("data");
$objC = $objA; // $objC now refers to the same instance as $objA

if ($objA === $objB) {
    echo "objA and objB are identical (===)\n"; // This will be false
}

if ($objA === $objC) {
    echo "objA and objC are identical (===)\n"; // This will be true
}
```


## Covariance, Contravariance, Invariance

Covariance, contravariance, and invariance refer to how type declarations for parameters and return types behave when overriding methods in child classes or implementing interfaces. These concepts were fully supported starting from PHP 7.4.

- **Covariance:** "Narrows" the return type (more specific).
- **Contravariance:** "Widens" the parameter type (less specific).
- **Invariance:** Requires an exact match of the type.

These concepts are crucial for maintaining type safety and flexibility in object-oriented programming, particularly when dealing with **polymorphism** and **inheritance hierarchies.**
### Covariance

Covariance allows a child method's return type to be a more specific type than the return type of its parent's method or the interface's method. 
This means if a parent method returns a `Fruit` object, the child method can return an `Apple` object (assuming `Apple` is a subclass of `Fruit`).

```php
class Fruit {}
class Apple extends Fruit {}

class Basket
{
    public function getFruit(): Fruit
    {
        return new Fruit();
    }
}

class AppleBasket extends Basket
{
    // Covariant return type: Apple is a more specific type than Fruit
    public function getFruit(): Apple
    {
        return new Apple();
    }
}
```

### Contravariance

Contravariance allows a child method's parameter type to be a less specific type than the parameter type of its parent's method or the interface's method. 
This means if a parent method accepts an `Apple` object, the child method can accept a `Fruit` object.

```php
class Fruit {}
class Apple extends Fruit {}

class Processor
{
    public function process(Apple $apple): void
    {
        // ... process the apple
    }
}

class GenericProcessor extends Processor
{
    // Contravariant parameter type: Fruit is a less specific type than Apple
    public function process(Fruit $fruit): void
    {
        // ... process the fruit
    }
}
```

### Invariance

Invariance means that the type declaration in the child method or interface implementation must exactly match the type declaration in the parent method or interface. Neither a more specific (covariant) nor a less specific (contravariant) type is allowed. In PHP, property types are typically invariant.

```php
class InvariantClass
{
    public string $name; // This property type is invariant
}

class ChildInvariantClass extends InvariantClass
{
    // public string $name; // Must remain 'string', cannot be 'int' or 'object'
}
```

## Readonly Properties

In PHP's OOP, the `readonly` keyword provides a mechanism to create properties that can only be initialized once and then cannot be modified afterward. This enhances **immutability** and helps in writing more predictable and robust code.

- **Immutability after Initialization:**  Once a `readonly` property is assigned a value (typically in the constructor), it cannot be reassigned or modified. Any attempt to do so will result in an `Error` exception.
    
- **Typed Properties Required:**  The `readonly` modifier can only be applied to typed properties. This means you must declare the data type of the property (e.g., `string`, `int`, `object`, `array`). 
    
- **Initialization Scope:**  A `readonly` property can only be initialized once, and this initialization must occur within the scope where the property is declared (usually within the class's constructor).
    
- **No Default Values (unless promoted):**  `readonly` properties cannot have a default value assigned directly in their declaration, unless they are promoted properties in the constructor.
    
- **Readonly Classes (PHP 8.2+):**  As of PHP 8.2, you can declare an entire class as `readonly`. This automatically makes all declared properties within that class `readonly` and also prevents the creation of dynamic properties


```php
class User
{
    public readonly int $id;
    public readonly string $name;

    public function __construct(int $id, string $name)
    {
        $this->id = $id;
        $this->name = $name;
    }
}

$user = new User(1, "khalid");

// Legal read
echo $user->name; // Output: khalid

// Illegal reassignment - will throw an Error
// $user->name = "malidkha";
```

```php
readonly class Product
{
    public string $tag;
    public float $price;

    public function __construct(string $tag, float $price)
    {
        $this->tag = $tag;
        $this->price = $price;
    }
}

$product = new Product("P123", 99.99);

// Legal read
echo $product->price; // Output: 99.99

// Illegal reassignment - will throw an Error
// $product->price = 120.00;
```


## Class & Object Functions

### `class_exists`

`class_exists()` function is used to determine if a given class has been defined. This function is particularly useful when working with object-oriented programming (OOP) to ensure a class is available before attempting to instantiate an object or interact with its members. 

The `class_exists()` function takes two parameters:

- `$class_name`:  A string representing the name of the class to check for. This parameter is case-insensitive.
- `$autoload`:  An optional boolean parameter (defaults to `TRUE`) that determines whether to trigger the autoloader if the class is not already loaded.

```php
// Define a class
class MyClass {
    public $property = "Hello";
}

// Check if 'MyClass' exists
if (class_exists('MyClass')) {
    echo "Class 'MyClass' exists.\n";
    $obj = new MyClass();
    echo $obj->property . "\n";
} else {
    echo "Class 'MyClass' does not exist.\n";
}

// Check for a non-existent class
if (class_exists('NonExistentClass')) {
    echo "Class 'NonExistentClass' exists.\n";
} else {
    echo "Class 'NonExistentClass' does not exist.\n";
}
```

**Note** :  If the class is namespaced. The class name is `App\MyClass`, not `MyClass`. You should use the fully-qualified class name `class_exists(App\MyClass)`

### `method_exist`

Checks if a method exists within a class or an object.

```php
method_exists(object|string $object_or_class, string $method): bool
```

Parameters:
- `$object_or_class`: This can be either an object instance or a string representing the class name.
- `$method`: This is a string representing the name of the method to check for existence.


```php
class MyClass {
    public function myMethod() {
        echo "This is myMethod.";
    }

    public function anotherMethod() {
        echo "This is anotherMethod.";
    }
}

$obj = new MyClass();

// Check if 'myMethod' exists in the object
if (method_exists($obj, 'myMethod')) {
    echo "myMethod exists in the object.\n";
} else {
    echo "myMethod does not exist in the object.\n";
}

// Check if 'nonExistentMethod' exists in the class
if (method_exists('MyClass', 'nonExistentMethod')) {
    echo "nonExistentMethod exists in the class.\n";
} else {
    echo "nonExistentMethod does not exist in the class.\n";
}

// Check for a method using a class name string
if (method_exists('MyClass', 'anotherMethod')) {
    echo "anotherMethod exists in the class.\n";
} else {
    echo "anotherMethod does not exist in the class.\n";
}
```

### `property_exists`

The PHP function `property_exists()` is used to determine whether a class or an object has a specific property. It is particularly useful in Object-Oriented Programming (OOP) when you need to check for the presence of a property before attempting to access or manipulate it, thereby preventing potential errors.

```php
property_exists(object|string $object_or_class, string $property);
```

Parameters:

- `$object_or_class`: This parameter can be either an object instance or the name of a class (as a string).
- `$property`: This is the name of the property you want to check for, as a string.

Key Difference from `isset()`:

- Unlike `isset()`, which checks if a property exists and is not `null`, `property_exists()` returns `true` even if the property exists but its value is `null`. This makes `property_exists()` a more precise tool for simply verifying the existence of a property, regardless of its current value.


### Class Name

In PHP, there are several ways to get the name of a class in an object-oriented programming context

#### `get_class()`

This function returns the name of the class of which an object is an instance. You can pass the object as an argument, or if called inside a class method, you can omit the argument and it will return the current class's name. 


```php
class MyClass {
	public function getMyClassName() {
		return get_class($this); // Returns "MyClass"
	}
}

$obj = new MyClass();
echo get_class($obj); // Outputs: MyClass
echo $obj->getMyClassName(); // Outputs: MyClass
```

**Note** :  `get_class()` function returns the fully qualified class name (FQCN) of an object, including its namespace if it belongs to one.

#### `_CLASS_` magic constant

```php
class AnotherClass {
	public function getMagicClassName() {
		return __CLASS__; // Returns "AnotherClass"
	}
}

$obj = new AnotherClass();
echo $obj->getMagicClassName(); // Outputs: AnotherClass
```

**Note** : The magic constant `__CLASS__` in PHP does not return the fully qualified class name.
#### `::class`

This provides a way to get the **fully qualified class name** as a string literal at compile time (if any). It's particularly useful for avoiding hardcoded strings and benefiting from IDE features like refactoring.

```php
namespace MyNamespace;

class YetAnotherClass {
	// ...
}

echo MyNamespace\YetAnotherClass::class; // Outputs: MyNamespace\YetAnotherClass
```

#### ReflectionClass

The `ReflectionClass::getName()` method returns a string containing the fully qualified class name, including its namespace (if any).

```php
class YetAnotherAnotherClass {
	// ...
}

$reflectionClass = new ReflectionClass(YetAnotherAnotherClass::class);
echo $reflectionClass->getName(); // Outputs: YetAnotherAnotherClass
```

## Auto-loading

PHP's OOP autoloading mechanism simplifies class management by automatically including class files when they are needed, eliminating the need for manual `require` or `include` statements. This is particularly beneficial in large projects with numerous classes.

### `spl_autoload_register`

The core function for autoloading in PHP is `spl_autoload_register()`. This function registers one or more autoloader functions, which PHP will call when an undefined class, interface, or trait is accessed.

```php
spl_autoload_register(function ($className) {
    // Convert namespace separators to directory separators
    $className = str_replace('\\', DIRECTORY_SEPARATOR, $className);

    // Define the base directory where your classes are located
    $baseDir = __DIR__ . '/src/'; 

    // Construct the full path to the class file
    $file = $baseDir . $className . '.php';

    // Check if the file exists and include it
    if (file_exists($file)) {
        require_once $file;
    }
});

// Example usage:
// If you have a class 'MyNamespace\MyClass' in 'src/MyNamespace/MyClass.php'
$obj = new MyNamespace\MyClass(); 
$obj->doSomething();
```

### Composer and PSR-4

For more robust and standardized autoloading in modern PHP projects, Composer is widely used. Composer leverages the PSR-4 autoloading standard, which provides a convention for mapping namespaces to file paths. Composer generates an optimized autoloader based on your `composer.json` configuration, handling the complexities of class loading automatically.


```php
//composer.json
//...

{
    "autoload": {
        "psr-4": {
            "MyApp\\": "src/"
        }
    }
}
```

This configuration tells Composer that any class within the `MyApp\` namespace (e.g., `MyApp\Controller\UserController`) will be found in a corresponding file within the `src/` directory (e.g., `src/Controller/UserController.php`).

```php
require __DIR__ . '/vendor/autoload.php';

// Now you can instantiate classes without manual requires
$userController = new MyApp\Controller\UserController();
```

## Attributes

PHP attributes, introduced in PHP 8, provide a way to add structured, machine-readable metadata to various code elements in an object-oriented programming (OOP) context. This metadata can then be inspected at runtime using the Reflection API, enabling dynamic behavior without modifying the core logic.


Attributes are special classes, marked with the global **`#[Attribute]`** attribute, that serve as annotations for other parts of your code. They can be applied to:

- **Classes:** To provide metadata about the class itself.
- **Methods:** To add information about a specific method's behavior or purpose.
- **Properties:** To describe characteristics of a class property.
- **Functions:** To annotate standalone functions.
- **Parameters:** To add details about function or method parameters.
- **Class Constants:** To provide metadata for class constants.

### Define

- The `#[Attribute]` attribute specifies where the `Route` attribute can be used (methods and classes in this example). The constructor defines the data the attribute will hold. 
- **Attribute::TARGET_CLASS**
- **Attribute::TARGET_FUNCTION**
- **Attribute::TARGET_METHOD**
- **Attribute::TARGET_PROPERTY**
- **Attribute::TARGET_CLASS_CONSTANT**
- **Attribute::TARGET_PARAMETER**
- **Attribute::TARGET_ALL**

```php
#[Attribute(Attribute::TARGET_METHOD | Attribute::TARGET_CLASS)]
class Route
{
	public function __construct(public string $path, public array $methods = ['GET']) {}
}
```



### Apply

- Attributes are applied using the `#[AttributeName]` syntax, optionally with constructor arguments.

```php
#[Route('/users', methods: ['GET', 'POST'])]
class UserController
{
	#[Route('/{id}', methods: ['GET'])]
	public function getUser(int $id)
	{
		// ...
	}
}
```


### Retrieve

- The Reflection API allows you to inspect classes, methods, and properties at runtime and retrieve their associated attributes. You can then instantiate the attribute objects to access their data.

```php
$reflectionClass = new ReflectionClass(UserController::class);
$attributes = $reflectionClass->getAttributes(Route::class);

foreach ($attributes as $attribute) {
	$route = $attribute->newInstance();
	echo "Class Route: " . $route->path . " (" . implode(', ', $route->methods) . ")\n";
}

$reflectionMethod = new ReflectionMethod(UserController::class, 'getUser');
$methodAttributes = $reflectionMethod->getAttributes(Route::class);

foreach ($methodAttributes as $attribute) {
	$route = $attribute->newInstance();
	echo "Method Route: " . $route->path . " (" . implode(', ', $route->methods) . ")\n";
    }
```

## Reflection Class

The `ReflectionClass` in PHP is a built-in class that provides the ability to inspect and interact with the internal structure of classes at runtime. It is part of PHP's **Reflection API**, which allows a program to examine and modify its own structure.


The PHP `ReflectionClass` enables:

- **Introspection of Class Structure:**
    - Retrieving the class name, namespace, short name, and filename where it's defined.
    - Determining if a class is abstract, final, a trait, or an interface.
    - Getting information about parent classes and implemented interfaces.
    
- **Inspection of Class Members:**
    - Accessing and retrieving details about class constants, including their names and values.
    - Inspecting class properties (variables), including their names, default values, visibility (public, protected, private), and whether they are static.
    - Examining class methods (functions), including their names, parameters, return types, visibility, and whether they are static or abstract.
    
- **Dynamic Interaction:**
    - Creating new instances of a class, even without calling its constructor directly (using `newInstanceWithoutConstructor`).
    - Invoking methods on a class or object dynamically.
    - Setting and getting property values, even for private or protected properties (though this practice should be used with caution as it can break encapsulation).
    
- **Annotation Parsing:** You can extract and analyze PHPDoc annotations from class and method doc comments, allowing you to add metadata to your code. As well as PHP `Attributes` (preferred way!)


The PHP `ReflectionClass` is a powerful tool used in various scenarios, including **dependency injection containers**, **ORMs,** and **debugging tools**, where dynamic analysis and manipulation of class structures are required. However, its use should be considered carefully, as excessive reliance on reflection can sometimes lead to code that is harder to understand and maintain, and can potentially **break encapsulation principles**.

```php
class MyExampleClass
{
    const MY_CONSTANT = 'This is a constant.';

    public static $staticProperty = 'Static value.';
    public $publicProperty = 'Public value.';
    protected $protectedProperty = 'Protected value.';
    private $privateProperty = 'Private value.';

    public function __construct($arg1, $arg2)
    {
        // Constructor logic
    }

    public function publicMethod()
    {
        return 'Public method called.';
    }

    protected function protectedMethod()
    {
        return 'Protected method called.';
    }

    private function privateMethod()
    {
        return 'Private method called.';
    }

    public static function staticMethod()
    {
        return 'Static method called.';
    }
}

// Create a ReflectionClass instance for MyExampleClass
$reflectionClass = new ReflectionClass('MyExampleClass');

echo "--- Class Information ---\n";
echo "Class Name: " . $reflectionClass->getName() . "\n";
echo "Is Final: " . ($reflectionClass->isFinal() ? 'Yes' : 'No') . "\n";
echo "Is Abstract: " . ($reflectionClass->isAbstract() ? 'Yes' : 'No') . "\n";
echo "Is Interface: " . ($reflectionClass->isInterface() ? 'Yes' : 'No') . "\n";
echo "Is Instantiable: " . ($reflectionClass->isInstantiable() ? 'Yes' : 'No') . "\n";
echo "File Name: " . $reflectionClass->getFileName() . "\n";
echo "Start Line: " . $reflectionClass->getStartLine() . "\n";
echo "End Line: " . $reflectionClass->getEndLine() . "\n";
echo "Namespace: " . $reflectionClass->getNamespaceName() . "\n";
echo "Parent Class: " . ($reflectionClass->getParentClass() ? $reflectionClass->getParentClass()->getName() : 'None') . "\n";
echo "Doc Comment: " . ($reflectionClass->getDocComment() ?: 'None') . "\n";

echo "\n--- Constants ---\n";
$constants = $reflectionClass->getConstants();
foreach ($constants as $name => $value) {
    echo "Constant: {$name} = {$value}\n";
}

echo "\n--- Properties ---\n";
$properties = $reflectionClass->getProperties();
foreach ($properties as $property) {
    echo "Property: {$property->getName()} (Visibility: ";
    if ($property->isPublic()) echo "public";
    if ($property->isProtected()) echo "protected";
    if ($property->isPrivate()) echo "private";
    echo ", Static: " . ($property->isStatic() ? 'Yes' : 'No') . ")\n";
}

echo "\n--- Methods ---\n";
$methods = $reflectionClass->getMethods();
foreach ($methods as $method) {
    echo "Method: {$method->getName()} (Visibility: ";
    if ($method->isPublic()) echo "public";
    if ($method->isProtected()) echo "protected";
    if ($method->isPrivate()) echo "private";
    echo ", Static: " . ($method->isStatic() ? 'Yes' : 'No') . ")\n";

    // Get parameters for methods
    if ($method->getParameters()) {
        echo "  Parameters: ";
        foreach ($method->getParameters() as $parameter) {
            echo $parameter->getName() . " ";
        }
        echo "\n";
    }
}

echo "\n--- Creating Instance & Invoking Methods ---\n";
// Create an instance without calling the constructor (if needed)
// $instance = $reflectionClass->newInstanceWithoutConstructor();

// Create an instance with constructor arguments
$instance = $reflectionClass->newInstanceArgs(['value1', 'value2']);

// Invoke a public method
$publicMethodReflection = $reflectionClass->getMethod('publicMethod');
echo "Invoking publicMethod: " . $publicMethodReflection->invoke($instance) . "\n";

// Invoke a static method
$staticMethodReflection = $reflectionClass->getMethod('staticMethod');
echo "Invoking staticMethod: " . $staticMethodReflection->invoke(null) . "\n"; // Pass null for static methods

// Set and Get property values (requires setting accessibility for non-public)
$privatePropertyReflection = $reflectionClass->getProperty('privateProperty');
$privatePropertyReflection->setAccessible(true); // Allow access to private property
$privatePropertyReflection->setValue($instance, 'New private value.');
echo "Private Property Value: " . $privatePropertyReflection->getValue($instance) . "\n";


// Creation of New Class Instances Without Using Constructors
$reflection = new ReflectionClass('MyClass');  
$instance = $reflection->newInstanceWithoutConstructor();  
$instance->__construct('Hello', 'World');
```


- For a complete list of methods for the `ReflectionClass` check [this](https://www.php.net/manual/en/book.reflection.php)
