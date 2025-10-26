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

