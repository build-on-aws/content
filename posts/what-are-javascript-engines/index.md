---
title: "What Are JavaScript Engines?"
description: "Ever wonder what kind of technology underlies JavaScript, the language of the web? Learn about the history and evolution of JavaScript's core."
tags:
    - javascript
    - students
spaces: 
     - students
authorGithubAlias: jlooper
authorName: Jen Looper
date: 2022-11-09
---

|ToC|
|---|

![Banner image asking "what are JavaScript engines?"](images/banner.png)

Writing code for the web sometimes feels a little magical in that we write a sequence of characters in a file, open that file in a browser, and watch it come to life. But understanding the tech behind the magic can help you better hone your craft as a programmer.

In this article, you'll discover what is going on behind the scenes in a JavaScript-powered web or mobile stack by grasping the complexities of the JavaScript engines that power browsers. Let’s break down what a JavaScript engine does, why different platforms use different engines, how they have evolved over the years, and why we, as developers, should care.

## First, a little terminology

A ‘JavaScript engine’ is often termed a type of [virtual machine](https://en.wikipedia.org/wiki/Virtual_machine). A ‘virtual machine’ refers to the software-driven emulation of a given computer system. There are many types of virtual machines, and they are classified by how precisely they are able to emulate or substitute for actual physical machines.

A ‘system virtual machine’, for example, provides a complete emulation of a platform on which an operating system can be executed. Mac users might be familiar with [Parallels](https://parallels.com), a system virtual machine that allows you to run Windows on your Mac.

A ‘process virtual machine’, on the other hand, is less fully-functional and can run one program or process. [Wine](https://winehq.com) is a process virtual machine that allows you to run Windows applications on a Linux machine, but does not provide an entire Windows OS on a Linux box.

A JavaScript engine is a kind of process virtual machine that is designed specifically to interpret and execute JavaScript code.

> Note: it’s important to differentiate between the [layout engines](https://en.wikipedia.org/wiki/Comparison_of_layout_engines_ECMAScript) that power a browser by laying out web pages, versus the lower-level JavaScript engine that interprets and executes code. A good explanation is found [in this article on how browsers work](https://web.dev/howbrowserswork/).

## So what, exactly, is a JavaScript engine, and what does it do?

The basic job of a JavaScript engine, when all is said and done, is to take the JavaScript code that a developer writes and convert it to fast, optimized code that can be interpreted by a browser or even embedded into an application. JavaScriptCore, in fact, [calls itself an "optimizing virtual machine"](http://trac.webkit.org/wiki/JavaScriptCore).

More precisely, each JavaScript engine implements a version of ECMAScript, of which JavaScript is a dialect. As ECMAScript evolves, so do JavaScript engines. The reason there are so many different engines is each one is designed to work with a different web browser, headless browser, or runtime like Node.js.

> You’re probably familiar with web browsers, but what’s a [headless browser](https://en.wikipedia.org/wiki/Headless_browser)? It’s a web browser without a graphic user interface. They are useful for running automated tests against your web products. Since version 59 of Chrome and version 56 of Firefox, regular browsers can be used in this way, notably for testing. And where does Node.js fit into this? Node.js is an asynchronous, event-driven framework that allows you to use JavaScript on the server-side. Since they are JavaScript-driven tools, they are powered by JavaScript engines.

Given the definition of a virtual machine above, it makes sense to term a JavaScript engine a process virtual machine, since its sole purpose is to read and compile JavaScript code. This doesn’t mean that it’s a simple engine. [JavaScriptCore](https://trac.webkit.org/wiki/JavaScriptCore), for example, has six ‘building blocks’ that analyze, interpret, optimize, and garbage collect JavaScript code.

## How does this work?

This depends on the engine. Let's consider two important engines: WebKit’s JavaScriptCore and Google’s V8 engine. These two engines handle processing code differently.

JavaScriptCore performs a series of steps to interpret and optimize a script:

- It performs a [lexical analysis](https://en.wikipedia.org/wiki/Lexical_analysis), breaking down the source into a series of tokens, or strings with an identified meaning.
- The tokens are then analyzed by the parser for syntax and built into a syntax tree.
- Four JIT (just in time) processes then kick in, analyzing and executing the bytecode produced by the parser.

>In simple terms, this JavaScript engine takes your source code, breaks it up into strings (a.k.a. lexes it), takes those strings and [converts them](https://en.wikipedia.org/wiki/Parse_tree) into bytecode that a compiler can understand, and then executes it.

Google’s [V8 engine](https://v8.dev/docs), written in C++, also [compiles](https://javascript.plainenglish.io/lets-understand-chrome-v8-compiler-workflow-parser-36941d0ff204) and executes JavaScript source code, handles memory allocation, and garbage collects leftovers. Its design consists of a compiler pipeline that compiles source code directly into machine code:

- Ignition, the interpreter that generates bytecode
- TurboFan, an optimizing compiler that compiles that bytecode into machine code
- SparkPlug, a compiler that supplements TurboFan

> If you're interested in history, this new pipeline replaced the older Full-codegen and Crankshaft double-compiler design used previously by V8.

Once machine code is produced by the compilation process, the engine exposes all the data types, operators, objects, and functions specified in the ECMA standard to the browser, or any runtime that needs to use them, like Node.js, Deno, or Electron (which is used by Visual Studio Code).

## A little detour: runtimes

If JavaScript engines quietly run in the background, parsing code and breaking it up into readable strings so a compiler can read and compile it, runtimes tend to attract more attention. Why is that?

Well-known runtimes work on top of JavaScript engines, extending their power. The best-known is Node, but Deno and Bun are newcomers to the arena. Node and Deno embed V8, and Bun embeds JavaScriptCore. Bun claims to run faster than Node or Deno because JavaScriptCore is faster than V8, handling 69,845 http requests per second vs 16,288 for Node and 12,926 for Deno.

These runtimes' goal, as stated by [Bun's docs](https://bun.sh/), "is to run most of the world's JavaScript outside of browsers, bringing performance and complexity enhancements to your future infrastructure, as well as developer productivity through better, simpler tooling." These runtimes, in fact, leverage the power of JavaScript engines to make JavaScript run outside of browsers. [NativeScript](https://nativescript.org) is a good example of a runtime built specifically for cross-platform native mobile application development built using JavaScript.

These runtimes were also built to solve some of the inherent problems presented by JavaScript's single-threaded architecture. Node, for example, prioritizes asynchronous, threadless execution of routines. All these runtimes offer a curated developer experience, including built in support for well-loved APIs like fetch, websocket, and even JSX, beloved of React developers. This may be the reason that they tend to attract developer attention.

Runtimes, overall, address perceived gaps in the performance of standard browser architecture and the engines that power them. As the engines evolve, so, surely, will these runtimes.

## What JavaScript engines are out there?

There is a large variety of JavaScript engines available to analyze, parse, and execute your client-side code. With every browser version release, the JavaScript engine might be changed or optimized to keep up with the state of the art in JavaScript code execution.

It’s useful to remember, before getting totally confused by the names given to these engines, that a lot of marketing push goes into these engines and the browsers they underlie. In this [useful analysis](http://wingolog.org/archives/2011/10/28/javascriptcore-the-webkit-js-implementation) of JavaScript compilation, the author notes wryly: "In case you didn’t know, compilers are approximately 37% composed of marketing, and rebranding is one of the few things you can do to a compiler, marketing-wise, hence the name train: SquirrelFish, Nitro, SFX..."

While keeping in mind the ebb and flow around naming and renaming these engines, it’s useful to note a few of the major events in the history of the JavaScript engine. I’ve compiled a handy chart for you:

| Browser, Headless Browser, or Runtime | JavaScript Engine |
-- | --
Mozilla	| Spidermonkey
Chrome	| 	V8
Safari	| 	JavaScriptCore*
IE	| 	Chakra
Node.js	| 	V8
Deno | V8
Bun | JavaScriptCore
Edge** | Blink and V8

*JavaScriptCore was rewritten as SquirrelFish, rebranded as SquirrelFish Extreme, also called Nitro. It’s still a true statement however to call JavaScriptCore the JavaScript engine that underlies WebKit implementations (such as Safari).

**[Edge](https://en.wikipedia.org/wiki/Microsoft_Edge) originally used the [Chakra](https://github.com/chakra-core/ChakraCore) engine, some of which Microsoft open sourced. Edge was then rebuilt as a Chromium browser, with Blink and V8 JavaScript engines under the hood.

## Why should we care?

The goal of a JavaScript engine’s code parsing and execution process is to generate the most optimized code in the shortest possible time.

Bottom line, the evolution of these engines parallels our quest to evolve the web and mobile environments to make them as performant as possible. To track this evolution, you can see how various engines perform in benchmarking graphs such as those produced on [arewefastyet.com](https://arewefastyet.com).

Any web developer needs to be aware of the differences inherent in the browsers that display the code that we work so hard to produce, debug, and maintain. Why do certain scripts work slowly on one browser, but more quickly on another?

Mobile developers, similarly, especially those who write hybrid mobile apps using a webview to display their content, will want to know what engines are interpreting their JavaScript code. All web developers who care about user experience should understand the limitations inherent to and possibilities offered by the various browsers on their small devices. Keeping up with the changes in JavaScript engines will be time well spent as you evolve as a web, mobile, or app developer.

> This article originally appeared in 2015 on the Telerik Developer Network, and has since been revised and updated for 2022.
