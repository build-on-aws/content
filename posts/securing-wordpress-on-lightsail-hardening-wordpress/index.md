---
title: "Securing Wordpress on Lightsail: Hardening Wordpress"
description: "A Wordpress instance on Lightsail has a basic security posture. However, we can harden Wordpress and make it more efficient."
tags:
    - Lightsail
    - Wordpress
    - security
authorGithubAlias: spara
authorName: Sophia Parafina
date: 2023-09-25
---

The Wordpress Bitnami deployment on Lightsail is designed to get us up and running quickly and easily. However, just like leaving your home for a vacation, it is always good practice to check that the doors and windows are locked, appliances are turned off, and heating and cooling set appropriately.  When hardening Wordpress on Lightsail we want to set rules guiding how a client or browser interacts with Wordpress and control administrative access. In this article, we’ll cover both methods by configuring the Apache .htaccess file and creating and managing Wordpress administrator roles.

## Basic Configuration

At it’s simplest, the Apache HTTP server .htaccess file sets access permissions to individual directories. You can place an .htaccess file in a directory and it will apply to all the subdirectories. We can also add a .htaccess file in a directory that only applies to that directory. The [Apache documentation](https://httpd.apache.org/docs/2.4/howto/htaccess.html) has detailed examples for many use cases and is worth reviewing. However, we’ll focus on a Wordpress specific configuration.

1. Wordpress runs in the Apache web server. This means that securing a Lightsail Wordpress server requires configuring both Apache and Wordpress. The Apache configuration file is wordpress-vhost.conf in the /opt/bitnami/apache/conf/vhosts directory. Let’s examine this file first; open the file with an editor of your choice.

```shell
<VirtualHost 127.0.0.1:80 _default_:80>
  ServerName www.example.com
  ServerAlias *
DocumentRoot /opt/bitnami/wordpress
  <Directory "/opt/bitnami/wordpress">
    Options -Indexes +FollowSymLinks -MultiViews
    AllowOverride None
    Require all granted
```

A common security recommendation is to disable listing or browsing the contents of a directory because it could expose files or code that affect Wordpress. A typical solution is to add a .htaccess file in each directory that prevents directory browsing.  The good news is that it is unnecessary with the Lightsail Wordpress server.   

We’re interested in the lines following DocumentRoot. Note that the directory is set to /opt/bitnami/wordpress and options or directives inside the Directory block apply to that directory. The line Options `-Indexes +FollowSymLinks -MultiViews` configures Apache to disable directory listing with the `-Indexes` option in the `./wordpress` directory. Adding ./htaccess files to disable directory listing is not needed.

```shell
AllowOverride None
```

This disables .htaccess files or blocks in a configuration file. We want to set it to AllowOverride All to secure Wordpress.

```shell
AllowOverride All
```

At the bottom of the `wordpress-vhost.conf` file, is the following line.

```shell
Include "/opt/bitnami/apache/conf/vhosts/htaccess/wordpress-htaccess.conf"
```

This line points to a file that contains all the .httaccess directives for Wordpress. When the Apache web server starts and reads the wordpress-vhost.conf file, it also read this file. Because we set AllowOverride All, Apache will use the .httaccess directives.

## Adding Security Headers

At the beginning of this article we described checking doors and windows are locked before leaving your house as typical security practice. We can add an extra layer of security to Wordpress by adding security headers. What are security headers? They’re Wordpress directives that control how web requests are handled by both Wordpress and the client browser. They prevent injection and execution of malicious code such as [cross-site scripting attacks (XSS)](https://owasp.org/www-community/attacks/xss/).

The `wordpress-vhost.conf` file contains all the configuration directives for Wordpress in one place, making it easier to maintain. The default file will look similar to this with a directives for the [akismet anti-spam plugin](https://akismet.com/wordpress/). Copy the the security headers after akismet configuration.

```she;;
<Directory "/opt/bitnami/wordpress/wp-content/plugins/akismet">
  # Only allow direct access to specific Web-available files.
    ...
</Directory>
<Directory "/opt/bitnami/wordpress">
  <IfModule mod_headers.c>
    Header set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
    Header set X-XSS-Protection "1; mode=block"
    Header set X-Frame-Options "SAMEORIGIN"
    Header set X-DNS-Prefetch-Control "on"
    Header set X-Content-Type-Options nosniff
    Header set Permissions-Policy "camera=(), microphone=(), geolocation=(), interest-cohort=()"
    Header set Content-Security-Policy "upgrade-insecure-requests; default-src 'none'; script-src 'self'; connect-src 'self'; img-src 'self'; style-src 'self';"0
    Header set Referrer-Policy "same-origin"
  /IfModule>
</Directory>
```

Let’s briefly examine what each directive means.

* **Strict-Transport-Security** allows acces only through HTTPS and HTTP requests are converted to HTTPS
* **X-XSS-Protection "1; mode=block"** response header is a feature in modern web browsers that blocks pages from loading when they detect cross-site scripting (XSS) attacks. 
* **X-Frame-Options "SAMEORIGIN"** prevents the loading of your content in a frame, iframe, embed, or object on another website. [Clickjacking](https://owasp.org/www-community/attacks/Clickjacking) is an attack that uses iframes to trick a user to clicking on a link that sends them to another page with malicious code.
* **X-DNS-Prefetch-Control "on"** resolves the URL of documents and images and fetches the content to reduce latency when a user clicks on a link. Not all browsers support this directive, but it can decrease load time for Chrome and Edge browsers.
* **X-Content-Type-Options nosniff** blocks requests for styles and the MIME type is not text/css or if a script is requested and the MIME type is not a JavaScript MIME type
* **Permissions-Policy** controls which browser features in a document can be accessed. Features such as cameras or microphones are disabled when the allowlist is empty, i.e., ().
* **Content-Security-Policy** treats HTTP URLs as if they were HTTPS URLs and specifies which resources can be loaded such as JavaScript, WebSocket and HTML requests, images, and style sheets.
* **Referrer-Policy "same-origin"** controls how a script or document can from one origin can load with a resource from another origin. Same-origin means that the protocol, host, and port are all the same. For example, `https:/example.com/index.html` is the same origin as `https://example.com/images/image.png`.

These security directives address Man-In-the-Middle attacks that can alter or expose data such as passwords. They also protect agains Cross-site scripting attacks that can inject malicious code that the application or web server executes.

## Remove Default Credentials









### Header 3

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.