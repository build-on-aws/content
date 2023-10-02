## Step 1: Environment Set-up

First, I needed to get everything set-up for my Java demo. While this isn't a tutorial, I'm sharing the outline steps in case you haven't used Java on your system recently or Java with Visual Studio Code.  

1. My system didn't have a JDK installed, but that was quickly rectified by installing [Amazon Coretto](https://aws.amazon.com/corretto/).
1. Next, I installed the [Coding Pack for Java](https://code.visualstudio.com/docs/languages/java) which bundles Visual Studio code and recommended extensions. I didn't need all the extensions for this demo
1. I installed [Maven](https://maven.apache.org/), my preferred Java project management and dependency tool.
1. I launched Visual Studio Code and signed into AWS Toolbox and enabled CodeWhisperer.

I wanted to check everything worked so it was time to write *Hello World*.  
This was the first time CodeWhisperer boosted my productivity!  

I created new file HelloWorld.java and added a comment `// Hello World Test` at the top. I pressed enter to move to a new line. I start to type `p` for `public` but before I can type the next letter, CodeWhisperer has proposed the following lines of code:

```java
// Hello World Test
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello World!");
    }
}
```

This is what I was intending to type, but CodeWhisperer has discerned that from my comment and suggested the code. This code looks correct, the only thing I would have done differently is remove the `!` at the end of `Hello World` - that's just a little too exuberant for me! I run the code and it prints out `Hello World!` to my console, so I know my system is set-up properly for the more advanced code.

## Step 2: Creating an AWS SDK Java App with Maven

I needed to access the [AWS SDK for Java v2](https://github.com/aws/aws-sdk-java-v2) and the recommended way to use it is via a Maven *Bill of Materials* import. I created a new Java project with Maven and edited my POM.xml. CodeWhisperer wasn't used for this part, I followed the steps from the [Using the SDK](https://github.com/aws/aws-sdk-java-v2#using-the-sdk). The command to generate a new project (on Windows using PowerShell):  
`mvn archetype:generate "-DgroupId=org.aws.devrel" "-DartifactId=DetectBirds" "-DarchetypeArtifactId=maven-archetype-quickstart" "-DarchetypeVersion=1.4" "-DinteractiveMode=false"`

Finally, I opened my new generated project in Visual Studio Code, and opened the App.java file, where Maven had placed its own Hello World sample:

```java
package org.aws.devrel;

/**
 * Hello world!
 *
 */
public class App 
{
    public static void main( String[] args )
    {
        System.out.println( "Hello World!" );
    }
}
```

Interestingly, the parenthesis placement in the code that Maven generated is *next line*, but CodeWhisperer proposed *same line* parentheses. Apart from that, the code is basically the same. This is not too surprising, as Hello World code should be fairly similar.  

## Step 3: Porting Python code to Java with CodeWhisperer

I found two main techniques for porting the code worked well:

1. Move each comment over from the Python code, evaluate/edit the CodeWhisperer suggested code, and repeat
1. Copy snippets of Python code and ask for it to be translated directly into Java

The first method worked the best in my case. The following steps show the code as CodeWhisperer added to it. Each step is a new comment prompting CodeWhisperer to suggest new code.  

## Step 3.1 Imports

The comment  
`# Import Amazon Rekognition for Python libraries` was slightly edited to `// Import Amazon Rekognition for Java libraries`. I changed the symbols indicating this line is a comment, and changed `Python` to `Java`.  
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

I guessed that I might not need *all* of these, but it was probably a good starting point. A cool feature of CodeWhisperer is that when it suggests code that requires an import, it also adds the import. This saves the ...

## Step 3.2 Arrays of Poultry and Birds of Prey

The next comment was `// String ArraysLists defining birds of prey ('Hawk', 'Buzzard', 'Eagle', 'Vulture', 'Bald Eagle') and poultry birds ('Chicken', 'Fowl', 'Ducks', 'Goose', 'Poultry', 'Hen')`. I slightly modified the original comment to change Arrays to ArrayLists. This is because I prefer to use typed ArrayLists if the students have already learned simple arrays. The resulting code suggestions were exactly what I wanted, though I couldn't remember the unwieldy `Arrays.asList` syntax until CodeWhisperer suggested it.
```java
    public static ArrayList<String> birdsOfPrey = new ArrayList<String>(Arrays.asList("Hawk", "Buzzard", "Eagle", "Vulture", "Bald Eagle"));
    public static ArrayList<String> poultryBirds = new ArrayList<String>(Arrays.asList("Chicken", "Fowl", "Ducks", "Goose", "Poultry", "Hen"));
```  

## Step 3.3 Instantiate the Amazon Rekognition Client and Loop through Every File in the Current Folder

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

## Step 3.4 Detecting Labels in Each Photo

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

## Step 3.5 Print the Color-coded Labels

The final bit of code was to print out each label on a line but coded red, green, or white depending on the result. I manually added an ANSI color code to print out the labels in different colors, but once I added one, CodeWhisperer could add the rest for me. In this section, I was prescriptive with comments outlining my requirements, and CodeWhisperer might occasionally suggest a way of doing it that I didn't like (possibly too complicated for beginners or too verbose) so I could left/right arrow to see other suggestions.  

```java
/// Print out each label on a single line  (Color codes are hexadecimal ansi escape codes: red == \x1b[31m )
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
