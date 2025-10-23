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