# PHP Best Practices

## Overview

This document revisits the essential security and optimized-performance configurations for PHP & PHP-FPM runtime from a practical perspective.

By following the key recommendations outlined below, you can avoid common configuration errors and prevent security vulnerabilities as well as ensuring optimized performances.



## Security 

### Get Latest PHP

New versions of PHP are released regularly with security fixes and improvements. By using the latest version, you’ll have the benefit of these fixes and improvements as well as any new features that might be helpful for your application.

### Use Up to date code dependencies and third party components

In addition to using the latest version of PHP, you should also keep your code up to date. This includes any third-party libraries or frameworks that you’re using. Outdated software is often the target of attacks because hackers know that it is more likely to have vulnerabilities that can be exploited.

### Secure your server

Your web server should be configured properly to protect your website from attacks. This includes ensuring that all unnecessary services are disabled and that file permissions are set correctly. You should also use a firewall to block unwanted traffic and an intrusion detection/prevention system (IDS/IPS) to monitor for suspicious activity.

**Note** : We discuss servers/network security in depth on my repository


### SQL Injection

An SQL injection is the most common attack a developer is bound to experience. A single query can compromise a whole application. In an SQL injection attack, the attacker tries to alter the data written to the database via malicious queries.

Suppose your PHP application processes user data based on input to generate SQL queries, and suddenly, an anonymous attacker secretly injects a malicious SQL query in the input field.

```sql
$sql = "SELECT * from table_name1 where name = ' malidkha'); Drop TABLE table_name2;-- '";
```

**Remediation** : 
1. Use Prepared Statements, also known as parameterized queries.
```php
// for PDO
$con->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);

$query = $con->prepare("SELECT * FROM users WHERE email = :email ");
$query->execute(array('email'=>$email));
```
2. Sanitize user input. (done by Prepared Statements)

```php
/*Useful unctions : `trim`, `array_filter`, `filter_var`, `mysqli_real_escape_string`, `strip_tags`, and `htmlspecialchars`.*/

filter_var("not a tag < 5", FILTER_SANITIZE_STRING); //Output: not a tag
array_filter($_POST, 'trim_value');    // the data in $_POST is trimmed
```
3. Input should still be validated which is not same thing as sanitation. (done by Prepared Statements)
```php
$email = filter_var($_POST['email'], FILTER_VALIDATE_EMAIL);
if (empty($email)) {
	throw new \InvalidArgumentException('Invalid email address');
}
```

4. In case of parameterized column or table identifiers
	> in such case binding a table/column name is not going to work (due to the nature of how prepared statements work). In this case it is important to filter and sanitize the data manually.
```php 
 //whitelist
  switch ($_POST['orderby']) {
        case 'name':
        case 'name2':
        case 'name3':
           // These strings are trusted and expected
           $qs .= " ORDER BY $POST['orderby']";
           if (!empty($_POST['asc'])) {
               $qs .= ' ASC';
           } else {
               $qs .= ' DESC';
           }
           break;
        default:
           //warning or return a default query order by
    }

//regex: Only allow table name that begin with an upercase or lowercase letter followed by any number of alphanumeric chars and underscore
    if (!preg_match('/^[A-Za-z][A-Za-z0-9_]*$/', $table)) {
        throw new AppSpecificSecurityException("Possible SQL injection attempt.");
    }
```