---
title: "Build a Web App to Deliver Calming and Empowering Affirmations Using Lambda and DynamoDb"
description: "May is Mental Health Month, so why not take a little time to relax and build yourself a mindfulness app?"
tags:
    - astro
    - lambda
    - dynamodb
authorGithubAlias: jlooper
authorName: Jen Looper
date: 2023-05-12
---

!["Your affirmation app"](images/banner.png)

May is Mental Health month, and, when you think about it, coding up a very simple web app can feel like a mindfulness exercise, if done without pressure in a calm environment. Why not take a little time this month to build yourself a mindfulness app - an app that can deliver a quick affirmation to you or anyone lucky enough to come across it on the internet? Using a lightweight web framework called Astro.dev, plus a Lambda endpoint that can query a Dynamodb database, you can code up a friendly affirmation app in no time at all. Let's get started! 

By the end of this tutorial, you will have built a web app that you can host on GitHub pages. Refresh the page every time you need a little seratonin boost. 

> This app was designed after the instructions given in [this helpful tutorial](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-dynamo-db.html) in the API Gateway docs. 

![my affirmation app](images/demo.png)

## Set Your Intention 

Let's get set up to start building your app. We'll be using a hot new framework called [Astro](https://astro.build/). Astro is a new breed of lightweight, highly-performant 'meta frameworks' in the JavaScript world, a framework that can use many other frameworks alongside it. Learn more about what you can do with Astro [in their excellent AI-infused docs]().

> Before starting, make sure your local computer is set up to use npm, git and node.

For now, you will need to follow the installation instructions outlined [in these instructions on using the CLI](https://docs.astro.build/en/install/auto/). 

You can start working anywhere on your local computer. Run the Astro setup wizard by typing `npm create astro@latest` in your terminal or command line. A wizard will launch and help you create a folder for your project. Ask the wizard to Include sample files and be sure to install dependencies. You don't need to use TypeScript in this app, so you can say 'no' to this. Initialize your new Astro folder as a git repository. The Terminal will display a message that you've successfully created your app.

![terminal](images/terminal.png)

Use `cd` to enter the new folder Astro created and make sure all dependencies are installed by typing `npm i` in the terminal. Type `npm run dev` to start your local server. At the moment, your web app looks like this:

![my Astro app](images/astro.png)

Use your favorite code editor to explore the folder that was just scaffolded. I prefer Visual Studio Code:

> tip: type `code .` in your terminal to open the folder in 
VS Code

Now you can prune some files in the scaffolded app, leaving just one box where you'll display your affirmations. 

In the `index.astro` file, replace all the code with the following:

```
---
import Layout from '../layouts/Layout.astro';

import AffirmationComponent from '../components/AffirmationComponent.jsx';

---
<Layout title="My Affirmations">
	<main>

		<h1>Welcome to <span class="text-gradient">Your Affirmation App</span></h1>
			<section class="text">
				<AffirmationComponent client:load affirmations={'my affirmation'} />
			</section>
	</main>
</Layout>

<style>
	main {
		margin: auto;
		padding: 1.5rem;
		max-width: 80ch;
	}
	h1 {
		font-size: 3rem;
		font-weight: 800;
		margin: 0;
	}
	.text-gradient {
		background-image: var(--accent-gradient);
		-webkit-background-clip: text;
		-webkit-text-fill-color: transparent;
		background-size: 400%;
		background-position: 0%;
	}
	.text {
		line-height: 1.6;
		margin: 1rem 0;
		border: 1px solid rgba(var(--accent), 25%);
		background-color: white;
		padding: 1rem;
		border-radius: 0.4rem;
		text-align: center;
		font-size: 1.5rem;
	}
	
</style>
```

You'll see that an error appears in your local server, as the file called AffirmationsComponent.jsx is missing. Let's fix that.

> What's going on with the above code? Astro offers an interesting syntax where it can combine front matter with style, script, and layout tags. You can progressively enhance your app to include more and more functionality by building up your components' capabilities.

## Embrace the Unknown

Astro is great for generating static web pages such as blogs, but we need it to do a little bit more and have the ability to pull data from an endpoint and refresh an element of the page. So we need to add a framework. Let's use one of the most popular JavaScript frameworks, Preact, to allow this site to become dynamic in production.

> [Preact](https://preactjs.com/) is a lightweight version of React, "a fast 3kB alternative to React with the same modern API"

You can add [frameworks](https://docs.astro.build/en/guides/integrations-guide/) progressively to an Astro app by using the Astro CLI. Type in `npx astro add preact` in the terminal of your app. Allow Astro to configure your app to suit Preact's requirements (a configuration change is needed).

> Tip: use the built-in terminal in VS Code to keep your environment neat by selecting terminal > new terminal. 

Now that you have added Preact, in the /src/components folder, remove the Card.astro file and add a file called AffirmationComponent.jsx, a file type understood by Preact. 

In your AffirmationComponent.jsx file, add the following code:

```
import { useState } from 'preact/hooks';

export default function Affirmation({affirmations}) {

  return (
      <h3>{affirmations}</h3>
  );
}
```
In this example, the text 'my affirmation' is being passed from index.astro to the child component, where it is displayed. Your app should now look like the image below. Change the hard-coded affirmation to anything you like! We'll revisit this code once we have an endpoint built to query a database full of great quotes.

![demo 2](images/demo2.png)

## Capture the Moments

Now it's time to build up a database with some sample affirmations. In the AWS Console, search for [DynamoDB](https://console.aws.amazon.com/dynamodb/). This is a serverless database you will use to store a series of affirmations. Choose Create table and name it `Affirmations`. For its partition key, enter `Id`. You can add a few helpful phrases by using the `Create Item`. Each item should have an Id and a Text, like this:

![dynamodb sample](images/dynamodb.png).

> Here's a hepful [list of nice affirmations](https://github.com/annthurium/affirmations/blob/master/affirmations.js).

Next, you need to create a serverless function using Lambda to query this database. Navigate to the [Lambda console](https://console.aws.amazon.com/lambda) and choose `Create function` > `Author from Scratch`. You can call it `get-affirmation-function` and use Node 18 for the runtime. In `Permissions`, and change the default execution role. You'll need to create a new role, so under `Permissions` choose `Create a new role from AWS policy templates`. You can call the role `http-affirmations-role`. Select the `Simple microservice` permissions to let your new function interact with DynamoDB. Now you can create your function.

Now you need to add a bit of code in your function to query the database, so open the index.mjs file in the Lambda code editor. Add the following code and select `Deploy`:

```
import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import {
  DynamoDBDocumentClient,
  ScanCommand,
  GetCommand,
} from "@aws-sdk/lib-dynamodb";

const client = new DynamoDBClient({});

const dynamo = DynamoDBDocumentClient.from(client);

const tableName = "Affirmations";

export const handler = async (event, context) => {
  let body;
  let statusCode = 200;
  const headers = {
    "Content-Type": "application/json",
  };

  try {
    switch (event.routeKey) {
      case "GET /items":
        body = await dynamo.send(
          new ScanCommand({ TableName: tableName })
        );
        body = body.Items;
        break;
      default:
        throw new Error(`Unsupported route: "${event.routeKey}"`);
    }
  } catch (err) {
    statusCode = 400;
    body = err.message;
  } finally {
    body = JSON.stringify(body);
  }

  return {
    statusCode,
    body,
    headers,
  };
};
```

Now, to connect your function to your database, you need to use one more service: [API Gateway](https://console.aws.amazon.com/apigateway).


## Make the Connection

In the AWS console, navigate over to https://console.aws.amazon.com/apigateway. Choose Create API > HTTP API > Build. Name your new API `http-affirmations-api`. Click the `Next` button and create an integration with the Lambda function that you just created. Then, add one route, which is the pathway that the API will use to perform various functions between the Lambda function and your database.

You need to specify that your API can use http `GET` to select elements from the database. Add `/items` as the route's name, then `Next` and `Create`:

![route](images/route.png). 

Test your new API by visiting the URL listed in the API Gateway console. Append `/items` to the end of the URL; you should see your database items listed!

## A Beautiful Convergence

Now, the last thing to do is to configure your web app to query the database and display a new affirmation each time the screen is refreshed. Normally, Astro will fetch data once, when the component is rendered. To make the data refresh from the database each time the page is reloaded, you need to make a few edits to allow client-side rendering in Astro.

Go back to make some edits to your Astro app. In `index.astro`, under the first import statement, add the ability to fetch the endpoint you just created, using the URL from API Gateway:

```
const response = await fetch('https://your-api-url/items');
const data = await response.json();
```
Then, replace the hard-coded affirmation where the child component is included:

```
<AffirmationComponent client:load affirmations={data} />
```
The use of `client:load` lets the app 'hydrate' the component on page load.

Finally, you need to make one more change in the AffirmationComponent.jsx file. Under the `export default` statement, import your data:

```
const num = Math.floor(Math.random() * affirmations.length);
  const [affirmation] = useState(JSON.stringify(affirmations[num].Text));
```

And finally make sure that the <h3> tag includes just the one affirmation:

```
<h3>{affirmation}</h3>
```

Your affirmations should refresh each time you reload the page.

## Find your Happy Place

The last thing you need to do is to celebrate your accomplishment and share it with the world. An easy way to do this is by using GitHub pages, deployed via GitHub Actions.

Commit your code to GitHub, using the git integration that was created by Astro when you scaffolded your app. Make sure the repo is public. Now you'll need a GitHub action to build and deploy your app to GitHub pages, since it's not a static app but has a build step.

Navigate to your GitHub repo and visit the Actions tab. Click the 'New Workflow' button and search for Astro. Select the Astro Workflow and click `configure`. This proces creates a new folder called `.github/workflows` with a .yaml file outlining the steps needed to build your app. Commit this structure to your repo by selecting `commit changes`. 

Finally, navigate to Settings > Pages to ensure that your app has GitHub Pages configured and that your new Action is building them. GitHub should provide you a URL. A demo of this whole app is available [here](https://jlooper.github.io/affirmations/).

## Breathe!

Wasn't that calming? By using easy-to-use, beautiful tooling such as Astro.dev, Lambda, Dynamodb, API Gateway, and hassle-free web hosting, you built a lovely application that looks good and helps you feel good, too. Don't forget to hydrate, listen to soothing music, touch grass, and enjoy May!