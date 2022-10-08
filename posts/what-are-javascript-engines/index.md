---
title: What Are JavaScript Engines?
description: Ever wonder what kind of technology underlies JavaScript, the language of the web? Learn about the history and evolution of the JavaScript's core.
tags:
    - JavaScript
    - foundational
    - aws
authorGithubAlias: jlooper
authorName: Jen Looper
date: 2022-11-01
---

Writing code for the web sometimes feels a little magical in that we write a sequence of characters and things happen in a browser. But understanding the tech behind the magic can help you better tune your craft as a programmer. At least you might feel slightly less idiotic when trying to explain what is going on behind the scenes in a JavaScript-powered web or mobile stack.

## Intro

Many years ago when I was a graduate student instructor, I was whining to a professor about not grasping a particularly thorny point of French grammar well enough to teach it to my undergraduate class. I remember her words at the time: “Sometimes, the only way to learn something is to teach it.”

Faced with trying to explain to engineers how NativeScript works behind the scenes by using a JavaScript engine at runtime to bridge to native APIs, it’s easy to get lost in the weeds. Any JavaScript developer, in fact, might be curious about the engines that underlie this technology that we use on a daily basis. Let’s break down what a JavaScript engine does, why different platforms use different engines, how they have evolved over the years, and why we, as developers, should care.

## First, a little terminology

A ‘JavaScript engine’ is often termed a type of virtual machine. A ‘virtual machine’ refers to the software-driven emulation of a given computer system. There are many types of virtual machines, and they are classified by how precisely they are able to emulate or substitute for actual physical machines.

A ‘system virtual machine’, for example, provides a complete emulation of a platform on which an operating system can be executed. Mac users are familiar with Parallels, a system virtual machine that allows you to run Windows on your Mac.

A ‘process virtual machine’, on the other hand, is less fully-functional and can run one program or process. Wine is a process virtual machine that allows you to run Windows applications on a Linux machine, but does not provide an entire Windows OS on a Linux box.

A JavaScript engine is a kind of process virtual machine that is designed specifically to interpret and execute JavaScript code.

> Note: it’s important to differentiate between the layout engines that power a browser by laying out web pages, versus the lower-level JavaScript engine that interprets and executes code. A good explanation is found here.

## So what, exactly, is a JavaScript engine, and what does it do?

The basic job of a JavaScript engine, when all is said and done, is to take the JavaScript code that a developer writes and convert it to fast, optimized code that can be interpreted by a browser or even embedded into an application. JavaScriptCore, in fact, calls itself an “optimizing virtual machine”.

More precisely, each JavaScript engine implements a version of ECMAScript, of which JavaScript is a dialect. As ECMAScript evolves, so do JavaScript engines. The reason there are so many different engines is each one is designed to work with a different web browser, headless browser, or runtime like Node.js.

You’re probably familiar with web browsers, but what’s a headless browser? It’s a web browser without a graphic user interface. They are useful for running automated tests against your web products. A good example is PhantomJS. And where does Node.js fit into this? Node.js is an asynchronous, event-driven framework that allows you to use JavaScript on the server-side. Since they are JavaScript-driven tools, they are powered by JavaScript engines.

Given the definition of a virtual machine above, it makes sense to term a JavaScript engine a process virtual machine, since its sole purpose is to read and compile JavaScript code. This doesn’t mean that it’s a simple engine. JavaScriptCore, for example, has six ‘building blocks’ that analyze, interpret, optimize, and garbage collect JavaScript code.

## How does this work?

This depends, of course, on the engine. The two main engines of interest to us, because they are leveraged by NativeScript, are WebKit’s JavaScriptCore and Google’s V8 engine. These two engines handle processing code differently.

JavaScriptCore performs a series of steps to interpret and optimize a script:

It performs a lexical analysis, breaking down the source into a series of tokens, or strings with an identified meaning.
The tokens are then analyzed by the parser for syntax and built into a syntax tree.
Four JIT (just in time) processes then kick in, analyzing and executing the bytecode produced by the parser.
Huh? In simple terms, this JavaScript engine takes your source code, breaks it up into strings (a.k.a. lexes it), takes those strings and converts them into bytecode that a compiler can understand, and then executes it.

Google’s V8 engine, written in C++, also compiles and executes JavaScript source code, handles memory allocation, and garbage collects leftovers. Its design consists of two compilers that compile source code directly into machine code:

Full-codegen: a fast compiler that produces unoptimized code
Crankshaft: a slower compiler that produces fast, optimized code.
If Crankshaft determines that the unoptimized code generated by Full-codegen is in need of optimization, it replaces it, a process known as ‘crankshafting’.

Fun fact: a crankshaft is an integral part of the internal combustion engines used in the automotive industry. A well-known engine of this type used in higher-performance vehicles is the V8.

Once machine code is produced by the compilation process, the engine exposes all the data types, operators, objects, and functions specified in the ECMA standard to the browser, or any runtime that needs to use them, like NativeScript.

## What JavaScript engines are out there?

There is a dizzying variety of JavaScript engines available to analyze, parse and execute your client-side code. With every browser version release, the JavaScript engine might be changed or optimized to keep up with the state of the art in JavaScript code execution.

It’s useful to remember, before getting totally confused by the names given to these engines, that a lot of marketing push goes into these engines and the browsers they underlie. In this useful analysis of JavaScript compilation, the author notes wryly: “In case you didn’t know, compilers are approximately 37% composed of marketing, and rebranding is one of the few things you can do to a compiler, marketing-wise, hence the name train: SquirrelFish, Nitro, SFX…”

While keeping in mind the heavy marketing influence in naming and renaming these engines, it’s useful to note a few of the major events in the history of the JavaScript engine. I’ve compiled a handy chart for you:

Browser, Headless Browser, or Runtime	JavaScript Engine
Mozilla	Spidermonkey
Chrome	V8
Safari**	JavaScriptCore*
IE and Edge	Chakra
PhantomJS	JavaScriptCore
HTMLUnit	Rhino
TrifleJS	V8
Node.js***	V8
Io.js***	V8

*JavaScriptCore was rewritten as SquirrelFish, rebranded as SquirrelFish Extreme also called Nitro. It’s still a true statement however to call JavaScriptCore the JavaScript engine that underlies WebKit implementations (such as Safari).

**iOS developers should be aware that Mobile Safari leverages Nitro, but UIWebView does not include JIT compilation, so the experience is slower. With iOS8, however, developers can use WKWebView which includes access to Nitro, speeding up the experience considerably. Hybrid mobile app developers should be able to breathe a little easier.

***One of the factors in the decision to split io.js from Node.js had to do with the version of V8 that would be supported by the project. This continues to be a challenge, as outlined here.

## Why should we care?

The goal of a JavaScript engine’s code parsing and execution process is to generate the most optimized code in the shortest possible time.

Bottom line, the evolution of these engines parallels our quest to evolve the web and mobile spheres to make them as performant as possible. To track this evolution, you can see how various engines perform in benchmarking graphs such as those produced on arewefastyet.com. It’s interesting, for example, to compare Chrome’s performance when powered by V8 versus a non-Crankshafted engine.

arewefastyet

Any web developer needs to be aware of the differences inherent in the browsers that display the code that we work so hard to produce, debug, and maintain. Why do certain scripts work slowly on one browser, but more quickly on another?

Mobile developers, similarly, especially those who write hybrid mobile apps using a webview to display their content, or those using a runtime like NativeScript, will want to know what engines are interpreting their JavaScript code. Mobile web developers should understand the limitations inherent to and possibilities offered by the various browsers on their small devices. Keeping up with the changes in JavaScript engines will really pay off as you evolve as a web, mobile, or app developer.

> This article originally appeared in 2015 on the Telerik Developer Network, and has since been revised and updated for 2022.