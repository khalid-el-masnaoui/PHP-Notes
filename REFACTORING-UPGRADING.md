
# PHP Refactoring and Upgrading

As a software engineer, you should always look for ways to improve your code.Applications must be regularly updated and maintained.

Refactoring and Upgrading  are distinct but often **intertwined** processes aimed at improving the quality, maintainability, and performance of a PHP application.


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

### Starting With Refactoring Guideline

The "rewrite everything" approach is tempting for several reasons. **Starting fresh means freedom from technical debt** and outdated design patterns

However, rewrites **consistently take longer than initially estimated**, often by factors of 2-3x. **Critical business logic and edge cases** can be buried in the old code and easily overlooked. Users expect all existing functionality to work, including obscure features you may not even know exist. Fresh codebases introduce their own bugs, sometimes replacing old problems with new ones.

A complete refactoring comes with its problems as well:
> **The primary cause of refactoring problems is fragmentation or lack of proper project knowledge on the application’s business model and more.**

A more balanced approach recognizes the value in both preserving what works and improving what doesn't. `=>` **Incremental Refactoring**

**When a Rewrite Makes Sense :**
	Despite favoring refactoring in most cases, complete rewrites can be justified when **the technology stack is truly obsolete** (e.g., PHP 5.3 or earlier), business requirements have fundamentally changed, the application needs to serve dramatically different purposes, or the current architecture simply cannot support essential new features. 

For optimal results, refactoring efforts should be performed concurrently with producing business knowledge. You can analyze each and every area of a module individually over an extended period of time while shaping a **repeatable refactoring process for the whole app**.

I will be discussing how we can reduce to eliminate such problems with some intuitive well known strategies 


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