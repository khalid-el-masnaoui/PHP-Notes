# PHP Pest

Pest is a progressive, elegant PHP testing framework that focuses on simplicity. Built on top of PHPUnit, it provides a cleaner and more expressive syntax for writing tests, making testing faster and more enjoyable. Pest is particularly popular in the Laravel ecosystem but can be used in any PHP project.

## Table of Contents

- **[Pest](#pest)**
   * **[Key Features](#key-features)**
   * **[Setting Up](#setting-up)**
      + **[Set Up](#set-up)**
      + **[Configurations](#configurations)**
   * **[Writing Tests](#writing-tests)**
      + **[Definitions, Naming, Conventions](#definitions-naming-conventions)**
      + **[Assertions](#assertions)**
         - **[Expect API examples](#expect-api-examples)**
         - **[Using PHPUnit assertions](#using-phpunit-assertions)**
      + **[Tips](#tips)**
         - **[Mark test incomplete / skipped](#mark-test-incomplete-skipped)**
      + **[Data Providers (Datasets)](#data-providers-datasets)**
      + **[Test Doubles](#test-doubles)**
         - **[Stubs](#stubs)**
         - **[Mocks](#mocks)**
      + **[Exception Testing](#exception-testing)**
      + **[Fixtures](#fixtures)**
      + **[Code Coverage](#code-coverage)**
         - **[Install Coverage Plugin](#install-coverage-plugin)**
         - **[Run with coverage](#run-with-coverage)**
   * **[Resources](#resources)**

# Pest

## Key Features

- **Elegant test syntax** — minimalistic, BDD-inspired API with closures instead of classes.
    
- **Built on PHPUnit** — fully compatible with PHPUnit assertions, mocks, and tools.
    
- **Higher developer productivity** — cleaner, less boilerplate code; extremely fast to write tests.
    
- **Expect API** — expressive `expect()` API for fluent assertions.
    
- **Plugins ecosystem** — official and community plugins (Laravel, coverage, snapshots, faker, etc.).
    
- **Supports unit & integration testing** — works for all test types like PHPUnit.
    
- **Snapshots and Dataset testing** — built-in dataset and snapshot testing tools.

## Setting Up

### Set Up

1. **Installation**
```shell
composer require pestphp/pest --dev
```

- Optional plugins
```shell
composer require pestphp/pest-plugin-laravel --dev 
composer require pestphp/pest-plugin-coverage --dev
```


2. **Initialize Pest**
```shel
./vendor/bin/pest --init
```

This converts your `tests/` directory to Pest structure (keeps PHPUnit compatibility).

3. **Example project structure**
```shell
tests/  
	├─ Unit/  
	├─ Feature/  
	└─ Pest.php
```

4. **Run tests**
```shell
./vendor/bin/pest
```

### Configurations

Pest configuration primarily involves two files: `tests/Pest.php` and the standard `phpunit.xml` (or `phpunit.xml.dist`) file. Pest is built on top of PHPUnit, so it uses the PHPUnit configuration file for core settings and the `Pest.php` file for its specific features like global hooks, custom expectations, and test case extensions.

1. `tests/Pest.php`

This file is where you configure the behavior and setup of your Pest test suite using the `pest()` function and methods like `uses()` and `in()`. 

Key configuration options include:

- **Defining a Base Test Case:** You can specify a base test case class to be used by all tests within a specific directory or the entire suite.

    
```php
// $this --> \PHPUnit\Framework\TestCase -- by default
it('has home', function () {
    echo get_class($this); // \PHPUnit\Framework\TestCase
 
    $this->assertTrue(true);
});

pest()->uses(Tests\TestCase::class)->in('Feature');
pest()->extend(Tests\TestCase::class)->in('Feature');

// tests/Feature/ExampleTest.php
it('has home', function () {
    echo get_class($this); // \Tests\TestCase
});

// glob pattern in(**)
pest()->extend(Tests\TestCase::class)->in('Feature/*Job*.php');
```
    
    
This allows you to share common functionality and access the underlying PHPUnit assertion API via the `$this` variable.

- **Applying Traits:** You can apply a trait (like Laravel's `RefreshDatabase` trait) to specific test files or directories.
    
    
```php
pest()->uses(\Illuminate\Foundation\Testing\RefreshDatabase::class)->in('Feature');
```

    
- **Global Hooks:** You can register `beforeEach()`, `afterEach()`, `beforeAll()`, and `afterAll()` hooks that run before or after each test or test suite.
- **Custom Expectations:** Define custom expectations using the `expect()->extend()` method to create a more expressive testing syntax.
- **Grouping Tests:** Organize tests into groups using the `group()` method which can then be filtered using the `--group` CLI option.

2. `phpunit.xml`

As Pest is a layer on top of PHPUnit, this XML file configures low-level settings such as: 

- **Environment Variables:** Define environment variables specifically for testing (e.g., to use a separate test database).
- **Test Suites and Directories:** Specify which directories and files should be scanned for tests. By default, Pest looks in the `tests` directory.
- **Bootstrap File:** Define a PHP script that is included before the tests run.
- **Display Options:** Control output formats, colors, and the display of skipped or incomplete tests using command-line arguments that are often configured via this file.


3. Command Line Interface (CLI) Options

Pest offers various CLI options for running and configuring tests: 

- `--init`: Initializes a standard Pest configuration in your project.
- `-c` or `--configuration <file>`: Read configuration from a specific XML file.
- `--test-directory <dir>`: Specify the directory containing your tests and `Pest.php` file.
- `--coverage-*`: Options for configuring code coverage reports (requires a coverage driver like PCOV or Xdebug).
- `--parallel`: Runs tests in parallel to speed up execution time.

## Writing Tests

### Definitions, Naming, Conventions

- No test classes needed — Pest tests are simple files with `test()` functions.
- Test files should end with `Test.php` and follow project structure.
- Pest supports PHPUnit test format too (for gradual migration).
- Always public closure-based test functions.

```php
test('simple assertion', function () {     
	expect(1)->toBe(1); 
});
```


### Assertions

Pest supports both **expect API** and PHPUnit assertions.

#### Expect API examples

```php
expect(1)->toBe(1); 
expect('hello')->toBeString(); 
expect([1, 2])->toHaveCount(2); 
expect(fn() => throw new Exception())->toThrow(Exception::class);
```

#### Using PHPUnit assertions

```php
test('assert equals', function () {     
	$this->assertEquals(10, 5 + 5); 
});
```


### Tips

#### Mark test incomplete / skipped

```php
test('unfinished')->markTestIncomplete();  
test('feature not ready')->skip('Coming soon');
```

### Data Providers (Datasets)

Pest uses built-in **datasets** instead of PHPUnit data providers.

```php
dataset('numbers', [     
	[1, 1],     
	[5, 5], 
]);  

test('sum works', function ($a, $b) {     
	expect($a)->toEqual($b); 
})->with('numbers');
```

Inline dataset:

```php 
test('compare values')     
	->with([         
			[10, 10],         
			[20, 20],     
		])     
		->expect(fn($a, $b) => expect($a)->toBe($b));
```


### Test Doubles

Since Pest runs on PHPUnit, test doubles use PHPUnit APIs.
#### Stubs

```php
$stub = $this->createStub(Service::class); 
$stub->method('run')->willReturn('done'); 

expect($stub->run())->toBe('done');
```

#### Mocks

```php
$mock = $this->createMock(Service::class); 
$mock->expects($this->once())      
	 ->method('save')      
	 ->with('data')      
	 ->willReturn(true);  
	 
expect($mock->save('data'))->toBeTrue();
```

Mock method expectations remain identical to PHPUnit.


### Exception Testing

```php
test('throws exception', function () {     
	throw new RuntimeException('Error!'); 
})->throws(RuntimeException::class, 'Error!');
```

Or using expect syntax:

```php
expect(fn() => throw new RuntimeException())->toThrow(RuntimeException::class);
```


### Fixtures

Pest replaces `setUp()` / `tearDown()` with **beforeEach()** and **afterEach()**

```php
beforeEach(function () {     
	$this->value = 10; 
});  

afterEach(function () {     
	unset($this->value); 
});  

test('value exists', function () {     
	expect($this->value)->toBe(10); 
});
```

Class-wide setup:

```php
beforeAll(fn() => /* run before all tests */); 
afterAll(fn() => /* run after all tests */);
```


### Code Coverage

#### Install Coverage Plugin

```shell
composer require pestphp/pest-plugin-coverage --dev
```

#### Run with coverage

```shell
./vendor/bin/pest --coverage
```

HTML report:

```shell
./vendor/bin/pest --coverage-html tests/coverageReports
```


## Resources

- **[Pest Docs](https://pestphp.com)**
