# Frequently Asked Questions

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
- https://blog.buildon.aws/posts/owasp-top-10-defined/01-what-is-broken-access-control/
- https://blog.buildon.aws/posts/owasp-top-10-defined/02-what-is-a-cryptographic-failure/
- https://blog.buildon.aws/posts/owasp-top-10-defined/03-what-is-an-injection-attack/

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

### I published my post on my personal blog/Dev.to/Medium. Can I publish it on BuildOn.AWS?

Please don’t syndicate to other platforms right now as we don’t want to drive traffic back to BuildOn.AWS during the soft launch. The canonical link helps surface the original content in search results.

### Why was my content proposal not accepted? Do you have feedback for me?

We will add feedback to your content proposal issue if we have suggestions for improvements. In many cases, the content is not a good fit for this platform and that is why it was not accepted.

### How do I optimize my content for SEO?

TODO
