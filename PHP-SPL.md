
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

- **`RecursiveIterator` Interface:** Designed for iterating over recursive data structures, such as nested arrays or directory trees.
    - Defines two methods: `hasChildren()` and `getChildren()`.
    - `hasChildren()`: Returns `true` if the current element has children that can be iterated over, `false` otherwise.
    - `getChildren()`: Returns a `RecursiveIterator` for the children of the current element.

### Array Iterator

The PHP `SPL ArrayIterator`provides a way to iterate over arrays and objects as if they were arrays. It implements the `Iterator` interface, allowing for consistent iteration behavior across different data structures.

- **Array-like Interface:**  Provides methods like `offsetExists()`, `offsetGet()`, `offsetSet()`, and `offsetUnset()`, which mirror the functionality of array access.
    
- **Sorting:**  It includes methods for sorting the underlying data, such as `asort()`, `ksort()`, `natsort()`, `natcasesort()`, `uasort()`, and `uksort()`.
    
- **Seeking:**  The `seek()` method allows you to move the internal pointer to a specific position within the iterator.

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

//ArrayObject => ARRAY_AS_PROPS
$array = ['name' => 'John', 'age' => 30];
$arrayObject = new ArrayObject($array, ArrayObject::ARRAY_AS_PROPS);

// Accessing internal array elements as object properties
echo $arrayObject->name; // Output: John

// Setting a new internal array element as an object property
$arrayObject->city = 'New York';
echo $arrayObject['city']; // Output: New York
```


### Recursive Array Iterator

The `RecursiveArrayIterator` class  provides a way to iterate over multi-dimensional arrays and objects recursively. It extends the `ArrayIterator` class, offering the same capabilities for unsetting and modifying values and keys during iteration, but with the added ability to traverse nested structures.


- **Recursive Traversal:**  Unlike `ArrayIterator`, `RecursiveArrayIterator` can delve into nested arrays and objects.
    
- `hasChildren()` method:  This method determines if the current element being iterated over is an array or an object, indicating whether it can be further recursed into.
    
- `getChildren()` method:  If `hasChildren()` returns true, this method returns a new `RecursiveArrayIterator` instance for the child array or object, allowing for deeper iteration.
    
- Integration with `RecursiveIteratorIterator`:  `RecursiveArrayIterator` is commonly used in conjunction with `RecursiveIteratorIterator` to flatten a multi-dimensional structure and iterate over all its elements in a single loop.


This example demonstrates how `RecursiveArrayIterator` and `RecursiveIteratorIterator` work together to iterate through all elements of a nested array, printing each key-value pair.

```php
$data = [
    'fruit' => 'apple',
    'vegetables' => [
        'root' => 'carrot',
        'leafy' => 'spinach',
        'legumes' => [
            'type' => 'bean',
            'color' => 'green'
        ]
    ],
    'meat' => 'chicken'
];

$iterator = new RecursiveArrayIterator($data);
$recursiveIterator = new RecursiveIteratorIterator($iterator);

foreach ($recursiveIterator as $key => $value) {
    echo "Key: $key, Value: $value\n";
}

```

### Recursive Iterator Iterator

The `SPL RecursiveIteratorIterator` class provides a way to flatten a tree-like structure represented by a `RecursiveIterator` into a single, linear iteration. It acts as a decorator for `RecursiveIterator` instances, allowing you to traverse hierarchical data structures, such as nested arrays, directories, or XML documents, in a non-recursive manner.


- **Flattening Recursive Structures:**  It takes a `RecursiveIterator` (or an `IteratorAggregate` that can provide one) and allows you to iterate over all elements in the entire structure, including children and their descendants, as if they were in a flat list.
    
- **Modes of Iteration:**     
    - `RecursiveIteratorIterator::LEAVES_ONLY` (default): Iterates only over the leaf nodes of the structure.
    - `RecursiveIteratorIterator::SELF_FIRST`: Iterates over parent nodes before their children.
    - `RecursiveIteratorIterator::CHILD_FIRST`: Iterates over children before their parent nodes.
    
- **Depth Control:**
    
    - `setMaxDepth()`: Allows you to limit the depth of the recursion, preventing iteration beyond a certain level.
    - `getDepth()`: Returns the current depth of the iteration.
    
- **Accessing Inner Iterators:**
    
    - `getInnerIterator()`: Retrieves the `RecursiveIterator` that the `RecursiveIteratorIterator` is currently operating on at the current level.
    - `getSubIterator()`: Returns the current active sub-iterator, which is particularly useful when dealing with nested structures.

### Directory Iterator

The `DirectoryIterator` class provides an object-oriented interface for iterating over the contents of a filesystem directory. It allows you to easily access information about files and subdirectories within a given path.

The `$fileInfo` object in the loop  is an instance of `SplFileInfo` class = > provides methods to retrieve various details about the current entry:
- `$fileInfo->getFilename()`: Returns the name of the file or directory.
- `$fileInfo->getPathname()`: Returns the full path to the file or directory.
- `$fileInfo->isDir()`: Checks if the entry is a directory.
- `$fileInfo->isFile()`: Checks if the entry is a file.
- `$fileInfo->isDot()`: Checks if the entry is '.' or '..'. It's common practice to skip these entries.
- `$fileInfo->getSize()`: Returns the size of the file in bytes.
- `$fileInfo->getExtension()`: Returns the file extension.



```php
$directoryPath = __DIR__; // Current directory
$iterator = new DirectoryIterator($directoryPath);

echo "Contents of: " . $directoryPath . "\n";
foreach ($iterator as $fileInfo) {
	if ($fileInfo->isDot()) {
		continue; // Skip '.' and '..'
	}

	if ($fileInfo->isDir()) {
		echo "Directory: " . $fileInfo->getFilename() . "\n";
	} elseif ($fileInfo->isFile()) {
		echo "File: " . $fileInfo->getFilename() . " (Size: " . $fileInfo->getSize() . " bytes)\n";
	}
}

```

### File System Iterator

`FilesystemIterator`: Extending `DirectoryIterator`, offers enhanced control over how directory contents are iterated. It allows for specifying flags that influence the behavior of the iterator, such as how keys are generated, what information is returned by `current()`, and whether dot entries (`.` and `..`) are skipped.

- **Flags:** 
    
    `FilesystemIterator` provides several predefined flags to customize its behavior, such as:
    - `FilesystemIterator::KEY_AS_PATHNAME`: Makes `key()` return the full path of the current item.
    - `FilesystemIterator::KEY_AS_FILENAME`: Makes `key()` return only the filename of the current item.
    - `FilesystemIterator::CURRENT_AS_FILEINFO`: Makes `current()` return an `SplFileInfo` object, providing detailed information about the current item.
    - `FilesystemIterator::SKIP_DOTS`: Skips the special "." and ".." directory entries.

- **Methods:** It provides methods like `current()`, `key()`, `next()`, `rewind()`, `valid()`, `getFlags()`, and `setFlags()` for programmatic control over the iteration process and flag management.

```php

$path = '/var/www/html'; // Replace with your desired path
try {
    $iterator = new FilesystemIterator(
        $path,
        FilesystemIterator::SKIP_DOTS | FilesystemIterator::CURRENT_AS_FILEINFO
    );

    foreach ($iterator as $item) {
        if ($item->isFile()) {
            echo "File: " . $item->getFilename() . " (Size: " . $item->getSize() . " bytes)\n";
        } elseif ($item->isDir()) {
            echo "Directory: " . $item->getFilename() . "\n";
        }
    }
} catch (UnexpectedValueException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}

```


### Recursive Directory Iterator

The `SPL RecursiveDirectoryIterator` class provides an interface for recursively iterating over filesystem directories. It simplifies the process of traversing directory structures, including subdirectories and their contents. 


- **Recursive Traversal:**  Unlike `DirectoryIterator`, which only iterates over a single directory, `RecursiveDirectoryIterator` enables you to traverse an entire directory tree.
    
- Integration with `RecursiveIteratorIterator`:  To achieve true recursive iteration (tree traversal), `RecursiveDirectoryIterator` is typically used in conjunction with `RecursiveIteratorIterator`. `RecursiveIteratorIterator` handles the logic of descending into subdirectories and presenting the elements in a linear fashion.
    
- **Constructor:**  The constructor takes the path to the directory you want to iterate over and optional flags (e.g., `FilesystemIterator::SKIP_DOTS` to skip `.` and `..`, or `FilesystemIterator::FOLLOW_SYMLINKS` to follow symbolic links).
    
- **Methods:**  It provides methods like `getChildren()` to get an iterator for the current entry if it's a directory, `hasChildren()` to check if the current entry is a directory (and not `.` or `..`), `getSubPath()`, `getSubPathname()`, and standard iterator methods like `key()`, `next()`, and `rewind()`.
    
- **Filtering:**  You can use `RecursiveFilterIterator` in conjunction with `RecursiveDirectoryIterator` to filter files or directories based on specific criteria (e.g., file extension, directory name).


```php
$path = '/path/to/your/directory'; // Replace with the actual path

try {
    $directoryIterator = new RecursiveDirectoryIterator($path, FilesystemIterator::SKIP_DOTS);
    $iterator = new RecursiveIteratorIterator($directoryIterator, RecursiveIteratorIterator::SELF_FIRST);

    foreach ($iterator as $fileInfo) {
        if ($fileInfo->isDir()) {
            echo "Directory: " . $fileInfo->getPathname() . "\n";
        } else {
            echo "File: " . $fileInfo->getPathname() . "\n";
        }
    }
} catch (UnexpectedValueException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
```


##  Observers and Subjects

The PHP Standard PHP Library (SPL) provides the `SplSubject` and `SplObserver` interfaces to facilitate the implementation of the **Observer design pattern**. This pattern allows objects (observers) to be notified of changes in the state of another object (the subject).


1. **`SplSubject` Interface**

The `SplSubject` interface defines the methods that a subject object must implement:

```php
interface SplSubject {
    public function attach(SplObserver $observer);
    public function detach(SplObserver $observer);
    public function notify();
}
```

- `attach(SplObserver $observer)`: This method is used to add an observer to the subject's list of observers.
- `detach(SplObserver $observer)`: This method is used to remove an observer from the subject's list.
- `notify()`: This method is called by the subject when its state changes. It iterates through all attached observers and calls their `update()` method.

2. **`SplObserver` Interface:*

The `SplObserver` interface defines the method that an observer object must implement:


```php
interface SplObserver {
    public function update(SplSubject $subject);
}
```

- `update(SplSubject $subject)`: This method is called by the subject's `notify()` method when the subject's state changes. The observer receives the subject object as an argument, allowing it to query the subject's state if needed.



3. **Implementing the Observer Pattern with SPL:**
	- **Create a Subject Class**:  Implement the `SplSubject` interface in your subject class. Maintain a collection of `SplObserver` objects.
	    
	- **Create Observer Classes**:  Implement the `SplObserver` interface in your observer classes. Define the `update()` method to handle notifications from the subject.
	    
	- **Attach Observers**:  In your application, create instances of your observer classes and attach them to the subject using the `attach()` method.
	    
	- **Trigger Notifications**:  When the subject's state changes, call its `notify()` method to inform all attached observers.


```php
interface Observer {
    public function update(Subject $subject);
}

interface Subject {
    public function attach(Observer $observer);
    public function detach(Observer $observer);
    public function notify();
}

class ConcreteSubject implements Subject {
    private $observers = [];
    private $state;

    public function attach(Observer $observer) {
        $this->observers[] = $observer;
    }

    public function detach(Observer $observer) {
        $this->observers = array_filter(
            $this->observers,
            function ($obs) use ($observer) {
                return ($obs !== $observer);
            }
        );
    }

    public function notify() {
        foreach ($this->observers as $observer) {
            $observer->update($this);
        }
    }

    public function setState($state) {
        $this->state = $state;
        $this->notify();
    }

    public function getState() {
        return $this->state;
    }
}

class ConcreteObserver implements Observer {
    private $observerState;

    public function update(Subject $subject) {
        if ($subject instanceof ConcreteSubject) {
            $this->observerState = $subject->getState();
            echo "Observer updated with state: $this->observerState\n";
        }
    }
}

// Example usage:
$subject = new ConcreteSubject();
$observer1 = new ConcreteObserver();
$observer2 = new ConcreteObserver();

$subject->attach($observer1);
$subject->attach($observer2);

$subject->setState('Blah Blah Record'); // new state

// output => 
// Observer updated with state: Blah Blah Record
// Observer updated with state: Blah Blah Record
```




## Others

### Object Storage

The `SplObjectStorage` class provides a specialized way to store and manage objects. Its primary purpose is to act as a map from objects to data, or as a set of unique objects when data association is not needed.

- **Object as Key:**  Unlike regular arrays where keys can be strings or integers, `SplObjectStorage` uses objects themselves as keys. When an object is added, `SplObjectStorage` internally generates a unique hash for that object, allowing it to efficiently check for object presence and retrieve associated data.
    
- **Associating Data with Objects:**  You can attach data to an object when adding it to the storage. This allows you to store specific information related to each individual object.

- **Checking for Object Presence:** The `contains()` method can be used to efficiently determine if a particular object exists within the storage.

- **Retrieving Associated Data:** If data was associated with an object, it can be retrieved using array-like access or the `getInfo()` method when iterating.

- **Iteration:** `SplObjectStorage` is traversable, meaning you can iterate over it using a `foreach` loop to access the stored objects and their associated data.

- **Object Uniqueness:** Even if you attach the same object multiple times, `SplObjectStorage` will only store it once, treating it as a unique key.

```php
$storage = new SplObjectStorage();
$obj1 = new stdClass();
$obj2 = new stdClass();

$storage->attach($obj1, "Data for object 1");
$storage->attach($obj2); // No data associated

if ($storage->contains($obj1)) {
	echo "obj1 is in storage.";
}

foreach ($storage as $object) {  
	echo "Object: " . get_class($object) . ", Data: " . $storage->getInfo() . "\n";  
}


echo $storage[$obj1]; // Outputs: Data for object 1
```

**Use Cases**:

- **Tracking Objects:**  Keeping track of which objects have been processed or are currently active.
    
- **Object-Specific Data Storage:**  Storing metadata or state information directly linked to individual object instances.
    
- **Managing Event Listeners:**  Attaching specific callbacks or handlers to different objects in an event system.
    
- **Implementing Object Pools:**  Managing a collection of reusable objects.


**Note** : `SplObjectStorage` and `WeakMap` in PHP both allow associating data with objects, but they differ significantly in how they handle object lifetimes and garbage collection.
- `SplObjectStorage` maintains a **strong reference** to the objects used as keys. This means that if an object is added as a key to `SplObjectStorage`, it will not be garbage collected as long as the `SplObjectStorage` instance itself exists and holds that reference, even if all other references to the object are removed.
    
- `WeakMap` uses **weak references** for its object keys. This means that an object used as a key in a `WeakMap` does not prevent the object from being garbage collected if no other strong references to it exist. When an object used as a key in a `WeakMap` is garbage collected, its corresponding entry (key-value pair) is automatically removed from the `WeakMap`

### Fixed Array

The `SplFixedArray` class provides a specialized array-like object with a fixed size. It differs from a regular PHP array in several key aspects:

- **Fixed Size:**  Unlike standard PHP arrays, which dynamically resize, an `SplFixedArray` has a size that must be set upon creation or explicitly changed using `setSize()`. If the new size is smaller, elements beyond the new size are discarded. If larger, the array is padded with `null` values.
    
- **Integer Keys Only:**  `SplFixedArray` only allows integer keys within the range of its defined size. Using string keys or integer keys outside this range will result in a `RuntimeException`.
    
- **Memory Efficiency:**  Due to its fixed size and type-restricted keys, `SplFixedArray` can potentially be more memory-efficient than a standard PHP array, especially for large arrays where the size is known in advance.
    
- **Performance:**  The fixed nature of `SplFixedArray` can lead to performance advantages in certain scenarios, as the underlying implementation can be optimized for a known size and key type.

```php
// Create a fixed array of size 5
$fixedArray = new SplFixedArray(5);

// Assign values to elements
$fixedArray[0] = "Apple";
$fixedArray[1] = "Banana";
$fixedArray[2] = "Cherry";

// Access elements
echo $fixedArray[0] . "\n"; // Output: Apple

// Attempting to use a string key will throw a RuntimeException
// $fixedArray["fruit"] = "Grape";

// Attempting to access an index outside the size will also throw a RuntimeException
// echo $fixedArray[5];

// Change the size of the array
$fixedArray->setSize(3); 
echo $fixedArray[2] . "\n"; // Output: Cherry (elements beyond new size are discarded)
// echo $fixedArray[3]; // This would now throw a RuntimeException

// Convert to a regular PHP array
$phpArray = $fixedArray->toArray();
print_r($phpArray);
```
### File Object