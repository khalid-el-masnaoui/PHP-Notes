# PHPUnit

PHPUnit is a robust and widely used testing framework designed specifically for PHP. It allows developers to perform unit testing by providing a structured and efficient way to test individual code units. As an implementation of the xUnit architecture, PHPUnit is tailored to suit the needs of PHP developers, making it straightforward to set up and begin testing.



# PHPUnit

## Key features

- **Unit testing**:  PHPUnit is primarily used to test individual "units" of code, such as functions or methods, to check their output against expected results. 
    
- **xUnit architecture**:  It is based on the xUnit architecture, a pattern for creating unit testing frameworks that originated with SUnit and was popularized by JUnit. 
    
- **Assertions**: It provides a collection of simple and flexible assertions that allow you to easily test if your code's output matches the expected value. 
    
- **Test doubles**: It supports the use of test doubles, such as stubs and mocks, to test code in isolation by replacing dependencies with fake objects. 
    
- **Data providers**: You can use data providers to test a single test method with different sets of data, which simplifies testing functionality against various inputs. 
    
- **Integration testing:** While primarily known for unit testing, can also be utilized for integration testing in PHP applications. Integration testing, in contrast to unit testing, focuses on verifying the interactions and communication between different components or modules of a system, or between the system and external dependencies like databases or APIs.
	- **Simulate Real Interactions:**  Instead of mocking all dependencies, integration tests aim to use real dependencies where possible to truly test the integration. For example, if testing a database interaction, the test would connect to the actual test database.

## Setting Up

1. Installation 

```shell
composer require --dev phpunit/phpunit
```

2. Using PSR-4 for autoloading

```json
{
    "require": {
    },
    "require-dev": {
        "phpunit/phpunit": "^11.5"
    },
    "autoload": {
        "psr-4": {
            "Malidkha\\Tests\\": "tests/"
        }
    }
}
```

3. Configuring PHPUnit - phpunit.xml

```xml

<?xml version="1.0" encoding="UTF-8"?>
<phpunit colors="true">
    <testsuites>
        <testsuite name="Application Unit Test Suite">
            <directory>./tests/Unit/</directory>
        </testsuite>
    </testsuites>
</phpunit>
```

4. Running the tests

```shell
./vendor/bin/phpunit
```


## Tests writing

### Definitions, naming, conventions

1. Test class — PHP class that contain tests for some functionality. Test class name must have “Test” postfix. Mostly uses one test class for one class, and named test class as original class name plus “Test” postfix.
2. Every test class mostly extends `PHPUnit\Framework\TestCase.`
3. Test method — it is a methods in test classes that contain functionality test. Test method name should have “test” prefix or must be marked with @test annotation or #[Test] attribute. Methods must be public.
4. For better convenience, the structure of the test directories should follow the structure of our class directories.

```php
public function testSimpleAssert(): void
{
    Assert::assertEquals(1, 1, 'Number "one" not aquals to number "one"');
}
```

## Asserts

```php
//Asserts that two variables have the same type and value. Used on objects, it asserts that two variables reference the same object.
assertSame($expected, $actual, string $message = '')

//Asserts that two variables do not have the same type and value. Used on objects, it asserts that two variables do not reference the same object.
assertNotSame($expected, $actual, string $message = '')

// Asserts that two variables are equal.
assertEquals($expected, $actual, string $message = ''): void

// Asserts that two variables are not equal.
assertNotEquals($expected, $actual, string $message = ''): void

// Asserts that a variable is null.
public static function assertNull($actual, string $message = ''): void

// Asserts that a variable is not null.
assertNotNull($actual, string $message = ''): void

// Asserts that a variable is of a given type.
assertInstanceOf(string $expected, $actual, string $message = ''): void

// Asserts that a condition is true.
assertTrue($condition, string $message = ''): void

// Asserts that a condition is false.
assertFalse($condition, string $message = ''): void

// Asserts the number of elements of an array, Countable or Traversable.
assertCount(int $expectedCount, $haystack, string $message = ''): void

// Asserts that an array has a specified key.
ssertArrayHasKey($key, $array, string $message = ''): void

// Asserts that a haystack contains a needle.
assertContains($needle, iterable $haystack, string $message = ''): void
```

### Tips

If we don’t want to write test body with some assertions we can use mark test as incomplete.

```php
public function testSomeFunctionality(): void
{
	$this->markTestIncomplete();
}
```

PHPUnit have other “mark” methods:

```php
$this->markTestSkipped();
$this->markAsRisky();
```

### Data providers

We can run test case many times with some arguments:

1. Add annotation @dataprovide dataProviderMethod or attribute
#[DataProvider(’dataProviderMethod’)] for our test case.

```php
/** @dataProvider dataProviderMethod */
public function testSimpleAssert($arg1, $arg2): void
{
    Assert::assertEquals($arg1, $arg2);
}
```

2. Create dataProvideMethod

```php
public function dataProviderMethod(): \Generator
{
    yield 'argument descriptions' => ['val1', 'val2'];
    yield 'yet another argument descriptions' => ['val_1', 'val_2'];
}
```

### Tests doubles

PHPUnit test doubles are objects that stand in for real dependencies during unit testing, allowing for isolated testing of a specific component (System Under Test, SUT) without relying on or triggering the behavior of its external dependencies. This helps to speed up tests and ensure that the SUT's behavior is correctly assessed.

PHPUnit provides mechanisms to create various types of test doubles, primarily **stubs** and **mocks**

#### Stubs

**Stubs:** Stubs are simplified test doubles that provide predefined responses to method calls. They are used when the test needs to control the return values of a dependency's methods, but doesn't need to verify interactions with that dependency. PHPUnit's `createStub()` method is used to create stubs.

- **Purpose:** Stubs are primarily used for state-based testing. Their main goal is to provide specific, pre-programmed responses to method calls, allowing the tested code to proceed without interacting with the real dependency. They simulate predictable outcomes.
    
- **Functionality:**  Stubs typically focus on defining return values for specific method calls. They do not track interactions or verify if certain methods were called.
    
- **Example:** If your code under test depends on a database connection to fetch data, a stub for the database connection would simply return a predefined dataset when a `fetch` method is called, without actually connecting to a database.

```php
    $stub = $this->createStub(DependencyClass::class);
    $stub->method('someMethod')->willReturn('expected_value');

    // Now, when your SUT calls someMethod on the stub, it will return 'expected_value'
```
