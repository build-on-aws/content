---
title: "How to get the most out of Amazon CodeWhisperer: Developer Guidelines"
description: "Unlock the power of Amazon CodeWhisperer from AWS. Learn how short, focused developer comments and intuitive variable & function names enhance coding speed, security and efficiency. Perfect for coders at all levels!"
tags:
    - CodeWhisperer
    - Python
authorGithubAlias: brookejamieson
authorName: Brooke Jamieson
date: 2023-07-14 (expected publication date)
---

<!-- Throughout this template there will be comments like these, please remove them before committing the first version of the content piece. -->
<!-- NB: READ THE COMMENT ABOVE, AND DELETE THIS AND OTHER COMMENTS!!! -->

Amazon CodeWhisperer is a powerful AI coding companion that helps developers build applications faster and more securely. I’ve done quite a few demos of CodeWhisperer since it’s launch, and the number one question developers ask me is if there’s anything they can do to improve the results when coding alongside CodeWhisperer, and the answer is yes! 
If you want to improve the results when using CodeWhisperer, here are some tips to set yourself up for success:
## Keep Comments Short and Focused
CodeWhisperer works best when comments represent small, discrete tasks. Long comments that describe complex functions won’t provide the context CodeWhisperer needs. 
For example:
```
# Add two numbers
def add(a, b): 
    return a + b
```
CodeWhisperer can generate this short code snippet easily. Compare this to a longer comment:
```
# Add all numbers in a list and return a sum, along with the number of elements and the average of the numbers
def add_all(numbers):
    sum = 0
    for i in numbers:
        sum += i
        count = len(numbers)
        average = sum / count
        return sum, count, average
```
While CodeWhisperer can still generate this function, it will step through line-by-line rather than completing the full code block at once. Keeping comments concise helps CodeWhisperer understand exactly what you’re trying to do, every step of the way, so that it can help you achieve these goals. 

Overall, the key with comments (regardless of whether you’re helping an AI coding companion or working as part of a team) is to make sure the comments are short and concise and map to discrete tasks, so it’s more manageable. This is actually one of the things I noticed the most when I started using code whisperer - I was writing better comments to help my AI sidekick, but this was improving my comments for human audiences too! 

## Use Intuitive Names
Like humans, CodeWhisperer benefits from intuitive names for variables, functions, and other code elements. 
For example: 

```
name = "G. Michael"
song = "C. Whispers"
if name == "G. Michael" and song == "C. Whispers":
    print("I love this song!")
```
In this example (which believe it or not is actually in the [official docs](https://docs.aws.amazon.com/codewhisperer/latest/userguide/whisper-code-block.html)), CodeWhisperer uses the contextual information in variable names to complete the function with a print statement that makes sense. 

However, I’m sure you can all think of bad examples of variable names you’ve seen in the wild, but let’s look at this example: 
```
n = "G. Michael"
s = "C. Whispers"
if n == "G. Michael" and s == "C. Whispers":
    print("True")
```
In this case, the variable names are so short that CodeWhisperer doesn’t have any context to enhance the code it’s generating for you. The function still completes with a print statement if the condition is true, but the outcome isn’t as good without the extra information. 

Using clear variable names helps CodeWhisperer understand the context of what you’re doing, so it can provide more relevant suggestions for what you’re trying to do. But once again, using clear variable names is best practices regardless who you’re writing the code with! 

## Wrap Up

To summarize, to get the best results from Amazon CodeWhisperer: 
1. Keep developer comments short and focused on smaller tasks, and 
2. Use intuitive names for code elements like variables and functions. 

I encourage you to get out there and experiment with Amazon CodeWhisperer in your projects. It’s designed to fit seamlessly into your workflow, supporting 15 programming languages and Popular IDEs like VsCode, IntelliJ Idea and AWS Cloud 9, as well as the Lambda console. With billions of lines of code in it’s knowledge base, CodeWhisperer can help you get more done faster, code with confidence and enhance your code security. 

