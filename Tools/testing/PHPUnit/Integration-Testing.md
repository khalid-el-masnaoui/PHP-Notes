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

