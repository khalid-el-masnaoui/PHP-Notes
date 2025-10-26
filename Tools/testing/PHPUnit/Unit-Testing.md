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

