# PHPUnit Integration Testing

PHPUnit, while primarily known for unit testing, can also be utilized for integration testing in PHP applications. Integration testing, in contrast to unit testing, focuses on verifying the interactions and communication between different components or modules of a system, or between the system and external dependencies like databases or APIs.

## Examples

### Example-1 : Payment Processor class with two dependencies classes

1. **`PaymentProcessor` Class**

```php
namespace App;

use App\Service\DiscountService;
use App\Service\TaxService;

class PaymentProcessor
{
    private DiscountService $discountService;
    private TaxService $taxService;

    public function __construct(DiscountService $discountService, TaxService $taxService)
    {
        $this->discountService = $discountService;
        $this->taxService = $taxService;
    }

    public function processPayment(float $amount, string $country, ?string $coupon = null): array
    {
        $discount = $this->discountService->calculateDiscount($amount, $coupon);
        $afterDiscount = $amount - $discount;

        $tax = $this->taxService->calculateTax($afterDiscount, $country);
        $total = $afterDiscount + $tax;

        return [
            'original' => $amount,
            'discount' => round($discount, 2),
            'tax' => round($tax, 2),
            'total' => round($total, 2),
        ];
    }
}
```

2. **`DiscountService` dependency class**

```php
namespace App\Service;

class DiscountService
{
    public function calculateDiscount(float $amount, string $couponCode = null): float
    {
        if ($couponCode === 'SAVE10') {
            return $amount * 0.10; // 10% discount
        }

        if ($amount > 200) {
            return $amount * 0.05; // 5% discount for large orders
        }

        return 0.0;
    }
}
```

3. **`TaxService` dependency class**

```php
namespace App\Service;

class TaxService
{
    public function calculateTax(float $amount, string $country): float
    {
        $rates = [
            'US' => 0.07,
            'UK' => 0.20,
            'FR' => 0.15,
        ];

        $rate = $rates[$country] ?? 0.10;
        return $amount * $rate;
    }
}
```

4. **`PaymentIntegrationTest` Class**

```php
namespace Tests\Integration;

use App\Service\DiscountService;
use App\Service\TaxService;
use App\PaymentProcessor;
use PHPUnit\Framework\TestCase;

class PaymentIntegrationTest extends TestCase
{
    private PaymentProcessor $processor;

    protected function setUp(): void
    {
        // Integration: use real instances of both services
        $discountService = new DiscountService();
        $taxService = new TaxService();
        $this->processor = new PaymentProcessor($discountService, $taxService);
    }

    public function testPaymentWithCoupon()
    {
        $result = $this->processor->processPayment(100, 'US', 'SAVE10');

        $this->assertEquals(10.0, $result['discount']); // 10% off
        $this->assertEquals(6.3, $result['tax']);       // tax after discount
        $this->assertEquals(96.3, $result['total']);
    }

    public function testPaymentWithLargeOrderDiscount()
    {
        $result = $this->processor->processPayment(300, 'UK');

        $this->assertEquals(15.0, $result['discount']); // 5% off
        $this->assertEquals(57.0, $result['tax']);      // 20% VAT
        $this->assertEquals(342.0, $result['total']);
    }

    public function testPaymentWithoutDiscount()
    {
        $result = $this->processor->processPayment(50, 'FR');

        $this->assertEquals(0.0, $result['discount']);
        $this->assertEquals(7.5, $result['tax']);
        $this->assertEquals(57.5, $result['total']);
    }
}
```

### Example-2 : User Service class with in-memory database 

1. **`UserService` Class**

```php
namespace App\Service;

use App\Repository\UserRepository;

class UserService
{
    private UserRepository $repository;

    public function __construct(UserRepository $repository)
    {
        $this->repository = $repository;
    }

    public function findUserByEmail(string $email): ?array
    {
        return $this->repository->findByEmail($email);
    }

    public function getActiveUsers(): array
    {
        return $this->repository->getActiveUsers();
    }
}
```

2. **`UserRepository` dependency class**

```php
namespace App\Repository;

class UserRepository
{
    private PDO $pdo;

    public function __construct(PDO $pdo)
    {
        $this->pdo = $pdo;
    }

    public function createTable(): void
    {
        $this->pdo->exec("
            CREATE TABLE users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT,
                email TEXT,
                active INTEGER
            )
        ");
    }

    public function seedData(): void
    {
        $stmt = $this->pdo->prepare("INSERT INTO users (name, email, active) VALUES (?, ?, ?)");
        $stmt->execute(['Alice', 'alice@example.com', 1]);
        $stmt->execute(['Bob', 'bob@example.com', 0]);
        $stmt->execute(['Charlie', 'charlie@example.com', 1]);
    }

    public function findByEmail(string $email): ?array
    {
        $stmt = $this->pdo->prepare("SELECT * FROM users WHERE email = ?");
        $stmt->execute([$email]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        return $user ?: null;
    }

    public function getActiveUsers(): array
    {
        $stmt = $this->pdo->query("SELECT * FROM users WHERE active = 1");
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
```

3. **`UserServiceTest` Class**

```php

use App\Repository\UserRepository;
use App\Service\UserService;
use PHPUnit\Framework\TestCase;

class UserIntegrationTest extends TestCase
{
    private PDO $pdo;
    private UserRepository $repository;
    private UserService $service;

    protected function setUp(): void
    {
        // Use in-memory SQLite database for integration tests
        $this->pdo = new PDO('sqlite::memory:');
        $this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        $this->repository = new UserRepository($this->pdo);
        $this->repository->createTable();
        $this->repository->seedData();

        $this->service = new UserService($this->repository);
    }

    public function testFindUserByEmailIntegration()
    {
        $user = $this->service->findUserByEmail('alice@example.com');

        $this->assertNotNull($user);
        $this->assertEquals('Alice', $user['name']);
    }

    public function testGetActiveUsersIntegration()
    {
        $activeUsers = $this->service->getActiveUsers();

        $this->assertCount(2, $activeUsers);
        $this->assertEquals(['Alice', 'Charlie'], array_column($activeUsers, 'name'));
    }
}
```

### Example-3 : User Repository class with in-memory database with SQL fixtures 


1. **`UserRepository` class**

```php
namespace App\Repository;

use PDO;

class UserRepository
{
    private PDO $pdo;

    public function __construct(PDO $pdo)
    {
        $this->pdo = $pdo;
    }

    public function findAll(): array
    {
        $stmt = $this->pdo->query('SELECT id, name, email FROM users');
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function findByEmail(string $email): ?array
    {
        $stmt = $this->pdo->prepare('SELECT id, name, email FROM users WHERE email = :email');
        $stmt->execute(['email' => $email]);
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        return $user ?: null;
    }
}
```

2. SQL data fixtures

```sql
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT NOT NULL
);

INSERT INTO users (name, email) VALUES
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com');

```

3. **`UserRepositoryTest` Class**

```php
namespace Tests\Integration\Repository;

use PHPUnit\Framework\TestCase;
use App\Repository\UserRepository;

class UserRepositoryTest extends TestCase
{
    private PDO $pdo;
    private UserRepository $repository;

    protected function setUp(): void
    {
        // Create in-memory SQLite DB for isolation
        $this->pdo = new PDO('sqlite::memory:');
        $this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

        // Load SQL fixture
        $fixture = file_get_contents(__DIR__ . '/fixtures/usersFixture.sql');
        $this->pdo->exec($fixture);

        $this->repository = new UserRepository($this->pdo);
    }

    public function testFindAllReturnsAllUsers(): void
    {
        $users = $this->repository->findAll();

        $this->assertCount(2, $users);
        $this->assertEquals('Alice', $users[0]['name']);
    }

    public function testFindByEmailReturnsCorrectUser(): void
    {
        $user = $this->repository->findByEmail('bob@example.com');

        $this->assertNotNull($user);
        $this->assertEquals('Bob', $user['name']);
    }

    public function testFindByEmailReturnsNullWhenNotFound(): void
    {
        $user = $this->repository->findByEmail('notfound@example.com');

        $this->assertNull($user);
    }

    protected function tearDown(): void
    {
        $this->pdo = null; // close connection
    }
}
```


### Example-4 : Currency Converter Service with fake API

1. **`CurrencyConverterService` class**

```php
namespace App\Service;

class CurrencyConverterService
{
    private ExchangeRateClient $client;

    public function __construct(ExchangeRateClient $client)
    {
        $this->client = $client;
    }

    public function convert(float $amount, string $from, string $to): float
    {
        $rate = $this->client->getRate($from, $to);
        if ($rate <= 0) {
            throw new InvalidArgumentException("Invalid exchange rate");
        }

        return round($amount * $rate, 2);
    }
}
```

1. **`ExchangeRateClient` dependency class**

```php
namespace App\Service;

class ExchangeRateClient
{
    private string $apiBase;

    public function __construct(string $apiBase)
    {
        $this->apiBase = rtrim($apiBase, '/');
    }

    public function getRate(string $from, string $to): float
    {
        $url = "{$this->apiBase}/rate?from={$from}&to={$to}";
        $response = file_get_contents($url);

        if ($response === false) {
            throw new RuntimeException("Failed to fetch exchange rate");
        }

        $data = json_decode($response, true);
        return $data['rate'] ?? 0.0;
    }
}
```

3. Fake API service `ExchangeRateStub.php`

```php
if ($_GET['from'] === 'USD' && $_GET['to'] === 'EUR') {
    echo json_encode(['rate' => 0.92]);
} elseif ($_GET['from'] === 'EUR' && $_GET['to'] === 'USD') {
    echo json_encode(['rate' => 1.09]);
} else {
    echo json_encode(['rate' => 0]);
}
```

4. **`CurrencyConverterIntegrationTest` Class**

```php
namespace Tests\Integration\Service;

use App\Service\ExchangeRateClient;
use App\Service\CurrencyConverterService;
use PHPUnit\Framework\TestCase;

class CurrencyConverterIntegrationTest extends TestCase
{
    private CurrencyConverterService $service;

    protected function setUp(): void
    {
        // Simulate API endpoint using the stub file
        $stubUrl = 'http://localhost/tests/Integration/Services/ExchangeRateStub.php';

        // In a real project, you might start a test server or use Guzzle + MockHandler
        $client = new ExchangeRateClient($stubUrl);
        $this->service = new CurrencyConverterService($client);
    }

    public function testUsdToEurConversion()
    {
        // Suppose rate = 0.92 from the stub
        $result = $this->service->convert(100, 'USD', 'EUR');
        $this->assertEquals(92.00, $result);
    }

    public function testEurToUsdConversion()
    {
        // Suppose rate = 1.09 from the stub
        $result = $this->service->convert(100, 'EUR', 'USD');
        $this->assertEquals(109.00, $result);
    }

    public function testInvalidCurrencyReturnsError()
    {
        $this->expectException(InvalidArgumentException::class);
        $this->service->convert(100, 'ABC', 'XYZ');
    }
}
```


### Example-5 : Weather Sync Service class with fake API and in-memory database

1. **`WeatherSyncService` Class**

```php

namespace App\Service;

use App\Repository\WeatherRepository;

class WeatherSyncService
{
    private WeatherApiClient $client;
    private WeatherRepository $repository;

    public function __construct(WeatherApiClient $client, WeatherRepository $repository)
    {
        $this->client = $client;
        $this->repository = $repository;
    }

    public function sync(string $city): void
    {
        $weatherData = $this->client->fetchWeather($city);
        $this->repository->save($weatherData);
    }
}
```

2. **`WeatherApiClient` dependency class**

```php
namespace App\Service;

class WeatherApiClient
{
    private string $baseUrl;

    public function __construct(string $baseUrl)
    {
        $this->baseUrl = rtrim($baseUrl, '/');
    }

    public function fetchWeather(string $city): array
    {
        $url = "{$this->baseUrl}/weather?city=" . urlencode($city);
        $response = file_get_contents($url);

        if ($response === false) {
            throw new RuntimeException("Failed to fetch weather data");
        }

        $data = json_decode($response, true);
        if (!isset($data['city']) || !isset($data['temperature'])) {
            throw new RuntimeException("Invalid API response");
        }

        return $data;
    }
}
```

3. **`WeatherRepository` dependency class**

```php
namespace App\Repository;

class WeatherRepository
{
    private PDO $pdo;

    public function __construct(PDO $pdo)
    {
        $this->pdo = $pdo;
    }

    public function createTable(): void
    {
        $this->pdo->exec("
            CREATE TABLE weather (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                city TEXT,
                temperature REAL,
                updated_at TEXT
            )
        ");
    }

    public function save(array $weatherData): void
    {
        $stmt = $this->pdo->prepare("
            INSERT INTO weather (city, temperature, updated_at)
            VALUES (:city, :temperature, :updated_at)
        ");
        $stmt->execute([
            ':city' => $weatherData['city'],
            ':temperature' => $weatherData['temperature'],
            ':updated_at' => date('Y-m-d H:i:s'),
        ]);
    }

    public function findByCity(string $city): ?array
    {
        $stmt = $this->pdo->prepare("SELECT * FROM weather WHERE city = :city LIMIT 1");
        $stmt->execute([':city' => $city]);
        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        return $result ?: null;
    }
}
```

4. Fake API `WeatherApiStub.php`

```php
header('Content-Type: application/json');

$city = $_GET['city'] ?? '';

$fakeData = [
    'Paris' => ['city' => 'Paris', 'temperature' => 18.5],
    'London' => ['city' => 'London', 'temperature' => 15.2],
    'New York' => ['city' => 'New York', 'temperature' => 21.0],
];

echo json_encode($fakeData[$city] ?? ['city' => $city, 'temperature' => 0]);
```
