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

### Configure error reports appropriately

Errors displayed are valuable for development. However, they can also expose sensitive information when visible in production. It is therefore essential to configure error reports appropriately.

**Remediation** : 

```ini
display_errors=Off
log_errors=On
error_log=/var/log/php/error.log
```

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

### XSS

**Cross-site scripting is a type of malicious web attack in which an external script is injected into the website’s code or output.** The attacker can send infected code to the end-user while the browser can not identify it as a trusted script. This attack occurs mostly in the places where the user can input and submit data. The attack can access cookies, sessions and other sensitive information about the browser.

**Stealing cookies": 

It can be lethal if combined with an XSS attack, where cookies of users can be stolen. A more damaging attack would be to redirect any user to a PHP file that steals cookies.

**Remediation** : 

 1. Employ the `htmlspecialchars`, and `ENT_QUOTES` method on the client body (user input) to prevent injecting malicious data into the database. These are built-in PHP methods to help sanitize input.

```php
// htmlspecialchars sanitization
$search = htmlspecialchars($search, ENT_QUOTES, 'UTF-8');
echo 'Search results for '.$search;

// ent_quotes sanitization
$body =  htmlspecialchars($_POST['body'], ENT_QUOTES);
```

2. When setting cookies make sure that you select the additional options like the secure, httponly, and make it available for a limited time.

```php
<?php
$expires = new DateTime('+1 day');
 setcookie('username', 'malidkha', $expires->getTimestamp(), '/', null, null, true ); // expires 1 day after initialization
```

### Session Hijacking and Session fixation

It can be lethal if combined with an XSS attack, where cookies of users can be stolen.

##### Session Fixation

There are three common methods used to obtain a valid session identifier:

- Prediction It refers to guessing a valid session identifier. The session identifier is extremely random, and this is unlikely to be the weakest point in your implementation.
    
-  Capturing a valid session identifier is the most common type of session attack, and there are numerous approaches like GET, cookies.
    
- Fixation Fixation is the simplest method of obtaining a valid session identifier. While it's not very difficult to defend against, if your session mechanism consists of nothing more than `session_start()`, you are vulnerable.
    

##### Session Hijacking

Session hijacking refers to all attacks that attempt to gain access to another user's session. Like session fixation, if your session mechanism consists of `session_start()` then your are vulnerable.

Session hijacking is a particular type of malicious web attack in which the attacker secretly steals the session ID of the user. That session ID is sent to the server where the associated $_SESSION array validates its storage in the stack and grants access to the application. Session hijacking is possible through an XSS attack or when someone gains access to the folder on a server where the session data is stored.

**Remediation** :

##### Configure PHP Setting

1. **_Strong Session ID_**

Standard session IDs generated by PHP are not random. They are predictable under certain circumstances making it vulnerable resulting session hijacking.

Generate random data for SID using following configurations.

```ini
session.entropy_file = /dev/urandom   //specifies the random number generator to read from
session.entropy_lenght = 32           //the number of bytes to read
```

Also its good idea to change the hash algorithm. By deafult, PHP uses the obsolete MD5.

```ini
session.hash_function = sha512
```

**Note** : the above three directive are removed since PHP 7.1

2. **_Use another session name_**

PHP uses a default session name _PHPSESSID_, it would be more secure to change it to another not revealing name.

```ini
session.name = CUSTOMID
```

3. **_Use Cookies_**

Exchanging session ID through the URL is a major security risk resulting session fixation abuse. Following there configuration can help to prevent such abuse.

```ini
session.use_only_cookies = 1    // tells PHP to set a cookie with a session ID when session started
session.use_cookies	=	1         // tells PHP to only accept session IDs comming from a cookie, not from URL
session.use_trans_sid	=	0       // prevents PHP from automatically inserting the session ID into links.
```

4. **_Secure Session Cookies_**

To protect session ID, set the following configurations-

```ini
session.cookie_httponly	=	1   // makes sure the session cookie is not accessible via JavaScript and prevent xss
session.cookie_secure	=	1     // (HTTPS only) makes sure the cookie will only be transmitted over a HTTPS connection.
```

5. **_Regenerating the Session ID_**

It is a good practice to generate new session ID once user logs in/out (state changed) which will help to prevent session fixation attacks.

```ini
session_regenerate_id(true)   // the argument tells PHP to delete the old session.
```

### Cross-Site Request Forgery XSRF/CSRF

This attack forces an end user to execute unwanted actions on a web application in which he/she is currently authenticated. A successful CSRF exploit can compromise end user data and operation in case of normal user. If the targeted end user is the administrator account, this can compromise the entire web application.

**Remediation** :

1. Random token with each request
> A application will generate the token which will be included in the form as a hidden input field. This unique token key will be use to varify valid request by comparing the submitted token with the one stored in the session. 
> Plus, you can check for the REQUEST type and make sure that it is a POST request, chekc it is an ajax request , check the correct HTTP-Referer ...

the token generation :
```html
<input type="hidden" name="_token" value="<?= token::generate('display_users')">
```

then the checking:

```php 
$_SERVER['HTTP_REFERER'] = str_replace("http://", "https://", $_SERVER['HTTP_REFERER']); //some browsers like safari sends the referer with http instead of https

if (input::exists("post") && $_SERVER['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest' && isset($_SERVER['HTTP_REFERER']) && $_SERVER['HTTP_REFERER'] == "https://malikdha.com/referer") {

	#code
	if (token::check(input::get("_token"), "display_users")) {
		#code
	}
	#code
}
#code
```

**Note** : You might as well generate a token for each session, instead of each request. (i prefer it with each request*)

### Parameter Tempering

Hackers can manipulate data easily before sending to web server using hidden fields, URL or proxy softwares (eg. Burp). The application should not simply trust on user input value that can modify things like prices in web carts, session tokens and HTTP headers.

##### Hidden Field Value Manipulation

Hidden, drop down, pre-selected, check-box field values are easily manipulated by the user using proxy software or simply downloading page and modifying field values & re-loading the page in the browser.

##### URL Manipulation

URL Manipulation is more vulnerable than other type of vulnerability as it is easy to alter query string from URL address.

```bash
http://www.malidkha.com/product?pid=12345&price=500

TO => http://www.malidkha.com/product?pid=12345&price=1
```


**Remediation** : 
1. Use session variable instead of using hidden form fields to store variables.
2. Or use encrypted values to compare if the field has been altered or not.

```php
- $digest_value = md5('input_field_name'.'input_field_value'.$salt);
# Add additional hidden field for digest value
# Finally, when form is submitted generate md5 of actual field value and compare against hidden digest value.
```

3. Aavoid putting parameters into a query string.
4. In the case when parameters from client is needed, they should accompanied (escort) by a valid session token (Eg. above example of hidden field).
5. Use cryptographic protection for sensitive parameter in a URL.
6. Use proper validation of input received (sanitize data, cross check user input in database, use JOIN TABLE)