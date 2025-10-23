# Software Testing

Software testing is a crucial process within the software development lifecycle that involves evaluating a software application to identify bugs, errors, and missing requirements. Its primary goal is to ensure the software functions correctly, securely, and efficiently according to its specifications and user expectations.



# Software Testing

## Key Aspects

- **Verification and Validation:**  Testing verifies that the software meets its specified requirements and validates that it fulfills the intended purpose and user needs.
    
- **Bug Detection:**  It aims to uncover defects, errors, or inconsistencies in the software's behavior compared to its expected output.
    
- **Quality Assurance:**  Testing contributes to delivering a high-quality product by improving reliability, usability, and performance.
    
- **Risk Mitigation:**  By identifying and addressing issues early, testing helps minimize the risks of software failure and negative user experiences.


## Testing Types

Software testing can be broken out into two different types: **functional** and **non-functional** testing. Different aspects of a software application require different testing types, such as **performance** testing, **scalability** testing, **integration** testing, **unit** testing, and many more.
Each of these software testing types offers excellent visibility into your application, from code to user experience.

### Unit Testing

Unit tests focus on testing individual units or components of code in isolation. These units can be functions, methods, or classes, typically representing the smallest testable parts of an application. The key principle of unit testing is to isolate each unit from the rest of the codebase and verify its behavior independently.

 **Characteristics of Unit Tests:**
 
1. **Isolation**: Unit tests are independent and isolated from external dependencies such as databases, network calls, or other components.
2. **Granularity**: They target specific units of code, allowing for fine-grained testing of functionality.
3. **Speed**: Unit tests are fast to execute since they do not rely on external resources or interactions

### Component Tests

Component tests, also known as module tests, sit between unit tests and integration tests in terms of scope. While unit tests focus on individual units of code, component tests validate the interactions and integration between multiple units or components within a module or subsystem.

**Characteristics of Component Tests:**

1. **Scope**: Component tests verify the behavior of a module or subsystem by testing interactions between its constituent units.
2. **Mocking**: External dependencies may be mocked or stubbed to isolate the component under test.
3. **Coverage**: They provide broader coverage compared to unit tests by testing interactions between units.


### Integration Tests

Integration tests evaluate the interaction and integration of multiple modules or subsystems to ensure that they function correctly when combined. Unlike unit tests and component tests, which focus on isolated parts of the system, integration tests validate the behavior of the system as a whole.

**Characteristics of Integration Tests:**

1. :**End-to-End Testing:**: Integration tests simulate real-world scenarios by testing the entire application stack, including databases, APIs, and external services.
2. :**Dependencies:**: They may involve real external dependencies, such as databases or network services, to validate interactions between different parts of the system.
3. :**Complexity:**: Integration tests are more complex and may take longer to execute due to their broader scope and reliance on external resources.


### Functional testing

Functional tests focus on the business requirements of an application. They only verify the output of an action and do not check the intermediate states of the system when performing that action.

There is sometimes a confusion between integration tests and functional tests as they both require multiple components to interact with each other. The difference is that an integration test may simply verify that you can query the database while a functional test would expect to get a specific value from the database as defined by the product requirements.

**Characteristics of Functional Tests:**

- **Scope:**  Validates the software's behavior against specified functional requirements from an end-user perspective.
    
- **Purpose:**  To confirm that the system or a specific feature delivers the expected output for given inputs, as defined in requirements or use cases.
    
- **Characteristics:**  Often performed by QA engineers, can be manual or automated, and typically uses black-box testing techniques (without knowledge of internal code structure). This category includes tests like smoke tests and regression tests.

### End-to-end testing

End-to-end testing replicates a user behavior with the software in a complete application environment. It verifies that various user flows work as expected and can be as simple as loading a web page or logging in or much more complex scenarios verifying email notifications, online payments, etc...

End-to-end tests are very useful, but they're expensive to perform and can be hard to maintain when they're automated. It is recommended to have a few key end-to-end tests and rely more on lower level types of testing (unit and integration tests) to be able to quickly identify breaking changes.


**Characteristics of End-to-end Tests:**

- **Simulates real-world scenarios:**  E2E tests mimic how actual users interact with an application, from navigating the front-end to triggering back-end processes and verifying outcomes. For example, an e-commerce test might involve a user searching for a product, adding it to the cart, checking out, and receiving a confirmation email. 
    
- **Tests the complete workflow:**  Unlike other tests that focus on isolated components, E2E tests validate the entire system from the initial user entry point to the final outcome. 
    
- **Validates all integrated components:**  The tests ensure all parts of the application—including the user interface, business logic, APIs, databases, and third-party services—work together correctly and that data flows properly between them. 
    
- **Focuses on end-user perspective:**  The primary goal is to verify that the entire system functions as expected from the user's point of view, ensuring the application meets business requirements. 
    
- **Requires a production-like environment:**  To accurately simulate real-world conditions, E2E tests should be executed in a testing environment that closely resembles the production environment. 
    
- **Is a form of system testing:**  E2E testing is a type of system testing that targets the entire application, but it differs in its focus on a specific user or business workflow perspective.

### Smoke testing

Smoke tests are basic tests that check the basic functionality of an application. They are meant to be quick to execute, and their goal is to give you the assurance that the major features of your system are working as expected.

Smoke tests can be useful right after a new build is made to decide whether or not you can run more expensive tests, or right after a deployment to make sure that they application is running properly in the newly deployed environment.
### Acceptance testing

Acceptance testing is the final stage of testing a product, especially software, to determine if it meets the specified requirements and is ready for delivery. It involves a formal evaluation, often by the customer or end-user, to ensure the product fulfills user needs and business requirements, and is functionally sound. Acceptance testing verifies the system as a whole against the original contract or specifications

**Types of acceptance testing**

- **User Acceptance Testing (UAT):**  The most common type, performed by the end-user to validate the software meets their needs. 
    
- **Operational Acceptance Testing (OAT):** Checks if the system is ready to operate and can be maintained in the production environment. This includes testing things like backup and restore procedures, and disaster recovery. 
    
- **Regulation Acceptance Testing (RAT):**  Verifies that the product complies with all relevant government rules and regulations. 
    
- **Alpha Testing:** An internal test of the software by a dedicated testing team or a small group of actual users, before it is released to the public. 
    
- **Beta Testing:** A form of acceptance testing that involves real users in their actual environments, but before the final release to the general public.

### Performance testing

Performance tests evaluate how a system performs under a particular workload. These tests help to measure the reliability, speed, scalability, and responsiveness of an application. 
For instance, a performance test can observe response times when executing a high number of requests, or determine how a system behaves with a significant amount of data. It can determine if an application meets performance requirements, locate bottlenecks, measure stability during peak traffic, and more.

**Key goals**

- **Ensure reliability**: Guarantee the application functions correctly under various conditions. 
- **Identify bottlenecks**: Find points of weakness in the system that slow down performance. 
- **Measure performance metrics**: Analyze key indicators like response time, throughput, and resource utilization. 
- **Determine scalability**: Understand how well the application handles an increasing number of users or transactions. 
- **Prevent issues**: Identify potential problems like memory leaks or crashes before they impact end-users

**Common types of performance testing:**

- **`Load testing:`** Tests the system's behavior under a normal, expected workload to see how it handles a specific number of concurrent users.

- **`Stress testing:`** Pushes the system beyond its normal operating limits to find its breaking point and understand how it fails and recovers.

- **`Spike testing:`** Evaluates the system's response to sudden, massive increases in load, like during a flash sale.

- **`Endurance testing (Soak testing):`** Checks the system's stability and performance over a prolonged period to detect issues like memory leaks that appear over time.

- **`Scalability testing:`** Measures the application's ability to "scale up" or "scale out" to handle increasing workloads. 