# PHPUnit Unit Testing

PHPUnit is primarily used for unit testing in PHP. It is a programmer-oriented testing framework designed to facilitate the testing of individual units or components of source code in isolation.

## Examples

### Example-1 : Simple User class

1. **`User` Class**

```php
namespace App;

use InvalidArgumentException;

final class User
{
    public int $age;
    public array $favoriteMovies = [];
    public string $name;
    /**
     * @param int $age
     * @param string $name
     */
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


2. **`UserTest` Class**

```php
namespace Tests;

use App\User;
use PHPUnit\Framework\TestCase;

final class UserTest extends TestCase
{
    public function testClassConstructor()
    {
        $user = new User(30, 'Alice');
        $this->assertSame('Alice', $user->name);
        $this->assertSame(30, $user->age);
        $this->assertEmpty($user->favoriteMovies);
    }
    public function testTellName()
    {
        $user = new User(30, 'Alice');
        $this->assertIsString($user->tellName());
        $this->assertStringContainsStringIgnoringCase('Alice', $user->tellName());
    }
    public function testTellAge()
    {
        $user = new User(30, 'Alice');
        $this->assertIsString($user->tellAge());
        $this->assertStringContainsStringIgnoringCase('30', $user->tellAge());
    }
    public function testAddFavoriteMovie()
    {
        $user = new User(30, 'Alice');
        $this->assertTrue($user->addFavoriteMovie('Inception'));
        $this->assertContains('Inception', $user->favoriteMovies);
        $this->assertCount(1, $user->favoriteMovies);
    }
    public function testRemoveFavoriteMovie()
    {
        $user = new User(30, 'Alice');
        $user->addFavoriteMovie('Inception');
        $this->assertTrue($user->removeFavoriteMovie('Inception'));
        $this->assertNotContains('Inception', $user->favoriteMovies);
        $this->assertEmpty($user->favoriteMovies);
    }
}
```

- **testClassConstructor()**: Verifies that the constructor correctly initializes the properties.
- **testTellName()**: Checks if the tellName method returns a string containing the user’s name.
- **testTellAge()**: Ensures the tellAge method returns a string that includes the user’s age.
- **testAddFavoriteMovie()**: Tests if adding a movie correctly updates the favorite movies list.
- **testRemoveFavoriteMovie()**: Validates that removing a movie updates the list and handles errors correctly.

### Example-2 : Calculator class with data providers

1. **`Calculator` Class**

```php
namespace App;

final class Calculator
{
    public function add(int $a, int $b): int
    {
        return $a + $b;
    }

    public function subtract(int $a, int $b): int
    {
        return $a - $b;
    }
}

```

2. **`CalculatorTest` Class**

```php
namespace Tests;

use App\Calculator;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

final class CalculatorTest extends TestCase
{
    /**
     * @return array<array<int>>
     */
    public static function provideAddCases(): array
    {
        return [
            'positive numbers' => [2, 3, 5],
            'zero with positive' => [0, 5, 5],
            'negative numbers' => [-2, -3, -5],
            'positive and negative' => [5, -2, 3],
        ];
    }

    #[DataProvider('provideAddCases')]
    public function testItAdds(int $num1, int $num2, int $expected): void
    {
        $calculator = new Calculator();
        $this->assertSame($expected, $calculator->add($num1, $num2));
    }

    /**
     * @return array<array<int>>
     */
    public static function provideSubtractCases(): array
    {
        return [
            'positive numbers' => [5, 2, 3],
            'zero with positive' => [5, 0, 5],
            'negative numbers' => [-5, -2, -3],
            'positive and negative' => [2, -5, 7],
        ];
    }

    #[DataProvider('provideSubtractCases')]
    public function testItSubtracts(int $num1, int $num2, int $expected): void
    {
        $calculator = new Calculator();
        $this->assertSame($expected, $calculator->subtract($num1, $num2));
    }
}
```


### Example-3 : User Service class with data fixtures

1. **`UserService`Class**

```php
namespace App\Service;

final class UserService
{
    private array $users;

    public function __construct(array $users)
    {
        $this->users = $users;
    }

    public function findUserByEmail(string $email): ?array
    {
        foreach ($this->users as $user) {
            if ($user['email'] === $email) {
                return $user;
            }
        }
        return null;
    }

    public function getActiveUsers(): array
    {
        return array_filter($this->users, fn($u) => $u['active']);
    }
}
```


2. Fixtures for the `UserService` Class testing

```php
// tests/fixtures/usersFixture.php

return [
    ['id' => 1, 'name' => 'Alice', 'email' => 'alice@example.com', 'active' => true],
    ['id' => 2, 'name' => 'Bob', 'email' => 'bob@example.com', 'active' => false],
    ['id' => 3, 'name' => 'Charlie', 'email' => 'charlie@example.com', 'active' => true],
];
```


3. **`UserServiceTest` Class**

```php
namespace Tests;

use App\Service\UserService;
use PHPUnit\Framework\TestCase;

final class UserServiceTest extends TestCase
{
    private array $fixtures;
    private UserService $userService;

    protected function setUp(): void
    {
        // Load fixture data
        $this->fixtures = require __DIR__ . '/fixtures/usersFixture.php';

        // Initialize service with fixture data
        $this->userService = new UserService($this->fixtures);
    }

    public function testFindUserByEmail()
    {
        $user = $this->userService->findUserByEmail('alice@example.com');

        $this->assertNotNull($user);
        $this->assertEquals('Alice', $user['name']);
    }

    public function testFindUserByEmailReturnsNullForUnknownEmail()
    {
        $user = $this->userService->findUserByEmail('unknown@example.com');
        $this->assertNull($user);
    }

    public function testGetActiveUsers()
    {
        $activeUsers = $this->userService->getActiveUsers();

        $this->assertCount(2, $activeUsers);
        $this->assertEquals(['Alice', 'Charlie'], array_column($activeUsers, 'name'));
    }
}
```

### Example-4 : User Service class with mocked dependency 

1. **`UserService` Class**

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
