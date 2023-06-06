---
title: "What is Cloud Storage?"
description: "Learn the basics of object storage, block storage, and file storage - and why they matter to you."
tags:
  - basics
  - cloud
  - storage
  - block-storage
  - object-storage
  - file-storage
authorGithubAlias: damonk10
authorName: David Priest
date: 2023-05-25
---

In the modern world, we all need storage, whether it’s the garage hiding your dusty exercise equipment, or your kitchen cupboards helping you find that one spice you really need, or that space under your stairs for stashing recently-orphaned child wizards. Well cloud storage has just as many options as the real world — and you use them a lot more often than you might realize.

In the same way you have lots of physical stuff, you have loads of digital stuff that needs somewhere to go. Some of it is big, some small. Some you just need for a little while, and other stuff you want to hold onto for a long time. You might need to access it everyday or once a decade. And each of these functions requires a slightly different kind of storage.

The three main types — or classes — of cloud storage are object, block, and file. Let’s break them down.

## Object Storage

The class of cloud storage we encounter most often is object: it’s what stores most of the assets we see on websites every day. Essentially, object storage keeps intact unstructured objects (like documents, images, videos, and other types of data) and throws them into things called buckets. Then it can retrieve those objects wholesale and deliver them on demand.

Not only do websites depend on object storage; almost all consumer grade cloud storage — like iCloud, Google Drive, Dropbox, and so on — is object storage.

Why is it so prevalent? Well, it’s cheaper than other forms of storage and more durable (meaning you have really low rates of data loss or corruption). The downside is that object storage isn’t highly performant — that is, it’s not super fast. Websites sometimes take a second or two to retrieve all their assets, and that’s okay (for the most part)! Same with the old photos you’re looking at from your cloud storage account.

Object storage also keeps track of metadata. Put simply, metadata is data about data. Different files have to be transferred and displayed differently based on their type — and it’s useful to store ancillary information based on the types of files, too. For instance, you may want to know when and where a photo was taken, but for a written doc, you just need to know the author. Object storage knows how to keep track of this sort of metadata.

In short, object storage keeps each file intact, and keeps track of its unique metadata, which is valuable when storing lots of different types of files.

## Block Storage

Block storage generally gets a lot more use in business settings. It tends to be more highly performant than object storage, because it’s often supporting huge databases getting constant use — and that require extremely low latency in order to carry out their complex tasks effectively.

Let’s take a closer look: imagine you have a spreadsheet that you want to save on a server somewhere. Object storage would keep that file whole and distinct. So if you wanted to change just one little cell in that spreadsheet, the entire file would have to be re-written. Block storage, by contrast, breaks down that spreadsheet into uniform blocks, each of which can be edited individually. You want to change a single cell? In block storage, you’re just re-writing a couple of blocks of data. That difference may not seem like a big deal, but if you’re re-writing single cells in a massive spreadsheet a million times per day, you quickly realize how much more efficient it is to keep the data segmented.

Block storage is really useful, then, for performance. It also offers flexibility in storage locations. Remember, a given file or object doesn’t have to be maintained as a whole in block storage. Instead, it’s broken into all these small bits, which can be shifted around and stored across a server — or even a cluster of servers.

Block storage has an important drawback: it isn’t good at supporting simultaneous operations or users without risking data corruption. Because data is broken up into all those blocks, and because it’s stored fluidly, block storage relies on the operating system to put its files back together again.

In real life, it’s also not so simple as each block of data mapping neatly to a single cell in a spread sheet. Instead, blocks are arbitrarily sized bits of data that may affect a number of different parts of the overall file.

Why does all of this matter? Well, if multiple people fiddle with multiple, interconnected parts of the data at once, the operating system could be unable to put it all together when it tries, resulting in large-scale data loss.

So if you have a lot of data that needs to be accessed very, very quickly in sequence and by a single operator, then block storage works great. Or if you have data that has a single writer but many readers, block storage will work well, too. That means databases will usually be best stored in block storage.

## File Storage

On the other hand, if you have multiple operators or simultaneous operations being run, then you’ll want File storage.

File storage, unlike Block, maintains a logical hierarchy just like what you see in your computer: where you have files nested inside of folders. And because it maintains that hierarchy, you can lock single files for re-writing — which means there’s a bit more flexibility for collaboration.

What’s more, you can also delimit user access to certain files and folders, giving you really good control over that collaboration.

In short, file storage is likely the best class of storage for businesses that depend on internal collaboration and shared data access.

## Takeaways

Okay, we know the three kinds of storage — object, block, and file. But what’s the takeaway here for most people? Well, a few observations:

First, regular people use storage in really different ways from big companies. Object storage is definitely the most common sort of storage you encounter everyday via the internet — because for the most part, we’re just retrieving media. But companies are using a lot of block storage (because it enables better analysis of data and it performs really well at scale) and file storage (because it allows us to collaborate without corrupting data).

The other high-level takeaway:

Storage and computing used to always be linked. You bought a laptop or desktop computer, and how much computing power it had generally corresponded with how much storage it would have. Now we’re now in a situation where compute and storage in a cloud environment can become decoupled. Not only do cloud storage and compute dwarf traditional local resources — you can access vast quantities of both using machines with highly variable individual capabilities.

## Conclusion

Cloud storage is the unsung hero of the modern era: humanity is creating some 100 billion terabytes of data each year at this point, and that number is rapidly rising. But numbers that big are hard to visualize. So think about it like this: if every byte of data we created last year was a millimeter, our data would reach the sun... and back... over 300 million times. Okay, that still doesn’t help. Basically, the amount of data here is unimaginably big.

And this digital reality depends on an infrastructure most of us take for granted. If you want to learn more about cloud storage, check out my video on the topic, or watch my discussion with Curtis Evans where we dive deeper into modern cloud storage implementations.