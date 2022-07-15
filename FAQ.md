# Frequently Asked Questions

### I have a series of posts. How do I link them together?

Currently, there is no built-in support for series, however you can accomplish this using simple [Markdown](https://www.markdownguide.org/basic-syntax/). Example:

```
This is a 3-part series:
1. [Title of part 1]()
1. [Title of part 2]()
1. [Title of part 3]()
```

You can then structure the layout of your files like this:

```
posts
├── become-cli-ninja-on-mac
│   ├── 01-start-an-ec2-mac-instance.md
│   ├── 02-remotely-connect-a-mac-instance.md
│   ├── images
│   │   ├── archi-ssh-tunnel.png
```

Where `posts/become-cli-ninja-on-mac/01-start-an-ec2-mac-instance.md` is part 1 and `posts/become-cli-ninja-on-mac/02-remotely-connect-a-mac-instance.md` is part 2.

The resulting URL mapping will be:
- https://blog.buildon.aws/posts/become-cli-ninja-on-mac/01-start-on-an-ec2-mac-instance
- https://blog.buildon.aws/posts/become-cli-ninja-on-mac/02-remotely-connect-a-mac-instance

### I published my post on my personal blog/Dev.to/Medium. Can I publish it on BuildOn.AWS?

Please don’t syndicate to other platforms right now as we don’t want to drive traffic back to BuildOn.AWS during the soft launch. The canonical link helps surface the original content in search results.

#### Why was my content proposal not accepted? Do you have feedback for me?

We will add feedback to your content proposal issue if we have suggestions for improvements. In some cases, the content is not 

#### How do I optimize my content for SEO?

TODO
