---
title: "From Python to Java: How I Used Amazon CodeWhisperer to Switch Languages"
description: "Want to easily port code between programming languages? This post shares how CodeWhisperer can make switching between Python and Java a breeze."
tags:
    - generative-ai
    - codewhisperer    
    - rekognition
    - java
    - students
spaces:
  - generative-ai
  - students
waves:
  - generative-ai
authorGithubAlias: srhowell
authorName: Stephen Howell
date: 2023-10-02
---
|ToC|
|---|

My Academic Developer Advocate role includes teaching students how to build solutions on AWS, and discussing strategies with lecturers on how to teach cloud and AI skills. A topic which is increasingly common with my audience is *Generative AI in the Classroom*. There is a range of attitudes to *Gen AI* from academics I meet, ranging from apathy to hostility to cautious optimism. I'm erring on the side of optimism that Gen AI will be a useful teaching tool for lecturers. This post condenses a few of the recent techniques I've explored for enhancing my own teaching practice.  

> I want to recognize that I've heard concerns about using Generative AI in teaching and learning. I've heard fears that students will not learn to code or do their own assignments because they will just 'ask the AI to do it for them'. I've also heard from lecturers who are excited to adopt GenAI as a teaching tool. For this post, I'm focusing on a small use case that I think may be familiar to many lecturers, trainers, and those who volunteer to teach coding: How to move from one language and stack to another. I'm not making any pronouncements on whether you *should* teach with Gen AI, but I'd like to offer one way you *could* teach with it.

For a broader discussion of Generative AI in education, I recommend reading [Generative AI for Education: A Curriculum and Instruction Perspective](/posts/genai-for-edu).

## Builder's Choice

A good Developer Advocate can bring a builder on a learning journey from the stack they use today to the stack they want to use tomorrow. In this case, my builder audience are students and their lecturers. However, I don't just work with Computer Science and Software Engineering students; Management Information Systems, Multimedia, Data Science, and others may be in my audience in any given talk. This means I must be mindful that not all students in the audience *can* code, or code at the same levels.  

If my talk must involve coding, I don't like to dictate the language. Instead I ask "What coding language/stack would you prefer me to use?". This is a relatively safe question because an overwhelming number of Computer Science courses have switched to Python over the last decade, and it is by far the most requested language from CS faculty. But for the other courses, it is a mixture. Some courses teach the languages that the lecturers are most familiar with. Some courses teach languages and stacks that the local industry needs. Some are in the process of changing, so the second and third years know one stack, but the first years have all switched to a different stack going forward.

![A stylized Python in digital art design](images/AdobeStock_607140721s.webp "Python is an industry (and academic) favorite")

## Teaching Computer Vision Labelling ML with Python

One of my favorite talks involves using [Amazon Rekognition](https://docs.aws.amazon.com/rekognition/?sc_channel=el&sc_campaign=genaiwave&sc_content=codewhisperer-for-lecturers&sc_geo=mult&sc_country=mult&sc_outcome=acq) to label images taken from an IoT camera on our farm. We have lovely hens and we certainly don't appreciate hawks trying to catch them. A motion sensitive camera can take a photo and send it for analysis on the cloud. I don't want to train a model to differentiate between the *Rhode Island Red* hens and an eagle, so I can use Amazon Rekognition to quickly check each image. To simplify the code for my short demo, the images are sourced from the current folder, not a camera, or cloud storage. The Python code is short and simple: it sends every PNG in the current folder to Amazon Rekognition and labels come back in JSON. The labels are printed out and color coded with red for a bird of prey, green for poultry, and white for neither. It's a nice demo of pre-trained ML models and calling an API. The Rekognition API can detect [3082 different labels](https://docs.aws.amazon.com/rekognition/latest/dg/samples/AmazonRekognitionLabels_v3.0.zip) so it works for many different use cases, not just hens and hawks!  

Here is the Python code for reference:

```python
# detect-birds.py
# This Python code reads in all the .jpg and/or .png files in the current directory and loops through each one.
# Each file is sent to an Amazon RekognitionClient to detect labels.
# If the labels match a hawk or buzzard, a red text label is printed out
# If the labels match a chicken or fowl, a green text label is printed out
# If the labels match neither hawks nor poultry, a white text label is printed out

# Import Amazon Rekognition for Python libraries 
import os
import boto3
# String Arrays defining birds of prey ('Hawk', 'Buzzard', 'Eagle', 'Vulture', 'Bald Eagle') and poultry birds ('Chicken', 'Fowl', 'Ducks', 'Goose', 'Poultry', 'Hen')
prey_birds = ['Hawk', 'Buzzard', 'Eagle', 'Vulture', 'Bald Eagle']
poultry = ['Chicken', 'Fowl', 'Ducks', 'Goose', 'Poultry', 'Hen']

# Create Amazon Rekognition client
rekognition = boto3.client('rekognition')

# detect_labels function, takes path to image as argument
def detect_labels(image_path):
    # Open image file for reading
    with open(image_path, 'rb') as image_file:
        image_bytes = image_file.read() 
        # Call Amazon Rekognition to detect labels in the image, max labels of 5, minimum confidence of 95%
        response = rekognition.detect_labels(Image={'Bytes': image_bytes}, MaxLabels=5, MinConfidence=95)
        # Print the labels for the detected objects, start with blue for the file name
        print ("\x1b[36m" + f"{image_path}:\t", end="")
        # For each label
        for label in response['Labels']:
            # check if it is a hawk or buzzard etc., if so print red text. (Color codes are hexadecimal ansi escape codes: red == \x1b[31m )
            if (label['Name'] in prey_birds):
                print ("\x1b[31m"+ f"{label['Name']} ({label['Confidence']:.1f})\t", end="")
            # else if it is a chicken or fowl, print green text
            elif (label['Name'] in poultry):            
                print ("\x1b[32m" + f"{label['Name']} ({label['Confidence']:.1f})\t", end="")
            else:
                print ("\x1b[37m" + f"{label['Name']} ({label['Confidence']:.1f})\t", end="")
        print() # print a new line

def main():
    # Loop through all the files in the current directory
    for file_name in os.listdir('.'):
        # If the file is a .jpg and .png file, pass it to detect_labels function
        if file_name.lower().endswith(('.jpg', '.jpeg', '.png')):
            detect_labels(file_name)

if __name__ == '__main__':
    main()
```

![Can ML tell a hawk apart from a hen?](images/AdobeStock_520205725_AdobeStock_167836824.webp "A Hawk and a Hen")

Recently, I was invited to give this ML talk to a student audience at a university I had not previously visited. The students were from 3 different degree courses but all had done a common semester (or *term*) of introductory coding. When I asked the lecturer who had invited me as to what language they would prefer, they responded that their students had only studied Java.  

Now, this was a mild surprise, but rather than insist they watch the demo in Python, there was an opportunity. Many years ago, I was a Java lecturer myself. For over a decade I taught introductory coding with Java, so surely I could easily rewrite the code in Java? Technically, I probably could; it might take some mental effort to get the Java gears in my brain turning again, but it would come back to me. And if it didn't, I'd have the stalwarts of every coder to help me, the example docs and StackOverflow! However, it would be a poor demo indeed if I were to say to students, "watch me try to remember how to code in Java". Instead I could turn to my new generative AI coding tool, **Amazon CodeWhisperer**, for help.

If you haven't tried [Amazon CodeWhisperer](https://aws.amazon.com/codewhisperer/?trk=83c710fd-0a7a-416b-9bb8-baa535b64ee0&sc_channel=el), it is an AI coding companion. It is a generative AI tool focused on suggesting code inside your IDE. There are *Individual* (free) and *Professional* (paid) [tiers](https://aws.amazon.com/codewhisperer/pricing/?trk=83c710fd-0a7a-416b-9bb8-baa535b64ee0&sc_channel=el). In this post, I'm using the free tier in Visual Studio Code via my [AWS Builder ID](https://docs.aws.amazon.com/signin/latest/userguide/sign-in-aws_builder_id.html?sc_channel=el&sc_campaign=genaiwave&sc_content=codewhisperer-for-lecturers&sc_geo=mult&sc_country=mult&sc_outcome=acq).

## CodeWhisperer to the Rescue

I've been exploring CodeWhisperer's capabilities for a while, but I hadn't tried it for the following two use cases:

1. Switching/moving/porting code from one language to another, and
1. Using Java as the target language.

CodeWhisperer supports Java (and other programming languages), but I personally hadn't had to use Java in a few years. I'll outline my approach and the developer experience, but I encourage you to experiment with CodeWhisperer yourself.  
While my use case is aimed at a lecturer in the class room, many professional developers have to 'context switch' daily. It's not uncommon for a 'full stack' developer to be working on multiple languages at once. They are expected to seamlessly move between technologies; and in a small company, they might be the only developer, so they can't specialize on one stack or aspect of the system. An AI coding companion helps with that constant context switching.

If you would like to read a detailed, step-by-step walkthrough for how I completed this, I've places it at the end of this post as an addendum at the bottom of this post.

## How CodeWhisperer Supports Language Porting

As I hadn't coded in Java on my device in several years, I needed to first set up the environment (install JDKs and Visual Studio Code extensions for Java), and create an AWS SDK Java app with Maven. As I am an 'old school' dev, I tested my setup by writing a simple Hello World program, and CodeWhisperer suggested the complete code after just typing the 'Hello World' comment. The code appears as a suggestion, similar to an auto-complete suggestion in text editors, and I can accept by pressing the `Tab` key. If no code is suggested, I can request it by pressing `ALT + c`. Finally, if the suggestion isn't exactly what I want, I can press left and right arrow keys to cycle through alternative suggestions in case one of those suits me better.  

I found the best suggestions were generated when I moved over comments from the Python code to the new Java class one-by-one, and let CodeWhisperer suggest Java implementations of that comment. Sometimes a slight editing of the comment was required, but only in a few cases. I used comments to generate the code for imports, array lists, instantiating the Rekognition client, processing image files, calling Rekognition's DetectLabels method, and printing color-coded labels.  

The experience of having a AI coding partner making suggestions takes a little getting used to, but I found it incredibly useful for reminding me of the 'Java-way' of doing certain things, and also the how it improved my efficiency immensely. Instead of writing a comment, switching to the docs or StackOverflow on how to do something in the Java world, CodeWhisperer was suggesting code that either looked right because it was reminding me of code I used to know, or looked strange because it was using new Java APIs or syntax that didn't exist the last time I used Java. I could then learn this new way of doing something in Java much quicker because it was presented in a way that directly integrated with the code I already had.  

Overall, CodeWhisperer accelerated developing the Java version by proposing code based on my comments and intent, and the previous code it had suggested.  

The final code the CodeWhisperer suggested to me:

```java
// Import Amazon Rekognition for Java libraries
import com.amazonaws.services.rekognition.AmazonRekognition;
import com.amazonaws.services.rekognition.AmazonRekognitionClientBuilder;
import com.amazonaws.services.rekognition.model.AmazonRekognitionException;
import com.amazonaws.services.rekognition.model.DetectLabelsRequest;
import com.amazonaws.services.rekognition.model.DetectLabelsResult;
import com.amazonaws.services.rekognition.model.Image;
import com.amazonaws.services.rekognition.model.Label;

import com.amazonaws.util.IOUtils;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class App {       
    // String ArraysLists defining birds of prey ('Hawk', 'Buzzard', 'Eagle', 'Vulture', 'Bald Eagle') and poultry birds ('Chicken', 'Fowl', 'Ducks', 'Goose', 'Poultry', 'Hen')
    final static ArrayList<String> birdsOfPrey = new ArrayList<>(Arrays.asList("Hawk", "Buzzard", "Eagle", "Bald Eagle"));
    final static ArrayList<String> fowl = new ArrayList<>(Arrays.asList("Chicken", "Duck", "Hen", "Rooster", "Fowl", "Poultry"));  // farm birds

    public static void main( String[] args ) throws Exception
    {       
        // Create Amazon Rekognition client                 
        AmazonRekognition rekognitionClient = AmazonRekognitionClientBuilder.defaultClient();

        // For every file in the current folder, if it's a PNG file, read the file into a byte array
        for (String photo : new File(".").list()) {
            if(photo.endsWith(".png")) {                
                ByteBuffer imageBytes;
                try (InputStream inputStream = new FileInputStream(new File(photo))) {
                    imageBytes = ByteBuffer.wrap(IOUtils.toByteArray(inputStream));
                }
                // Call Amazon Rekognition to detect labels in the image, max labels of 5, minimum confidence of 95%
                DetectLabelsRequest request = new DetectLabelsRequest()
                        .withImage(new Image().withBytes(imageBytes))
                        .withMaxLabels(5)
                        .withMinConfidence(90F);
                try {
                    DetectLabelsResult result = rekognitionClient.detectLabels(request);
                    List <Label> labels = result.getLabels();
                    // Print out each label on a single line  (Color codes are hexadecimal ansi escape codes: red == \x1b[31m )
                    // Print out the file name followed by ':' in blue
                    System.out.print("\n\033[0;36m" + photo + ": ");                    
                    
                    for (Label label: labels) {                        
                        // Set colorCode to ANSI color White
                        String colorCode = "\033[0;37m"; // White
                        // If the label is in the birds of prey arraylist, set the color to red
                        if(birdsOfPrey.contains(label.getName())) {                            
                            colorCode = "\033[0;31m"; // Red
                        }
                        else if(fowl.contains(label.getName())) {
                            // If the label is in the poultry arraylist, set the color to green
                            colorCode = "\033[0;32m"; // Green
                        }           
                        // Print out the label with the color code set above followed by confidence in brackets, rounded to 1 decimal place             
                        System.out.print("\t" + colorCode +  label.getName() + " (" + 
                            String.format("%.1f", label.getConfidence()) + ")");
                            
                    }                                                                
                } catch (AmazonRekognitionException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
```

## Prompt Based LLM Tools

Of course, if you've tried prompt based Gen AI tools, you might suggest feeding them all the code at once with the prompt "Convert this Python code into Java" or similar. This might work well in a professional development environment, but I don't recommend it to students who are starting out learning to code. It defeats the educational purposes of an academic lecture which needs to teach the students, line by line, how the syntax works. Using CodeWhisperer in a comment by comment fashion establishes the task being solved with each set of new lines generated. The lecturer can discuss the suggestion before accepting or rejecting it. This active learning approach using live-coding and explaining *why* a line of code works (or not) is the best way I've found to teach foundational coding.

## Conclusion  

Though I still needed my (rusty) Java knowledge to finalize the code, CodeWhisperer boosted my efficiency enormously. Tools like CodeWhisperer help me focus on the most meaningful part of being an educator - teaching students and spreading knowledge, not bashing my head against an IDE with syntax errors I can't decipher!  

## About the Author

Stephen is an Academic Developer Advocate at AWS, supporting students and faculty on their cloud skills journey. When not teaching, learning, or protecting his chickens, Stephen likes to read, write, and play science fiction stories with his family. The Academic Advocacy Team supports students worldwide to join the AWS Community. If you are a student who loves learning cloud technologies and would like support other students on their journey, consider becoming a Cloud Captain and launching a Cloud Club. If you are an academic who would like to discuss teaching and learning cloud and AI skills, please get in touch with Stephen.  

## Addendum: Steps to Port Python to Java  

Here are the 'hands-on' steps I followed, they will be similar depending on the languages you are porting from/to.  

### Step 1: Environment Set-up

First, I needed to get everything set-up for my Java demo. While this isn't a tutorial, I'm sharing the outline steps in case you haven't used Java on your system recently or Java with Visual Studio Code.  

1. My system didn't have a JDK installed, but that was quickly rectified by installing [Amazon Coretto](https://aws.amazon.com/corretto/?sc_channel=el&sc_campaign=genaiwave&sc_content=codewhisperer-for-lecturers&sc_geo=mult&sc_country=mult&sc_outcome=acq).
1. I installed the [Coding Pack for Java](https://code.visualstudio.com/docs/languages/java) which bundles Visual Studio code and recommended extensions.  
1. I installed [Maven](https://maven.apache.org/), my preferred Java project management and dependency tool.
1. I launched Visual Studio Code and signed into AWS Toolbox and enabled CodeWhisperer.
1. I needed to access the [AWS SDK for Java v2](https://github.com/aws/aws-sdk-java-v2) and the recommended way to use it is via a Maven *Bill of Materials* import.  
1. I created a new Java project with Maven and edited my POM.xml.  

CodeWhisperer wasn't used for the latter steps, I followed the steps from the [Using the SDK](https://github.com/aws/aws-sdk-java-v2#using-the-sdk).  

### Step 2: Porting Python code to Java with CodeWhisperer

I found the main technique for porting code was moving each comment over from the Python code, evaluate/edit the CodeWhisperer suggestions, and repeat. The following steps show the code as CodeWhisperer added to it. Each step is a new comment prompting CodeWhisperer to suggest new code.  

#### Step 2.1 Imports

The comment `# Import Amazon Rekognition for Python libraries` was slightly edited to `// Import Amazon Rekognition for Java libraries`.  
I changed the symbols indicating this line is a comment, and changed `Python` to `Java`.  
The resulting code suggestion *looked* reasonable, though I wouldn't be sure until I tried to use the libraries suggested:  

```java
import com.amazonaws.services.rekognition.AmazonRekognition;
import com.amazonaws.services.rekognition.AmazonRekognitionClientBuilder;
import com.amazonaws.services.rekognition.model.AmazonRekognitionException;
import com.amazonaws.services.rekognition.model.DetectLabelsRequest;
import com.amazonaws.services.rekognition.model.DetectLabelsResult;
import com.amazonaws.services.rekognition.model.Image;
import com.amazonaws.services.rekognition.model.Label;
```

I guessed that I might not need *all* of these, but it was probably a good starting point. A cool feature of CodeWhisperer is that when it suggests code that requires an import, it also adds the import.  

#### Step 2.2 Arrays of Poultry and Birds of Prey

The next comment was `// String ArraysLists defining birds of prey ('Hawk', 'Buzzard', 'Eagle', 'Vulture', 'Bald Eagle') and poultry birds ('Chicken', 'Fowl', 'Ducks', 'Goose', 'Poultry', 'Hen')`. I slightly modified the original comment to change Arrays to ArrayLists. This is because I prefer to use typed ArrayLists if the students have already learned simple arrays. The resulting code suggestions were exactly what I wanted, though I couldn't remember the unwieldy `Arrays.asList` syntax until CodeWhisperer suggested it.  

```java
    public static ArrayList<String> birdsOfPrey = new ArrayList<String>(Arrays.asList("Hawk", "Buzzard", "Eagle", "Vulture", "Bald Eagle"));
    public static ArrayList<String> poultryBirds = new ArrayList<String>(Arrays.asList("Chicken", "Fowl", "Ducks", "Goose", "Poultry", "Hen"));
```  

#### Step 2.3 Instantiate the Amazon Rekognition Client and Loop through Every File in the Current Folder

The comment `// Create Amazon Rekognition client` produced the expected `AmazonRekognition rekognitionClient = AmazonRekognitionClientBuilder.defaultClient();`.  
The next step could be done in a few different ways. I need to check every file in the current folder and if it's a PNG file, read the bytes (for sending to Rekognition). Java has added some nice syntax and core libraries to make this easier than the last time I coded in it, so I was curious to see what CodeWhisperer would suggest. It also added the necessary imports too. I'm omitting the final two parentheses that CodeWhisperer suggested as I need to add some more code in.

```java
// For every file in the current folder, if it's a PNG file, read the file into a byte array
for (String photo : new File(".").list()) {
        if(photo.endsWith(".png")) {                
            ByteBuffer imageBytes;
            try (InputStream inputStream = new FileInputStream(new File(photo))) {
                imageBytes = ByteBuffer.wrap(IOUtils.toByteArray(inputStream));
            }
```

#### Step 2.4 Detecting Labels in Each Photo

The comment `// Call Amazon Rekognition to detect labels in the image, max labels of 5, minimum confidence of 95%` produced:  

```java
DetectLabelsRequest request = new DetectLabelsRequest()
        .withImage(new Image().withBytes(imageBytes))
        .withMaxLabels(5)
        .withMinConfidence(90F);
try {
        DetectLabelsResult result = rekognitionClient.detectLabels(request);
        List <Label> labels = result.getLabels();
    
    } catch (AmazonRekognitionException e) {
        e.printStackTrace();
    }
```

#### Step 2.5 Print the Color-coded Labels

The final bit of code was to print out each label on a line but coded red, green, or white depending on the result. I manually added an ANSI color code to print out the labels in different colors, but once I added one, CodeWhisperer could add the rest for me. In this section, I was prescriptive with comments outlining my requirements, and CodeWhisperer might occasionally suggest a way of doing it that I didn't like (possibly too complicated for beginners or too verbose) so I could left/right arrow to see other suggestions. I had to add comments for each `else` clause I wanted, but that reinforces the iterative way of building up the code suggestion by suggestion.  

```java
// Print out each label on a single line  (Color codes are hexadecimal ansi escape codes: red == \x1b[31m )
// Print out the file name followed by ':' in blue
System.out.print("\n\033[0;36m" + photo + ": ");                    

for (Label label: labels) {                        
    // Set colorCode to ANSI color White
    String colorCode = "\033[0;37m"; // White
    // If the label is in the birds of prey arraylist, set the color to red
    if(birdsOfPrey.contains(label.getName())) {                            
        colorCode = "\033[0;31m"; // Red
    }
    else if(fowl.contains(label.getName())) {
        // If the label is in the poultry arraylist, set the color to green
        colorCode = "\033[0;32m"; // Green
    }           
    // Print out the label with the color code set above followed by confidence in brackets, rounded to 1 decimal place             
    System.out.print("\t" + colorCode +  label.getName() + " (" + 
        String.format("%.1f", label.getConfidence()) + ")");
        
}                                                                
```
