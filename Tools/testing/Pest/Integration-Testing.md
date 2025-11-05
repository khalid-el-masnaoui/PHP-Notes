
# Pest Integration Testing

**Pest** provides a cleaner, expressive syntax and works perfectly for integration testing in PHP applications too.

Integration tests verify **real interactions between services**, or between the application and external systems (database, API, filesystem, etc.).


##  Example 1 — Payment Processor (real services)

1. **`PaymentProcessor` Class**

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

2. **`DiscountService` dependency class**

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

3. **`TaxService` dependency class**

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

3.  `tests/Integration/PaymentProcessorTest.php`
```php

use App\Service\DiscountService;
use App\Service\TaxService;
use App\PaymentProcessor;

beforeEach(function () {
    $discountService = new DiscountService();
    $taxService = new TaxService();
    $this->processor = new PaymentProcessor($discountService, $taxService);
});

it('processes payment with coupon', function () {
    $result = $this->processor->processPayment(100, 'US', 'SAVE10');

    expect($result['discount'])->toBe(10.0);
    expect($result['tax'])->toBe(6.3);
    expect($result['total'])->toBe(96.3);
});

it('processes payment with large order discount', function () {
    $result = $this->processor->processPayment(300, 'UK');

    expect($result['discount'])->toBe(15.0);
    expect($result['tax'])->toBe(57.0);
    expect($result['total'])->toBe(342.0);
});

it('processes payment without discount', function () {
    $result = $this->processor->processPayment(50, 'FR');

    expect($result['discount'])->toBe(0.0);
    expect($result['tax'])->toBe(7.5);
    expect($result['total'])->toBe(57.5);
});
```


## Example 2 — User Service + In-Memory SQLite DB


1. **`UserService` Class**

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

2. **`UserRepository` dependency class**

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