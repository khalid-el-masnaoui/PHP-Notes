
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

### Linked List

- **Concept:**  A linear collection of data elements (nodes) where each node contains data and a pointer (or reference) to the next node in the sequence.
    
- **Operations** : 
	- **Doubly Linked:**  Each node in the list maintains pointers to both the previous and next nodes, enabling efficient traversal in both forward and backward directions.
    
	- **Efficient Operations:**  Adding or removing elements at either end of the list (`push`, `pop`, `unshift`, `shift`) typically has an `O(1)` time complexity, making it suitable for implementing stacks and queues.
    
	- **Iterator Support:**  The class implements the `Iterator` interface, allowing for easy iteration over the list elements using constructs like `foreach`.
    
	- **Iterator Modes:**  You can set the iteration mode using `setIteratorMode()` to control how the list is traversed (e.g., `LIFO` for stack-like behavior, `FIFO` for queue-like behavior).
    
	- **Array-like Access:**  It supports array-like access using `offsetGet()`, `offsetSet()`, `offsetExists()`, and `offsetUnset()` for accessing and manipulating elements by index, though this can be less efficient than operations at the ends of the list.

```php
// Create a new SplDoublyLinkedList instance
$list = new SplDoublyLinkedList();

// Add elements to the end of the list using push()
$list->push("Apple");
$list->push("Banana");
$list->push("Cherry");

echo "Original List (FIFO iteration):" . PHP_EOL;
// Set iterator mode to FIFO (First In, First Out)
$list->setIteratorMode(SplDoublyLinkedList::IT_MODE_FIFO);
foreach ($list as $value) {
    echo $value . PHP_EOL;
}

echo PHP_EOL . "Original List (LIFO iteration):" . PHP_EOL;
// Set iterator mode to LIFO (Last In, First Out)
$list->setIteratorMode(SplDoublyLinkedList::IT_MODE_LIFO);
foreach ($list as $value) {
    echo $value . PHP_EOL;
}

// Add an element to the beginning of the list using unshift()
$list->unshift("Date");

echo PHP_EOL . "List after unshift (FIFO iteration):" . PHP_EOL;
$list->setIteratorMode(SplDoublyLinkedList::IT_MODE_FIFO);
foreach ($list as $value) {
    echo $value . PHP_EOL;
}

// Remove an element from the end of the list using pop()
$removedEnd = $list->pop();
echo PHP_EOL . "Removed from end: " . $removedEnd . PHP_EOL;

// Remove an element from the beginning of the list using shift()
$removedStart = $list->shift();
echo "Removed from start: " . $removedStart . PHP_EOL;

echo PHP_EOL . "List after pop and shift (FIFO iteration):" . PHP_EOL;
$list->setIteratorMode(SplDoublyLinkedList::IT_MODE_FIFO);
foreach ($list as $value) {
    echo $value . PHP_EOL;
}

// Get the element at the top (last element in FIFO, first in LIFO)
echo PHP_EOL . "Top element: " . $list->top() . PHP_EOL;

// Get the element at the bottom (first element in FIFO, last in LIFO)
echo "Bottom element: " . $list->bottom() . PHP_EOL;

// Get the number of elements in the list
echo "Number of elements: " . $list->count() . PHP_EOL;

  
// Accessing elements by index  
echo "\nElement at index 0: " . $list->offsetGet(0) . "\n";

```

### Stack

- **Concept:**  A linear data structure that follows the `Last-In, First-Out (LIFO)` principle (extends `SplDoublyLinkedList` with `SplDoublyLinkedList::IT_MODE_LIFO | SplDoublyLinkedList::IT_MODE_KEEP`).
    
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

- **Concept:**  A linear data structure that follows the `First-In, First-Out (FIFO)` principle  (extends `SplDoublyLinkedList` with `SplDoublyLinkedList::IT_MODE_FIFO`).
    
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

### Heap

- **Concept:**  
	- A region of memory used for dynamic memory allocation, where data can be allocated and deallocated at runtime. It's less ordered than a `stack` or `queue`.
	- Heaps are a type of specialized tree-based data structure that satisfies the heap property, which dictates a specific ordering between parent and child nodes.
    
- **Operations:**  
	- **Abstract Base Class:**  `SplHeap` itself cannot be instantiated directly. Instead, concrete implementations like `SplMinHeap` and `SplMaxHeap` extend it, defining the specific ordering (minimum or maximum element at the top).
	- **Heap Property:**  Ensures that the parent node's value is either greater than or equal to (in a max-heap) or less than or equal to (in a min-heap) the values of its children.    
    - `insert($value)`: Adds an element to the heap, maintaining the heap property.
    - `extract()`: Removes and returns the top element of the heap (the minimum in `SplMinHeap`, maximum in `SplMaxHeap`).
    - `top()`: Returns the top element without removing it.
    - `isEmpty()`: Checks if the heap is empty.
    - `count()`: Returns the number of elements in the heap.
    - `compare($value1, $value2)`: An abstract method that must be implemented by concrete heap classes to define the comparison logic for ordering elements.
    -  **Iterator Interface:**  `SplHeap` implements the `Iterator` interface, allowing you to traverse the elements of the heap (though the order of iteration is not guaranteed to be sorted).
	- **Corruption Handling:**  Includes methods like `isCorrupted()` and `recoverFromCorruption()` to manage potential issues arising from exceptions during the `compare()` method.
    
- **Use Cases:**  Storing objects whose lifetime is not tied to a specific function scope, large data structures, shared data between different parts of a program.

```php
$minHeap = new SplMinHeap();

$minHeap->insert(10);
$minHeap->insert(5);
$minHeap->insert(20);
$minHeap->insert(2);

echo "Top element: " . $minHeap->top() . "\n"; // Output: Top element: 2

echo "Elements in Min Heap (ascending order):\n";
// Loop to display the elements, starting from the top and moving down
for ($minHeap->top(); $minHeap->valid(); $minHeap->next()) {
    echo $minHeap->current() . "\n";
}

// Accessing the top element without removing it
echo "\nTop element of Min Heap: " . $minHeap->top() . "\n";

// Extracting elements (removes and returns the top element)
while (!$minHeap->isEmpty()) {
    echo "Extracting: " . $minHeap->extract() . "\n";
}
// Output:
// Extracting: 2
// Extracting: 5
// Extracting: 10
// Extracting: 20
```

**Custom Heap Implementation**

```php
class Team
{
    public $name;
    public $score;

    public function __construct($name, $score)
    {
        $this->name = $name;
        $this->score = $score;
    }
}

class TeamRankingHeap extends SplMaxHeap
{
    /**
     * Compare two elements to determine their order in the heap.
     * For a Max Heap, return a positive value if $value1 is greater than $value2,
     * a negative value if $value1 is less than $value2, and 0 if they are equal.
     */
    public function compare($value1, $value2)
    {
        // Sort by score in descending order
        return $value1->score - $value2->score;
    }
}

// Create a custom heap
$rankingHeap = new TeamRankingHeap();

// Insert Team objects
$rankingHeap->insert(new Team("Team A", 100));
$rankingHeap->insert(new Team("Team B", 150));
$rankingHeap->insert(new Team("Team C", 80));
$rankingHeap->insert(new Team("Team D", 120));

echo "Team Rankings (highest score at top):\n";
while (!$rankingHeap->isEmpty()) {
    $team = $rankingHeap->extract();
    echo "Team: " . $team->name . ", Score: " . $team->score . "\n";
}
```

## Iterators 

Traditional PHP loops can get messy, especially when dealing with large datasets. SPL’s **Iterator classes** allow us to **traverse objects more elegantly and efficiently**.

- **`Iterator` Interface** :  The fundamental interface that all custom iterators must implement. It defines five methods: 
	- `current()`:  returns the current element (current value).
	- `key()`: returns the key/index of the current element
	- `next()`:moves the cursor forward to the next element
	- `rewind()`:  rewinds the cursor to the first element of the iterator.
	- `valid()`: checks have there is any element left. If so then return true otherwise return false.
    
- **`IteratorAggregate` Interface** :  Allows an object to provide an external iterator to traverse its internal data. The `getIterator()` method must return an object implementing the `Iterator` interface.


### Array Iterator

The PHP `SPL ArrayIterator`provides a way to iterate over arrays and objects as if they were arrays. It implements the `Iterator` interface, allowing for consistent iteration behavior across different data structures.

`OffsetGet`, `offsetSet` and `offsetUnset` methods are available.

```php
//iterate over an array
$myArray = ['apple', 'banana', 'cherry'];  
$arrayIterator = new ArrayIterator($myArray);  
  
foreach ($arrayIterator as $key => $value) {  
	echo "Key: $key, Value: $value\n";  
}

//iterate over an object
class MyObject {
	public $prop1 = 'value1';
	public $prop2 = 'value2';
}

$myObject = new MyObject();
$objectIterator = new ArrayIterator($myObject);

foreach ($objectIterator as $key => $value) {
	echo "Key: $key, Value: $value\n";
}

//Modification
$data = ['a' => 1, 'b' => 2, 'c' => 3];
$iterator = new ArrayIterator($data);

foreach ($iterator as $key => $value) {
	if ($key === 'b') {
		$iterator->offsetUnset($key); // Remove element
	} else {
		$iterator->offsetSet($key, $value * 10); // Modify value
	}
}

// ARRAY_AS_PROPS
$array = ['name' => 'John', 'age' => 30];
$arrayObject = new ArrayObject($array, ArrayObject::ARRAY_AS_PROPS);

// Accessing internal array elements as object properties
echo $arrayObject->name; // Output: John

// Setting a new internal array element as an object property
$arrayObject->city = 'New York';
echo $arrayObject['city']; // Output: New York
```