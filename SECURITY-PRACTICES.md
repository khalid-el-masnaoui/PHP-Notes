# PHP Security Best Practices

## Overview

This document revisits the essential security configurations for PHP & PHP-FPM runtime from a practical perspective.

By following the key recommendations outlined below, you can avoid common configuration errors and prevent security vulnerabilities.

## Table of contents

- **[Get Latest PHP](#get-latest-php)**
- **[Use Up to date code dependencies and third party components](#useup-to-date-code-dependencies-and-third-party-components-)**
- **[Secure your server](#secure-your-server)**
- **[Apply the principles of security through obscurity](#apply-the-principles-of-security-through-obscurity)**
- **[Configure error reports appropriately](#configure-error-reports-appropriately)**
- **[SQL Injection](#sql-injection)**
- **[XSS](#xss)**
- **[Session Hijacking and Session fixation](#session-hijacking-and-session-fixation)**
- **[Cross-Site Request Forgery XSRF/CSRF](#cross-site-request-forgery-xsrfcsrf)**
- **[Parameter Tempering](#parameter-tempering)**
- **[Command Injections](#command-injections)**
- **[Brute Force](#brute-force)**
- **[Broken Access-Control And Authentication](#broken-access-control-and-authentication)**
	- **[Broken Access Control](#broken-access-control)**
	- **[Broken Authentication](#broken-authentication)**
- **[Remote & Local File Inclusion RFI/LFI](#remote--local-file-inclusion-rfilfi)**
- **[File Upload](#file-upload)**
- **[Passwords](#passwords)**
- **[SSL Certificates For HTTPS](#ssl-certificates-for-https)**
- **[Other Techniques and Tools](#other-techniques-and-tools)**
	- **[ Add Rate limiting to costly calls and requests](#add-rate-limiting-to-costly-calls-and-requests)**
	- **[Security Configurations](#security-configurations)**
	- **[Tools](#tools)**
		- **[PHPCS-Security-Audit](#phpcs-security-audit)**
		- **[Local PHP Security Checker & Composer Audit](#local-php-security-checker--composer-audit)**
		- **[ Parse: A PHP Security Scanner](#parse-a-php-security-scanner)**
		- **[PHPMD](#phpmd)**
	    
- **[Resources](#resources)**


## Get Latest PHP

New versions of PHP are released regularly with security fixes and improvements. By using the latest version, you’ll have the benefit of these fixes and improvements as well as any new features that might be helpful for your application.

## Use Up to date code dependencies and third party components

In addition to using the latest version of PHP, you should also keep your code up to date. This includes any third-party libraries or frameworks that you’re using. Outdated software is often the target of attacks because hackers know that it is more likely to have vulnerabilities that can be exploited.

## Secure your server

Your web server should be configured properly to protect your website from attacks. This includes ensuring that all unnecessary services are disabled and that file permissions are set correctly. You should also use a firewall to block unwanted traffic and an intrusion detection/prevention system (IDS/IPS) to monitor for suspicious activity.

**Note** : We discuss servers/network security in depth on my repository

## Apply the principles of security through obscurity

Although security through obscurity is not a complete strategy in itself, it can slow down attackers and make their task more difficult.

For example:

- **Hide PHP version**: prevents attackers from knowing the exact version of PHP being used. This can be done by disabling `expose_php` in the php.ini file: `expose_php = Off`.
- **Generic login error messages**: when a connection attempt fails, do not specify whether it is the password or the user name that is incorrect. Use a generic message such as ‘Incorrect identifiers’ to avoid revealing that a valid identifier has been found (enumeration attacks).

These techniques do not replace fundamental security measures, but they do make it harder for attackers to gather exploitable information.

## Configure error reports appropriately

Errors displayed are valuable for development. However, they can also expose sensitive information when visible in production. It is therefore essential to configure error reports appropriately.

:lock: **Remediation** : 

```ini
display_errors=Off
log_errors=On
error_log=/var/log/php/error.log
```


## SQL Injection

An SQL injection is the most common attack a developer is bound to experience. A single query can compromise a whole application. In an SQL injection attack, the attacker tries to alter the data written to the database via malicious queries.

Suppose your PHP application processes user data based on input to generate SQL queries, and suddenly, an anonymous attacker secretly injects a malicious SQL query in the input field.

```sql
$sql = "SELECT * from table_name1 where name = ' malidkha'); Drop TABLE table_name2;-- '";
```

:lock: **Remediation** : 
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

## XSS

**Cross-site scripting is a type of malicious web attack in which an external script is injected into the website’s code or output.** The attacker can send infected code to the end-user while the browser can not identify it as a trusted script. This attack occurs mostly in the places where the user can input and submit data. The attack can access cookies, sessions and other sensitive information about the browser.

**Stealing cookies": 

It can be lethal if combined with an XSS attack, where cookies of users can be stolen. A more damaging attack would be to redirect any user to a PHP file that steals cookies.

:lock: **Remediation** : 

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

setcookie('user_session', $value, [ 
'expires' => time() + 3600, 
'path' => '/', 
'domain' => 'maldikha.com', 
'secure' => true, // Cookie sent only via HTTPS 
'httponly' => true, // Inaccessible via JavaScript 
'samesite' => 'Strict' // Prevents cookies being sent by cross-site requests ]); 

```

## Session Hijacking and Session fixation

It can be lethal if combined with an XSS attack, where cookies of users can be stolen.

### Session Fixation

There are three common methods used to obtain a valid session identifier:

- Prediction It refers to guessing a valid session identifier. The session identifier is extremely random, and this is unlikely to be the weakest point in your implementation.
    
-  Capturing a valid session identifier is the most common type of session attack, and there are numerous approaches like GET, cookies.
    
- Fixation Fixation is the simplest method of obtaining a valid session identifier. While it's not very difficult to defend against, if your session mechanism consists of nothing more than `session_start()`, you are vulnerable.
    

### Session Hijacking

Session hijacking refers to all attacks that attempt to gain access to another user's session. Like session fixation, if your session mechanism consists of `session_start()` then your are vulnerable.

Session hijacking is a particular type of malicious web attack in which the attacker secretly steals the session ID of the user. That session ID is sent to the server where the associated $_SESSION array validates its storage in the stack and grants access to the application. Session hijacking is possible through an XSS attack or when someone gains access to the folder on a server where the session data is stored.

:lock: **Remediation** :

### Configure PHP Setting

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

## Cross-Site Request Forgery XSRF/CSRF

This attack forces an end user to execute unwanted actions on a web application in which he/she is currently authenticated. A successful CSRF exploit can compromise end user data and operation in case of normal user. If the targeted end user is the administrator account, this can compromise the entire web application.

:lock: **Remediation** :

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

## Parameter Tempering

Hackers can manipulate data easily before sending to web server using hidden fields, URL or proxy softwares (eg. Burp). The application should not simply trust on user input value that can modify things like prices in web carts, session tokens and HTTP headers.

### Hidden Field Value Manipulation

Hidden, drop down, pre-selected, check-box field values are easily manipulated by the user using proxy software or simply downloading page and modifying field values & re-loading the page in the browser.

### URL Manipulation

URL Manipulation is more vulnerable than other type of vulnerability as it is easy to alter query string from URL address.

```bash
http://www.malidkha.com/product?pid=12345&price=500

TO => http://www.malidkha.com/product?pid=12345&price=1
```


:lock: **Remediation** : 
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

## Command Injections

Executing commands via PHP can be extremely powerful, but it also presents a high risk if precautions are not taken.

Poor management can allow attackers to inject malicious commands into your server, compromising the security of your application.

:lock: **Remediation** :

1. Disable dangerous functions with disable_functions
>  These functions are commonly used to execute system commands, open processes or access sensitive information. Disabling them prevents misuse in the event of a breach.

```ini
disable_functions = show_source, exec, shell_exec, system, passthru, proc_open, popen, curl_exec, curl_multi_exec, parse_ini_file, show_source, eval
```

2. Strictly validate input parameters

> If you absolutely must use command execution functions (such as `exec()` or `system()`), you must be extremely careful about the parameters passed to them.
> Validate all input data using whitelists, i.e. accepting only pre-approved values. This reduces the likelihood of malicious input being executed as a command.

3. Escape commands and arguments using the appropriate functions
4. 
> These functions prevent malicious users from injecting additional commands or modifying the executed command via malformed inputs.

```php 
escapeshellcmd() #Escapes special characters in a command to prevent them from being interpreted as shell operators. Use this function to secure the entire command.
escapeshellarg() #Escapes arguments passed to a command to treat them as literal strings. This prevents the injection of special characters or additional commands.
```

## Brute Force 

A brute force attack can manifest itself in many different ways, but primarily consists in an attacker configuring predetermined values, making requests to a server using those values, and then analyzing the response.

This attack is used to break in (log in) to websites, getting access to applications and APIs...

:lock: **Remediation** : 
1. Have a `BruteForce Block` mechanism in place
```php
# if a login/access to api/site is failed
BruteForceBlock::addFailedLoginAttempt(...) #add the failed attempt and bind it with the IP


# check the client IP is not blocked due to many failed attemepts 
BruteForceBlock::checkIP()
```

1. when a connection attempt fails, do not specify whether it is the password or the user name that is incorrect. Use a generic message such as ‘Incorrect identifiers’ to avoid revealing that a valid identifier has been found (enumeration attacks). 

> > Since Redis works as an in-memory database, it is a qualified candidate for creating a BruteForce Blocker.


## Broken Access-Control And Authentication

When designing an internal application, you must provide a form of access control through authentication and authorization. You use authentication to confirm whether users have the right to access your system by validating their usernames and passwords against their account values. On the other hand, authorization allows you to verify whether an authenticated user has the correct permission to access a particular resource. For instance, to delete or update a product.

### Broken Access Control
> Access control weaknesses are common due to the lack of automated detection, and lack of effective functional testing by application developers.  
> Access control detection is not typically amenable to automated static or dynamic testing. Manual testing is the best way to detect missing or ineffective access control, including HTTP method (GET vs PUT, etc), controller, direct object references, etc.

:lock: **Remediation** : 

* With the exception of public resources, deny by default.  
* Implement access control mechanisms once and re-use them throughout the application, including minimizing CORS usage.  
* Model access controls should enforce record ownership, rather than accepting that the user can create, read, update, or delete any record.  
* Unique application business limit requirements should be enforced by domain models.  
* Disable web server directory listing and ensure file metadata (e.g. .git) and backup files are not present within web roots.  
* Log access control failures, alert admins when appropriate (e.g. repeated failures).  
* Rate limit API and controller access to minimize the harm from automated attack tooling.  
* JWT tokens should be invalidated on the server after logout.

Some access control mechanisms are : 
1.  Role Based Access Control (RBAC) : Role based access control is giving access to a resource when the subject has a given role.
2. Permission Based Access Control (PBAC) : Role based access control is giving access to a resource when the subject has a given permission
3. Access Control Lists (ACL): specifies which subjects are granted access to a resource, as well as what operations are allowed on a given resource.

### Broken Authentication
> When authentication is broken, it means there are loopholes in how users are authenticated, and web sessions are managed. Such loopholes can allow attackers to impersonate a user and perform unauthorized actions

>Attackers can take advantage of poor authentication mechanisms to hijack a users’ account and access sensitive data. This is what happens in the case of broken authentication where weak authentication features result in security compromises.

**Types of Broken Authentication Attacks**
* Brute Force
* Session Hijacking
* Session Fixation
* Credential Stuffing
* Session ID in URL Rewrite

:lock: **Remediation** : 

* Where possible, implement multi-factor authentication to prevent automated, credential stuffing, brute force, and stolen credential re-use attacks.  
* Do not ship or deploy with any default credentials, particularly for admin users.  
* Enforce Strong passwords constraints and Implement weak-password checks, such as testing new or changed passwords against a list of the [top 10000 worst passwords](https://github.com/danielmiessler/SecLists/tree/master/Passwords).  
* Align password length, complexity and rotation policies with [NIST 800-63 B’s guidelines in section 5.1.1 for Memorized Secrets](https://pages.nist.gov/800-63-3/sp800-63b.html#memsecret) or other modern, evidence based password policies.  
* Ensure registration, credential recovery, and API pathways are hardened against account enumeration attacks by using the same messages for all outcomes.  
* Limit or increasingly delay failed login attempts. Log all failures and alert administrators when credential stuffing, brute force, or other attacks are detected.  
* Use a server-side, secure, built-in session manager that generates a new random session ID with high entropy after login. Session IDs should not be in the URL, be securely stored and invalidated after logout, idle, and absolute timeouts.

## Remote & Local File Inclusion RFI/LFI

_**RFI**_ : Remote File Inclusion (RFI) vulnerabilities occur when the application allows a malicious user to include files from a remote server in the code executed by the application server.

By exploiting an RFI, an attacker can potentially execute malicious code on the target server, compromising the integrity, confidentiality and availability of the application and the data it processes.

**_LFI_** : A Local File Inclusion (LFI) occurs when the application allows the inclusion of local files, i.e. files that reside on the server itself.


An RFI vulnerability occurs mainly in web applications that accept user input to determine which file to include in a page. If this input is not properly filtered or validated, an attacker can manipulate the input to point to a file hosted on a server under his control. This remote file, often written in a scripting language such as PHP, can then contain malicious code that will be executed by the vulnerable application’s server.

:lock: **Remediation** : 
1. Avoid using user-controlled data directly in `include` and `require` statements and instead consider an allow-list approach for dynamically including scripts. 

2.  Input validation is essential to protect web applications against RFI attacks.

3. Secure configuration
```ini
; Whether to allow the treatment of URLs (like http:// or ftp://) as files.
allow_url_fopen = Off

; Whether to allow include/require to open URLs (like https:// or ftp://) as files.
allow_url_include = Off
```

## File Upload

It allows your visitor to place files (upload files) on your server. This can result in various security problems such as delete your files, delete a database, get user details and much more. You can disable file uploads using PHP or write secure code (like validating user input and only allow image file types such as png or gif).

:lock: **Remediation** : 
1. Disable PHP execution in selected directories

> Put a .htaccess with the following content in upload directory to prevent the execution of PHP file. Instead, it will download the file.

```conf
php_flag engine off
```

2. Move upload directory outside of web-root which will not allow direct access to images.

> Since, it is out of scope to access from URL we need to create either symlinks or alias from nginx configuration file. Moreover, we can add additional access restrictions like setting only valid file type to be accessible and preventing files access directly via URL in particular image directory.

3. Other validations – like file size, file rename, and store uploaded files in private location – are also required to strengthen the security of the applications.


## Passwords 

Reversible encryption is harmful. It can easily be cracked and decrypted, making your data vulnerable to theft or exposure

Hashing passwords is a safer bet than not hashing passwords at all (or Reversible encrypted passwords) as hackers can expose sensitive information if passwords are not secured properly. But the idea of using any hashing algorithm is not effective as there are still proper ways of hashing passwords for guaranteed security.

:lock: **Remediation** : 

 1. Hash Passwords to Prevent Vulnerabilities
 
>If you are using anything other than the `password_hash` method provided by php, like `sha-1`, `sha-256`, `sha-512`, `md5`, you are still risking data theft due to brute force.

```php
// Create the hash on account creation
$password = "securedpass";
password_hash($password, PASSWORD_DEFAULT); // default algo is BCRYPT

// Verifying password on Login
password_verify($inputedPass, $db_password);
```

## SSL Certificates For HTTPS

All the modern browsers like Google Chrome, Opera, Firefox and others, recommend using HTTPS protocol for web applications. HTTPs provides a secured and encrypted accessing channel for untrusted sites. You must include HTTPS by installing an SSL certificate on your website. It also strengthens your web applications against XSS attacks and prevents hackers to read transported data using codes.

## Other Techniques and Tools

### Add Rate limiting to costly calls and requests

Rate limiting is a technology that puts a cap on the number of times a user can request a resource from a server. Many services implement rate limiting to prevent abuse to a service when a user may try to put too much load on a server

:lock: **Remediation** : 

1. Have a `Rate Limit`Mechanism in place
```php
#limit the access of the endpiint1 to 120 request per minute using sessions based on an api-key header , ip ..
$rateLimiter->rateLimit(120, 1, "endpoint1");
```


> **Note** : It might be practical to code a rate-limiting module by logging user activities in a database like MySQL. However, the end product may not be scalable when many users access the system since the data must be fetched from disk and compared against the set limit. This is not only slow, but relational database management systems are not designed for this purpose.

> Since Redis works as an in-memory database, it is a qualified candidate for creating a rate limiter, and it has been proven reliable for this purpose.

### Security Configurations

- `memory_limit`: limits the amount of memory a script can use.
- `max_execution_time`: prevents scripts from running indefinitely.
- `file_uploads` and `upload_max_filesize`: control file upload authorisations and limits.

### Tools
#### PHPCS Security Audit

[_phpcs-security-audit_](https://github.com/FloeDesignTechnologies/phpcs-security-audit) is a set of [PHP_CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer) rules that finds vulnerabilities and weaknesses related to security in PHP code.

The tool also checks for CVE issues , it being an extension of `PHP_CodeSniffer` makes it easy integration into continuous integration systems. It also allows for finding security bugs that are not detected with some object oriented analysis (such as [PHPMD](http://phpmd.org/)).

**Example**

A quick example of the results and hos it works,

```bash
$ phpcs --extensions=php,inc,lib,module,info --standard=./vendor/pheromone/phpcs-security-audit/example_base_ruleset.xml ./vendor/pheromone/phpcs-security-audit/tests.php

FILE: tests.php
--------------------------------------------------------------------------------
FOUND 18 ERRORS AND 36 WARNINGS AFFECTING 44 LINES
--------------------------------------------------------------------------------

  6 | WARNING | Possible XSS detected with . on echo
  6 | ERROR   | Easy XSS detected because of direct user input with $_POST on echo
  9 | WARNING | Usage of preg_replace with /e modifier is not recommended.
 10 | WARNING | Usage of preg_replace with /e modifier is not recommended.
 10 | ERROR   | User input and /e modifier found in preg_replace, remote code execution possible.
 11 | ERROR   | User input found in preg_replace, /e modifier could be used for malicious intent.
   ...
```

You can easily customize the rulesets.

#### Local PHP Security Checker & Composer Audit

The Local PHP Security Checker is a command line tool that checks if your PHP application depends on PHP packages with known security vulnerabilities. It uses the [Security Advisories Database](https://github.com/FriendsOfPHP/security-advisories) behind the scenes

```shell

#can be used like this
local-php-security-checker --path=/path/to/php/project/vendor
local-php-security-checker --path=/path/to/php/project/composer.lock

local-php-security-checker --no-dev --format=json --path=/path/to/php/project/composer.lock
```


**Note** :
* Local PHP Security Checker is **archived** , use `composer audit` instead , it uses the same  [Security Advisories Database](https://github.com/FriendsOfPHP/security-advisories)

#### Parse: A PHP Security Scanner

The [_Parse_](https://github.com/psecio/parse) scanner is a static scanning tool to review your PHP code for potential security-related issues.

For example, you really shouldn't be using [eval](http://php.net/eval) in your code anywhere if you can help it. When the scanner runs, it will parse down each of your files and look for any `eval()` calls. If it finds any, it adds that match to the file and reports it in the results.

#### PHPMD

What PHPMD does is: It takes a given PHP source code base and look for several potential problems within that source. These problems can be things like:

1. Possible bugs
2. Suboptimal code
3.  Overcomplicated expressions
4. Unused parameters, methods, properties

it can help us with avoiding some security bugs early-on,

we will discuss such tool and other static analysis tools like `phpstan`, in the folder `Tools`


## Resources

- [resource 1](https://www.vaadata.com/blog/php-security-best-practices-vulnerabilities-and-attacks)
- [resource 2](https://github.com/guardrailsio/awesome-php-security)