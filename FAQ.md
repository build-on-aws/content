# Frequently Asked Questions

* [Markdown Syntax](#markdown-syntax)
  * [Where do I find the general Markdown syntax guide?](#where-do-i-find-the-general-markdown-syntax-guide)
  * [I have a series of posts. How do I link them together?](#i-have-a-series-of-posts-how-do-i-link-them-together)
  * [How do I link to other posts in my series or other posts on the BuildOn.AWS site?](#how-do-i-link-to-other-posts-in-my-series-or-other-posts-on-the-buildonaws-site)
  * [How do I show images in my post?](#how-do-i-show-images-in-my-post)
  * [How do I show videos in my post?](#how-do-i-show-videos-in-my-post)
  * [How do I get syntax highlighting in my code snippets?](#how-do-i-get-syntax-highlighting-in-my-code-snippets)
  * [What languages does syntax highlighting support?](#what-languages-does-syntax-highlighting-support)
  * [How do I write the same code snippet in different languages?](#how-do-i-write-the-same-code-snippet-in-different-languages)
* [Miscellaneous]()
  * [I published my post on my personal blog/Dev.to/Medium. Can I publish it on BuildOn.AWS?](#i-published-my-post-on-my-personal-blogdevtomedium-can-i-publish-it-on-buildonaws)
  * [Why was my content proposal not accepted? Do you have feedback for me?](#why-was-my-content-proposal-not-accepted-do-you-have-feedback-for-me)
  * [How do I optimize my content for SEO?](#how-do-i-optimize-my-content-for-seo)

## Markdown Syntax

### Where do I find the general Markdown syntax guide?

👉 https://www.markdownguide.org/basic-syntax/

### I have a series of posts. How do I link them together?

Currently, there is no built-in support for a series of posts, however you can accomplish this using simple [Markdown](https://www.markdownguide.org/basic-syntax/). Example:

```
This is a 3-part series:
1. What is broken access control? (this post)
1. [What is a cryptographic failure?](/posts/owasp-top-10-defined/02-what-is-a-cryptographic-failure/)
1. [What is an injection attack?](/posts/owasp-top-10-defined/03-what-is-an-injection-attack/)
```

_Note: Add a trailing slash at the end._

You can then structure the layout of your files like this:

```
posts
├── owasp-top-10-defined
│   ├── 01-what-is-broken-access-control
│   │   ├── index.md
│   │   ├── images
│   │   │   ├── broken-access-control.png
│   ├── 02-what-is-a-cryptographic-failure
│   │   ├── index.md
│   │   ├── images
│   │   │   ├── cryptographic-failure.png
│   ├── 03-what-is-an-injection-attack
│   │   ├── index.md
│   │   ├── images
│   │   │   ├── what-is-an-injection-attack.png
```

Where `posts/owasp-top-10-defined/01-what-is-broken-access-control/index.md` is part 1, `posts/owasp-top-10-defined/02-what-is-a-cryptographic-failure/index.md` is part 2, and `posts/owasp-top-10-defined/03-what-is-an-injection-attack/index.md` is part 3.

The resulting URL mapping will be:
- https://buildon.aws/posts/owasp-top-10-defined/01-what-is-broken-access-control/
- https://buildon.aws/posts/owasp-top-10-defined/02-what-is-a-cryptographic-failure/
- https://buildon.aws/posts/owasp-top-10-defined/03-what-is-an-injection-attack/

You can see an example of this in the repo [here](/posts/owasp-top-10-defined).

### How do I link to other posts in my series or other posts on the BuildOn.AWS site?

You can reference them using absolute paths like this, but **omit the `.md`** as we turn the markdown into an HTML document:

- `[What is a cryptographic failure?](/posts/owasp-top-10-defined/02-what-is-a-cryptographic-failure/)`
- `[A cool tutorial](/tutorials/a-cool-tutorial/)`

_Note: Please do not hard code the full URL in the post_

### How do I show images in my post?

Store your images (jpg, png, webp, svg, gif) in an `images` subdirectory of your post.

```
posts
├── what-happens-when-you-type-a-url-in-your-browser
│   ├── index.md
│   ├── images
│   │   ├── the-internet.jpg
```

_Note: Do not share images across posts or even posts in a series._

To show images in your post, you'll link to them using a relative path:

`![Put your alt-text here](images/the-internet.jpg) "Put your image title/caption here"`

The caption will appear underneath the image and also on mouse over.

### How do I show videos in my post?

At the moment, only YouTube videos are supported. Simply place the URL of the video in a separate line, for example:

```
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor. 

https://www.youtube.com/watch?v=dQw4w9WgXcQ

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.
```
The video will be embedded in the article with a responsive layout that adjusts to the available width.

![Video embedded in an article](embedded-video.webp "Video embedded in an article")

It works with the domains youtube.com, youtu.be or youtube-nocookie.com.

### How do I get syntax highlighting in my code snippets?

Use standard markdown code blocks, and specify the language, for example:

````markdown
   ```javascript
   console.log("Hello World!");
   ```
````

This will render something like:

![Example of code snippet with syntax highlighting](code-snippet-highlighting.webp "Example of code snippet with syntax highlighting")

If you do not specify a language, autodetection takes place. Although it works reasonably in many cases, this system is not perfect, so we recommend explicitly indicating the language in order to get consistent results. If you want to disable language autodetection in a code snippet, simply specify "text" or "plaintext" language. This is particularly useful for embedding the output of some command.

### What languages does syntax highlighting support?

Currently, the following languages are supported:

* bash (or sh)
* clojure
* cpp (or c++)
* csharp (or c#)
* css
* dockerfile (or docker)
* fsharp (or f#)
* go
* java
* javascript
* json
* kotlin
* php
* plaintext
* powershell
* python
* ruby
* shell
* swift
* typescript
* xml
* yaml (or yml)
* html
* sh
* text (or plaintext). This one actually disables highlighting preventing incorrect guessing.

### How do I write the same code snippet in different languages?

If you want embed the same code snippet in different languages, for example, explaining how to do some algorithm in Java, Python, Javascript, etc., put them in a list. The list must contain in all its elements a small piece of text (the title) and a code snippet, for example:

````markdown 
* Javascript
    ```javascript
    console.log("Hello world");
    ```
* Java
    ```java
    System.out.println("Hello world");
    ```
* Python
    ```python
    print("Hello world")
    ```
* Linux bash
    ```sh
    echo "Hello world"
    ```
````

This will be rendered as one single code block with different tabs on the top for the different code snippets. The title of each tab will be the text in every list item. Notice that if any of the list elements does not respect this format, the whole list will be rendered as a normal list.

![Example of a code snippet in different languages, rendered with tabs](code-snippet-tabs.webp "Example of a code snippet in different languages, rendered with tabs")

If you don't want a list of code snippets to be rendered as tabs, simply separate with an empty line every list element. Actually, if any of the list elements contains anything different to a text + a code snippet (like in the example above), it will not be rendered with tabs. 

## Miscellaneous

### I published my post on my personal blog/Dev.to/Medium. Can I publish it on BuildOn.AWS?

Please don’t syndicate to other platforms right now as we don’t want to drive traffic back to BuildOn.AWS during the soft launch. The canonical link helps surface the original content in search results.

### Why was my content proposal not accepted? Do you have feedback for me?

We will add feedback to your content proposal issue if we have suggestions for improvements. In many cases, the content is not a good fit for this platform and that is why it was not accepted.

### How do I optimize my content for SEO?

TODO
