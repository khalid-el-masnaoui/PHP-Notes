
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

- **Concept:**  A linear data structure that follows the `Last-In, First-Out (LIFO)` principle (extends `SplDoublyLinkedList`).
    
- **Operations:** 
	- `push(mixed $value)`: Adds an element to the top of the stack.
	- `pop(): mixed`: Removes and returns the element from the top of the stack. Throws `UnderflowException` if the stack is empty.
	- `top(): mixed`: Returns the element at the top of the stack without removing it. Throws `UnderflowException` if the stack is empty.
	- `isEmpty(): bool`: Checks if the stack is empty.
	- `count(): int`: Returns the number of elements in the stack.
	- **Array Access:** You can use array-like syntax to add elements (`$stack[] = 'value'`) but direct access for retrieval or modification at arbitrary indices is not the intended use for a stack.
	- **Iteration:** `SplStack` is iterable, and when iterated, it yields elements in LIFO order.
	    
- **Use Cases:**  Function call management (call stack), expression evaluation, undo/redo functionality, browsing history management ..


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


### Queue

- **Concept:**  A linear data structure that follows the `First-In, First-Out (FIFO)` principle  (extends `SplDoublyLinkedList`).
    
- **Operations:** 
	- `enqueue` : add an element to the rear)
	- `dequeue` : remove an element from the front
	-  `bottom` : view the element at the front of the queue without removing it.
	-  `isEmpty()` : check if the queue contains any elements
	- `count()` :  returns the number of elements currently in the queue.
	- **Iterator Mode:** The `SplQueue` can be iterated over in `FIFO` order
    
- **Use Cases:**  Task scheduling, breadth-first search algorithms, managing requests in a system.

```php
$queue = new SplQueue();
$queue->enqueue("Task A");
$queue->enqueue("Task B");

$firstTask = $queue->dequeue(); // $firstTask will be "Task A"

$nextTask = $queue->bottom(); // $nextTask will be "Task B"

if ($queue->isEmpty()) {  
	echo "Queue is empty.";  
}

$numberOfTasks = $queue->count(); // $numberOfTasks will be 1 after the dequeue operation above

```


**Task Management with `SplQueue`**

```php
// Using SplQueue to manage tasks
$tasks = new SplQueue();

// Adding tasks to the queue
$tasks->enqueue('Process Order 101');
$tasks->enqueue('Send Email to Customer');
$tasks->enqueue('Restock Inventory');

// Processing the first task
echo $tasks->dequeue(); // Outputs: Process Order 101
```