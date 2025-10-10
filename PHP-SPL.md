
# PHP SPL

## Overview

The **Standard PHP Library (SPL)** is a collection of built-in interfaces, classes, and functions that enhance PHP’s OOP capabilities.


# Standard PHP Library (SPL)

The Standard PHP Library (SPL) is a collection of interfaces and classes that are meant to solve common programming challenges.

SPL aims to implement some efficient data access interfaces and classes for PHP. Functionally, it is designed to traverse aggregate structures (anything you want to loop over).

Despite its utility, the SPL remains underutilized by many in the PHP community.


Key features of SPL include:

- **Data Structures:** Pre-built classes for handling `stacks`,` queues`, and `heaps`
- **Iterators:** Objects that allow for **memory-efficient** looping over large datasets 
- **Observers and Subjects:** Implementation of the **Observer Design Pattern** for event-driven programming 
- **File Handling Enhancements:** More powerful tools for working with directories and file streams 

By embracing SPL, we can **write cleaner, faster, and more maintainable code**.



## Data Structures 

### Stack

- **Concept:**  A linear data structure that follows the `Last-In, First-Out (LIFO)` principle. (extends `SplDoublyLinkedList`)
    
- **Operations:** 
	- `push(mixed $value)`: Adds an element to the top of the stack.
	- `pop(): mixed`: Removes and returns the element from the top of the stack. Throws `UnderflowException` if the stack is empty.
	- `top(): mixed`: Returns the element at the top of the stack without removing it. Throws `UnderflowException` if the stack is empty.
	- `isEmpty(): bool`: Checks if the stack is empty.
	- `count(): int`: Returns the number of elements in the stack.
	- **Array Access:** You can use array-like syntax to add elements (`$stack[] = 'value'`) but direct access for retrieval or modification at arbitrary indices is not the intended use for a stack.
	- **Iteration:** `SplStack` is iterable, and when iterated, it yields elements in LIFO order.
	    
- **Use Cases:**  Function call management (call stack), expression evaluation, undo/redo functionality, browsing history management ..
    
- **Memory:**  Typically used for static memory allocation, local variables, and function call frames. Fast and efficient due to contiguous memory allocation and simple management.


```php
$stack = new SplStack();

// Push elements onto the stack
$stack->push('first');
$stack->push('second');
$stack->push('third');

echo "Top element: " . $stack->top() . "\n"; // Output: Top element: third

// Pop elements from the stack
echo "Popped: " . $stack->pop() . "\n"; // Output: Popped: third
echo "Popped: " . $stack->pop() . "\n"; // Output: Popped: second

// Check if stack is empty
if ($stack->isEmpty()) {
    echo "Stack is empty.\n";
} else {
    echo "Stack is not empty. Count: " . $stack->count() . "\n"; // Output: Stack is not empty. Count: 1
}

// Push another element using array-like syntax
$stack[] = 'fourth';

// Iterate through the stack
echo "Elements in stack:\n";
foreach ($stack as $item) {
    echo $item . "\n"; // Output: fourth, then first (LIFO order)
}

```


**Browsing History with `SplStack`**

```php
// Using SplStack to manage browsing history
$history = new SplStack();

// User visits various product pages
$history->push('Product A');
$history->push('Product B');
$history->push('Product C');

// Displaying the last visited product
echo $history->top(); // Outputs: Product C

// Going back in browsing history
$history->pop();
echo $history->top(); // Outputs: Product B
```