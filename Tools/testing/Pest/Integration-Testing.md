
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