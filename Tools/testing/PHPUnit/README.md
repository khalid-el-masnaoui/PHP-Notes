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

