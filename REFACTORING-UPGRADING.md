
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


#### 7.Tools

There are several tools available that can help you refactor PHP code more efficiently. Some of the most popular tools include:

- **PhpStorm**: A popular IDE for PHP development that includes built-in refactoring tools and code analysis features.
- **PHPStan**: A static analysis tool that can help you find bugs and unused code in your PHP code.
- **PHP_CodeSniffer**: A tool that can detect violations of a defined coding standard and help you fix them (with its version compatibility checker).
- **Rector**: A PHP refactoring tool that can automatically fix code issues and apply best practices.
- `F2` key in `VsCode`: it renames all local variables, constants, functions, classes ... in the whole project
- Using **AI** to assist you in the refactoring process

These tools are covered in details in the folder `Tools`


## Reminder

Despite favoring refactoring in most cases, complete rewrites can be justified when **the technology stack is truly obsolete** (e.g., PHP 5.3 or earlier), business requirements have fundamentally changed, the application needs to serve dramatically different purposes, or the current architecture simply cannot support essential new features. 