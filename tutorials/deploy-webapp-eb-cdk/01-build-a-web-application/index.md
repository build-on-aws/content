# Module 1: Build a Web Application
In this module, we will create a Node.js web application and run it locally

**Time to complete** 10 minute

**Module prerequisites**
* AWS account with administrator-level access*
* Recommended browser: The latest version of Chrome or Firefox
[*]Accounts created within the past 24 hours might not yet have access to the services required for this tutorial.


## Overview
We will create a non-containerized application that we will deploy to the cloud. For this example, we are going to use Node.js to build a web application.

The web application will be a simple web app server that will serve static HTML files and also have a REST API endpoint. The focus of this tutorial is not to teach you how to build web applications, so feel free to use the example application, or build your own one. While this tutorial focuses on using Node.js, you can also build a similar web app with other Elastic Beanstalk supported programming languages, such as Java, .NET, PHP, Ruby, Python, Go, and Docker.

You can implement this in your local computer or in an AWS Cloud9 environment.

## What you will accomplish
In this module, you will:
* Develop a simple Node.js web app that serves an HTML file and has a simple REST API
* Run the application locally
 

## Implementation

### Create the client app
The first step is to create a new directory for our application.
```bash
mkdir my_webapp
cd my_webapp
```

Then you can initialize the Node.js project. This creates the package.json file that will contain all the definitions of your Node.js application.
```bash
npm init -y
```

If npm is not installed, install it in your local terminal following the instructions found at [Setting up your Node.js development environment](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/nodejs-devenv.html).

### Create Express app
We are going to use [Express](https://expressjs.com/) as our web application framework. To use it, we need to install Express as a dependency in our Node.js project.

```bash
npm install express
```

After running this command, you will see the dependency appear in the package.json file. Additionally, the node_modules directory and package-lock.json files are created.

Now you can create a new file called app.js. This file will contain the business logic for where our Node.js Express server will reside.

We are now ready to start adding some code. The first thing we need to add is the dependencies for the app—in this case, adding Express to allow use of the module we previously installed, and then the code to start up the web server. We will specify the web server to use port 8080, as that is what Elastic Beanstalk uses by default.

```JavaScript
var express = require('express');
var app = express();
var fs = require('fs');
var port = 8080;

app.listen(port, function() {
  console.log('Server running at http://127.0.0.1:', port);
});

```

We can start up our application now, but it won't do anything yet as we have not defined any code to process requests.

### Create a REST API

We will now add code to serve a response for a HTTP REST API call. To create our first API call, add the following code in the app.js file.

```JavaScript
var express = require('express');
var app = express();
var fs = require('fs');
var port = 8080;
/*global html*/

// New code
app.get('/test', function (req, res) {
    res.send('the REST endpoint test run!');
});


app.listen(port, function() {
  console.log('Server running at http://127.0.0.1:%s', port);
});

```

This is just to illustrate how to connect the /test endpoint to our code; you can add in a different response, or code that does something specific, but that is outside the scope of this tutorial.

### Serve HTML content

Our Express Node.js application can also serve a static web page. We need to create an HTML page to use as an example. Let's create a file called index.html.
Inside this file, add the following HTML with a link to the REST endpoint we created earlier to show how it connects to the backend.

```html
<html>
    <head>
        <title>Elastic Beanstalk App</title>
    </head>

    <body>
        <h1>Welcome to the demo for ElasticBeanstalk</h1>
        <a href="/test">Call the test API</a>
    </body>
</html>
```


To serve this HTML page from our Express server, we need to add some more code to render the /path when it is called. To do this, add the following code above the /test call:

```JavaScript
app.get('/', function (req, res) {
    html = fs.readFileSync('index.html');
    res.writeHead(200);
    res.write(html);
    res.end();
});
```

This code will serve the index.html file whenever a request for the root of the app (/) is made.

### Running the code locally

We are now ready to run our application and test if it is working locally. To do this, we are going to update package.json with a script to make it easier to run. In the package.json file, replace the scripts section with:
```JSON
"scripts": {
    "start": "node app.js"
  },
```

Now you can go to your terminal and run:
```bash
npm start
```

This will start a local server with the URL **http://127.0.0.1:8080** or **http://localhost:8080**.

When you paste this URL in your browser, you should see the following:
![View the application in local browser](images/gsg_build_elb_1.a82b887bd1a7f77b51fbd8413743c888e262d0bb.gif)

To stop the server, press **ctrl + c** to stop the process in your terminal where you ran **npm start**. 

## Conclusion
In this first module, we built a very basic Node.js application and ran it locally to ensure it works. In the next module, we will learn how to create the infrastructure and CI/CD pipeline using the AWS CDK to run it on AWS Elastic Beanstalk.