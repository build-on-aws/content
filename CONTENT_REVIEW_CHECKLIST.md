# Content Review Checklist

Reviewers and authors should both use this checklist to ensure content meets all of the requirements to be published on the BuildOn platform.  

## Step 1: Read the whole article and review it for

- [ ] **Clarity**: Prioritize clarity and simplicity over a distinctive voice.
  - [ ] Use short sentences and short paragraphs, ideally with 2-3 sentences each.
  - [ ] Use headers to introduce sections and to enable the reader to scan the content.
  - [ ] Break up large blocks of text with subheadings, bullet points, and numbered lists.
  - [ ] Emphasize important points using bold, italics, or underlining.
  - [ ] Add relevant images, videos, or infographics to support and illustrate the content.
- [ ] **Style:** Style should be conversational, educational, and opinionated. It should NOT be sales-y.
  - [ ] Would you read this piece?
  - [ ] Does this piece sound like it was written by a human?
  - [ ]  Would the reader naturally search for this content?
  - [ ] Is this helpful and useful to the reader — and is the core question answered?
  - [ ] Does this content inspire the reader to learn, build, or experiment (even if it’s not on AWS!)?
  - [ ]  Will the reader want to share this content with their network?
  - [ ] Are opinions backed up with sound reasoning and evidence?
- [ ] **Depth**:
  - [ ] **Blog posts** and **foundational content** should be at least 500 words in length, and they should sufficiently address the topic in the title and description. There is no maximum content length at this time.
  - [ ] **Tutorials** should have detailed explanations for each step, or a detailed description of *“we are going to set up X, Y, and Z, and to be able to do A, B, and C, please follow these steps.”* Remember to include the “why” to provide context, along with the “how.”
- [ ] **Errors**: Check for typos, grammatical mistakes, and misspellings. Please make use of the [Style Guide](https://github.com/build-on-aws/style-guide) to run checks on the content as part of the review.

## Step 2: Once you have finished reading the article, check each of the following

- [ ] **Titles**: Titles should be succinct, prioritizing action words (what is the reader *doing*) and keywords. Titles should also convey WHY the reader would want to read the article. Titles should use [Title Case](https://apastyle.apa.org/style-grammar-guidelines/capitalization/title-case) (all major words capitalized).
- [ ] **Description:** Ensure the description further explains what the content piece is about. Do not repeat the title in the description.
- [ ] **Introduction:** The first paragraph below the frontmatter is the introduction, and should not have any H heading prior to it.
- [ ] **Syntax**: All content should follow [Markdown syntax](https://www.markdownguide.org/basic-syntax/).
- [ ] **Correct directory:** Ensure that the content piece is in the correct directory and uses the correct template:
  - [ ] `/posts` for technical experiences & opinion pieces, also known as “blog stye”
  - [ ] `/tutorials` for any tutorial
  - [ ] `/concepts` for any essentials, foundational, or deep-dive
  - [ ] `/code/snippets` for any code snippet
  - [ ] `/livestreams` for any livestream show or show notes
- [ ] **Tutorials:**
  - [ ] Any tutorial needs to follow the [template provided in GitHub](https://github.com/build-on-aws/content/blob/main/templates/tutorial.md).
  - [ ] Before the conclusion, include a Clean Up section detailing how to remove any infrastructure created.
  - [ ] Include a cost estimation for per hour, and per month (using 750 hours for the calculation).
  - [ ] Indicate if any free service tiers apply, and the threshold to determine if the reader is still in that period. E.g. “We will be using a `t2.micro` instance in this tutorial, if you are still in your initial 12-month period, this will be included in the free tier.”
- [ ] **Files:** Only the `index.md` and images under the `images` directory are allowed, no other files.
- [ ] **Image formats**: Images **should not exceed 250kb** in size, 1500px in width, and 1000px in height. They should be stored in the `./images/` subdirectory of the post, in jpg, png, webp, or svg formats.
- [ ] **Image quality**: Images should be clear and helpful. They should NOT be text-only, and they must include descriptive alt-text. If images don’t work, suggest alternatives from [Shutterstock](https://www.shutterstock.com/), [Adobe Stock Photos](https://stock.adobe.com/), [Freeway](https://freeway.amazon.com/), or elsewhere.
- [ ] **Image alt-text:** Images should have a detailed description as part of the alt-text to allow visually impaired people to understand what is being shown (e.g., “CodeCatalyst screen where you create a new project with the name, repo, and description filled in.”). Keep alt-text concise to under 125 characters and include the most relevant information for the image.
- [ ] **Image copyright:** Ensure you have permission to use the images as described in the [Marketing Dos/Don’ts](https://pathfinder.legal.amazon.dev/#/page/AWSLegalSalesandMarketing-MarketingandPublicRelations-MarketingDosandDontsandReviewofMarketing/live). Not all open source licenses allow for corporate use.
- [ ] **Section headers:** Only use H2 and higher for section headers; H1 is reserved for the title.
- [ ] **Personally identifiable information:** Ensure articles do not contain personally identifiable information. Content can use fictitious examples [here](https://alpha.www.docs.aws.a2z.com/awsstyleguide/latest/styleguide/safenames.html).
- [ ] **Code samples**: Code samples should be presented succinctly in a [Markdown code block](https://www.markdownguide.org/basic-syntax/#code-blocks-1) (with correct language for syntax highlighting). If there is a separate code repo, you can link to it. For any AWS employee authored samples, please follow the [repo publishing process](https://w.amazon.com/bin/view/AWS/Hands-On_Builders_Hub/Content/Code_Samples/). No source code files may be added added to the content repo under any circumstances.
- [ ] **Code output:** Do not add screenshots of terminal output, use a code block.
- [ ] **Keywords**: In the URL, page title, description, SEO description, first sentence, and headings, the most important keywords should be present and appropriately used. In the SEO description, include a call to action.
- [ ] **SEO Description**: Should provide a unique description of the content in less than 155 characters and include SEO keywords and a call to action. This is stored in the `seoDescription` field in the frontmatter.
  - [ ] Examples:
    - [ ] Are you a seasoned React developer? Just getting started with React? Learn more about the new library features in React 18 and how to upgrade your app.
    - [ ] Learn how to create a simple CI/CD pipeline with GitHub Actions to deploy a Flask app running in a container to infrastructure in the cloud.
- [ ] **Tags:** Tags in a post are limited to 5 that will displayed in the feed, so ensure the most important 5 are first in the list, using the `kebab-case` convention (all lowercase, with `-` between words).
- [ ] **Tags:** Use tags from the  [official AWS tagging taxonomy](https://w.amazon.com/bin/view/AWS_Marketing/AWS_Marketing_Website/PlatformAndTools/Directories/Tags). If a tag is not found in the official AWS tagging taxonomy, select one from the [BuildOn Content Marketing Tagging](https://quip-amazon.com/lVsOAdNZuvZ6) list.
- [ ] **Publication date:** Update the `date` field in the frontmatter to be the current or future date that the post will be published. Content with future dates will be published at the *next build* after that date.
- [ ] **Links:** Do not add links as raw text, e.g. `start from here https://example.com`. Instead, add them as links via `[start from here](https://example.com)`.
- [ ] **Links - relative**: To link to other content in the repo, use a relative link, not one prefixed with the full URL, e.g. `/posts/the-other-post` and not `https://buildon.aws/posts/the-other-post`.
- [ ] **Links to AWS services:** When linking to AWS services, do not link to the product description pages (PDP), e.g. [CodeCatalyst](https://aws.amazon.com/codecatalyst/)(https://aws.amazon.com/codecatalyst/), rather link to the documentation page, e.g. [CodeCatalyst](https://docs.aws.amazon.com/codecatalyst/latest/userguide/welcome.html)(https://docs.aws.amazon.com/codecatalyst/latest/userguide/welcome.html). All links to AWS sites should have the tracking parameters attached to them with the following values:
  - [ ] `sc_channel=el`
  - [ ] `sc_geo=mult`
  - [ ] `sc_country=multsc`
  - [ ] `outcome=acq`
  - [ ] `sc_campaign=devopswave` - replace `devopswave` with the appropriate wave string
  - [ ] `sc_content=mwaa_env_wrkflw`  - replace `mwaa_env_wrkflw` with the directory name of the post

The end result should be combined into a URL query string after the link, e.g., `https://docs.aws.amazon.com/codecatalyst/latest/userguide/welcome.html?sc_channel=el&sc_geo=mult&sc_country=mult&sc_outcome=acq&sc_campaign=devopswave&sc_content=mwaa_env_wrkflw`

- [ ] **Product and service names:** The first use of service names can be the shortened version of the service name paired with “AWS” or “Amazon,” as defined [here](https://w.amazon.com/bin/view/AWSDocs/editing/service-names/#HI). Subsequent uses will follow the same subsequent use rule as documented [here](https://w.amazon.com/bin/view/AWSDocs/editing/service-names/#HI). As an example, “Amazon S3” would come first, followed by “S3.” See the [DevRel-modified rules](https://quip-amazon.com/wfoOAUZ6fkwc#eFE9BA4zQkv) for AWS product and service names for more details.
- [ ] **Product and service descriptions:** Marketing messaging is not copied from AWS product and service pages, but is instead paraphrased, using more technical language or a conversational style that resonates with builders. See the [DevRel-modified rules](https://quip-amazon.com/wfoOAUZ6fkwc#eFE9BA4zQkv)for AWS product and service descriptions for more details.
- [ ] **Competitor mentions and service comparisons:** Mentioning competitors and comparing one AWS service to other services is allowed, but should not imply that one is better than the other. Competitors should not be at the center of the message. Ensure the tone is around the existence of options and helps people understand their choices, giving the reader balanced information about each in order to make an informed decision or solve a problem.
  - [ ] ***Note: Content referencing competitors needs to be reviewed by the Legal team before publication. Work directly with nikkimc@ or cherbk@ to coordinate this.***

## Step 3: Before publishing, check to make sure the post adheres to the legal rules:

- [ ] **License:** Ensure author has agreed to license in the pull request body and acknowledges ownership or permission to use content including images.
- [ ] **Open Source Code of Conduct**: Ensure that content adheres to the [Amazon Open Source Code of Conduct](https://aws.github.io/code-of-conduct).
