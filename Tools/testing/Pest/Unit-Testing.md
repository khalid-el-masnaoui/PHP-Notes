# Pest Unit Testing

Pest is a modern PHP testing framework that focuses on simplicity and developer experience. While PHPUnit is class-based, Pest uses a more expressive, functional API — but remains fully compatible with PHPUnit under the hood.

## Table of Contents

- **[Pest Unit Testing](#pest-unit-testing)**
   * **[Example-1 : Simple User class](#example-1-simple-user-class)**
   * **[Example-2 : Calculator class with datasets](#example-2-calculator-class-with-datasets)**
   * **[Example-3 : User Service class with fixtures](#example-3-user-service-class-with-fixtures)**
   * **[Example-4 : Mocking dependencies in Pest](#example-4-mocking-dependencies-in-pest)**
   * **[Example-5 : Database Service mock](#example-5-database-service-mock)**

## Example-1 : Simple User class

1. **`User` Class**

```php
namespace App;

use InvalidArgumentException;

final class User
{
    public int $age;
    public array $favoriteMovies = [];
    public string $name;

    public function __construct(int $age, string $name)
    {
        $this->age = $age;
        $this->name = $name;
    }

    public function tellName(): string
    {
        return "My name is " . $this->name . ".";
    }

    public function tellAge(): string
    {
        return "I am " . $this->age . " years old.";
    }

    public function addFavoriteMovie(string $movie): bool
    {
        $this->favoriteMovies[] = $movie;
        return true;
    }

    public function removeFavoriteMovie(string $movie): bool
    {
        if (!in_array($movie, $this->favoriteMovies)) {
            throw new InvalidArgumentException("Unknown movie: " . $movie);
        }

        unset($this->favoriteMovies[array_search($movie, $this->favoriteMovies)]);
        return true;
    }
}

```

2. **`tests/Unit/UserTest.php`**

```php
use App\User;

it('initializes the class properly', function () {
    $user = new User(30, 'Alice');

    expect($user->name)->toBe('Alice');
    expect($user->age)->toBe(30);
    expect($user->favoriteMovies)->toBeEmpty();
});

it('returns name string', function () {
    $user = new User(30, 'Alice');

    expect($user->tellName())
        ->toBeString()
        ->toContain('Alice');
});

it('returns age string', function () {
    $user = new User(30, 'Alice');

    expect($user->tellAge())
        ->toBeString()
        ->toContain('30');
});

it('adds a favorite movie', function () {
    $user = new User(30, 'Alice');

    expect($user->addFavoriteMovie('Inception'))->toBeTrue();
    expect($user->favoriteMovies)->toContain('Inception');
    expect($user->favoriteMovies)->toHaveCount(1);
});

it('removes a favorite movie', function () {
    $user = new User(30, 'Alice');
    $user->addFavoriteMovie('Inception');

    expect($user->removeFavoriteMovie('Inception'))->toBeTrue();
    expect($user->favoriteMovies)->not->toContain('Inception');
    expect($user->favoriteMovies)->toBeEmpty();
});

```


## Example-2 : Calculator class with **datasets**

1. **`Calculator` Class**

```php
namespace App;

final class Calculator
{
    public function add(int $a, int $b): int { return $a + $b; }
    public function subtract(int $a, int $b): int { return $a - $b; }
}

```

2. **`tests/Unit/CalculatorTest.php`**

```php
use App\Calculator;

dataset('add_cases', [
    [2, 3, 5],
    [0, 5, 5],
    [-2, -3, -5],
    [5, -2, 3]
]);

it('adds numbers correctly', function ($a, $b, $expected) {
    expect((new Calculator())->add($a, $b))->toBe($expected);
})->with('add_cases');

dataset('subtract_cases', [
    [5, 2, 3],
    [5, 0, 5],
    [-5, -2, -3],
    [2, -5, 7]
]);

it('subtracts numbers correctly', function ($a, $b, $expected) {
    expect((new Calculator())->subtract($a, $b))->toBe($expected);
})->with('subtract_cases');
```


## Example-3 : User Service class with fixtures

1. **`UserService` Class**

```php
namespace App\Service;

final class UserService
{
    private array $users;

    public function __construct(array $users) { $this->users = $users; }

    public function findUserByEmail(string $email): ?array
    {
        return collect($this->users)->first(fn($u) => $u['email'] === $email);
    }

    public function getActiveUsers(): array
    {
        return array_filter($this->users, fn($u) => $u['active']);
    }
}
```


3. Fixtures `tests/fixtures/users.php`

```php
return [
    ['id'=>1,'name'=>'Alice','email'=>'alice@example.com','active'=>true],
    ['id'=>2,'name'=>'Bob','email'=>'bob@example.com','active'=>false],
    ['id'=>3,'name'=>'Charlie','email'=>'charlie@example.com','active'=>true],
];
```


3. **`tests/Unit/UserServiceTest.php`**

```php
use App\Service\UserService;

beforeEach(function () {
    $this->fixtures = require __DIR__.'/fixtures/users.php';
    $this->service = new UserService($this->fixtures);
});

it('finds user by email', function () {
    $user = $this->service->findUserByEmail('alice@example.com');

    expect($user)->not->toBeNull();
    expect($user['name'])->toBe('Alice');
});

it('returns null for unknown email', function () {
    expect($this->service->findUserByEmail('unknown@example.com'))->toBeNull();
});

it('gets active users', function () {
    $active = $this->service->getActiveUsers();

    expect($active)->toHaveCount(2);
    expect(array_column($active, 'name'))->toEqual(['Alice', 'Charlie']);
});
```


## Example-4 : Mocking dependencies in Pest

1. **`UserService` Class**

```php
namespace App\Service;

use App\Repository\UserRepository;

class UserService
{
    private $userRepository;

    public function __construct(UserRepository $userRepository)
    {
        $this->userRepository = $userRepository;
    }

    public function getUserById(int $id): ?array
    {
        return $this->userRepository->find($id);
    }

    public function createUser(string $name, string $email): array
    {
        // Imagine some validation or business logic here
        $userData = [
            'name' => $name,
            'email' => $email,
        ];
        return $this->userRepository->save($userData);
    }
}
```

2. **`UserRepository` dependency class**

```php
namespace App\Repository;

class UserRepository
{
    public function find(int $id): ?array
    {
        // In a real application, this would interact with a database
        // For this example, we'll return a dummy user
        if ($id === 1) {
            return ['id' => 1, 'name' => 'John Doe', 'email' => 'john.doe@example.com'];
        }
        return null;
    }

    public function save(array $userData): array
    {
        // In a real application, this would persist data to a database
        // For this example, we'll simulate saving and returning the data
        $userData['id'] = rand(100, 999); // Assign a dummy ID
        return $userData;
    }
}
```

3. **`tests/Unit/UserServiceTest.php`**

> Pest can use PHPUnit mocks or Mockery — here we use PHPUnit mocks


```php
use App\Repository\UserRepository;
use App\Service\UserService;

it('gets user by id', function () {
    $repo = mock(UserRepository::class, function ($mock) {
        $mock->shouldReceive('find')
            ->with(1)
            ->andReturn(['id'=>1,'name'=>'Mocked User','email'=>'mock@example.com']);
    });

    $service = new UserService($repo);

    $user = $service->getUserById(1);

    expect($user)->not->toBeNull();
    expect($user['name'])->toBe('Mocked User');
});

it('creates user', function () {
    $repo = mock(UserRepository::class, function ($mock) {
        $mock->shouldReceive('save')
            ->once()
            ->with(['name'=>'Jane Doe','email'=>'jane@example.com'])
            ->andReturn(['id'=>200,'name'=>'Jane Doe','email'=>'jane@example.com']);
    });

    $service = new UserService($repo);

    $user = $service->createUser('Jane Doe','jane@example.com');

    expect($user['id'])->toBe(200);
    expect($user['name'])->toBe('Jane Doe');
});

```


## Example-5 : Database Service mock

> PHPUnit’s DBUnit is old — Pest encourages dependency abstraction + mocks

```php
use App\Service\DatabaseService;

it('gets user by id using database mock', function () {
    $pdo = mock(PDO::class, function ($mock) {
        $mock->shouldReceive('query')
            ->andReturn(collect([
                ['id'=>1,'name'=>'John Doe','email'=>'john@example.com'],
                ['id'=>2,'name'=>'Jane Smith','email'=>'jane@example.com'],
            ]));
    });

    $db = new DatabaseService($pdo);

    $user = $db->getUserById(1);

    expect($user['name'])->toBe('John Doe');
    expect($user['email'])->toBe('john@example.com');
});
```