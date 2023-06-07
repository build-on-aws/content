# Content Review Checklist

Ready to submit your content for publication? Review this checklist to make sure your content is ready. Taking care of these items before submitting your content will speed up the time to review. 

Reviewers and authors should both use this checklist to ensure content meets all of the requirements to be published on the BuildOn platform. Step 1 is overall guidance and not a hard requirement, more of a strong suggestion, whereas steps 2 & 3 deal with the technical aspects that content needs to adhere to for publishing.

Community contribution are currently in an invite-only phase, and we plan to open up to the broader community in the near future.

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
  - [ ] Would the reader naturally search for this content?
  - [ ] Is this helpful and useful to the reader — and is the core question answered?
  - [ ] Does this content inspire the reader to learn, build, or experiment (even if it’s not on AWS!)?
  - [ ] Will the reader want to share this content with their network?
  - [ ] Are opinions backed up with sound reasoning and evidence?
- [ ] **Depth**:
  - [ ] **Blog posts** and **foundational content** should be at least 500 words in length, and they should sufficiently address the topic in the title and description. There is no maximum content length at this time.
  - [ ] **Tutorials** should have detailed explanations for each step, or a detailed description of *“we are going to set up X, Y, and Z, and to be able to do A, B, and C, please follow these steps.”* Remember to include the “why” to provide context, along with the “how.”
- [ ] **Errors**: Check for typos, grammatical mistakes, and misspellings - there is a workflow step that will run a spelling, grammar, and language usage check with suggestions when you open a PR. The output will be at the bottom of the PR.

## Step 2: Once you have finished reading the article, check each of the following

- [ ] **Titles**: Titles should be succinct, prioritizing action words (what is the reader *doing*) and keywords. Titles should also convey WHY the reader would want to read the article. Titles should use [Title Case](https://apastyle.apa.org/style-grammar-guidelines/capitalization/title-case) (all major words capitalized).
- [ ] **Description:** Ensure the description further explains what the content piece is about. Do not repeat the title in the description.
- [ ] **Introduction:** The first paragraph below the frontmatter is the introduction, and should not have any H heading prior to it.
- [ ] **Syntax**: All content should follow [Markdown syntax](https://www.markdownguide.org/basic-syntax/).
- [ ] **Correct directory:** Ensure that the content piece is in the correct directory and uses the correct template:
  - [ ] `/posts` for technical experiences & opinion pieces, also known as “blog style”
  - [ ] `/tutorials` for any tutorial
  - [ ] `/concepts` for any essentials, foundational, or deep-dive
  - [ ] `/code/snippets` for any code snippet
  - [ ] `/livestreams` for any livestream show or show notes
- [ ] **Tutorials:**
  - [ ] Any tutorial needs to follow the [template provided in GitHub](/templates/tutorial.md).
  - [ ] Before the conclusion, include a Clean Up section detailing how to remove any infrastructure created.
  - [ ] Include a cost estimation for per hour, and per month (using 750 hours for the calculation).
  - [ ] Indicate if any free service tiers apply, and the threshold to determine if the reader is still in that period. E.g. “We will be using a `t2.micro` instance in this tutorial, if you are still in your initial 12-month period, this will be included in the free tier.”
- [ ] **Files:** Only the `index.md` and images under the `images` directory are allowed, no other files.
- [ ] **Image formats**: Images **should not exceed 250kb** in size, 1500px in width, and 1000px in height. They should be stored in the `./images/` subdirectory of the post, in `jpg`, `png`, `webp`, or `svg` formats.
- [ ] **Image quality**: Images should be clear and helpful. They should NOT be text-only, and they must include descriptive alt-text. If images don’t work, look for alternatives from Shutterstock, Adobe Stock Photos, Pixabay, or elsewhere.
- [ ] **Image alt-text:** Images should have a detailed description as part of the alt-text to allow visually impaired people to understand what is being shown (e.g., “CodeCatalyst screen where you create a new project with the name, repo, and description filled in.”). Keep alt-text concise to under 125 characters and include the most relevant information for the image.
- [ ] **Image copyright:** Ensure you have legal permission to use the images.
- [ ] **Section headers:** Only use H2 and higher for section headers; H1 is reserved for the title.
- [ ] **Personally identifiable information:** Ensure articles do not contain personally identifiable information.
- [ ] **Code samples**: Code samples should be presented succinctly in a [Markdown code block](https://www.markdownguide.org/basic-syntax/#code-blocks-1) (with correct language for syntax highlighting). If there is a separate code repo, you can link to it. No source code files may be added added to the content repo under any circumstances.
- [ ] **Code output:** Do not add screenshots of terminal output, use a code block.
- [ ] **Keywords**: In the URL, page title, description, SEO description, first sentence, and headings, the most important keywords should be present and appropriately used. In the SEO description, include a call to action.
- [ ] **SEO Description**: Should provide a unique description of the content in less than 155 characters and include SEO keywords and a call to action. This is stored in the `seoDescription` field in the frontmatter.
  - [ ] Examples:
    - [ ] Are you a seasoned React developer? Just getting started with React? Learn more about the new library features in React 18 and how to upgrade your app.
    - [ ] Learn how to create a simple CI/CD pipeline with GitHub Actions to deploy a Flask app running in a container to infrastructure in the cloud.
- [ ] **Tags:** Tags in a post are limited to 5 that will displayed in the feed, so ensure the most important 5 are first in the list, using the `kebab-case` convention (all lowercase, with `-` between words).
- [ ] **Publication date:** Update the `date` field in the frontmatter to be the current or future date that the post will be published. Content with future dates will be published at the *next build* after that date.
- [ ] **Links:** Do not add links as raw text, e.g. `start from here https://example.com`. Instead, add them as links via `[start from here](https://example.com)`.
- [ ] **Links - relative:** To link to other content in the repo, use a relative link, not one prefixed with the full URL, e.g. `/posts/the-other-post` and not `https://buildon.aws/posts/the-other-post`.

## Step 3: Before publishing, check to make sure the post adheres to the legal rules

- [ ] **License:** Ensure author has agreed to license in the pull request body and acknowledges ownership or permission to use content including images.
- [ ] **Open Source Code of Conduct**: Ensure that content adheres to the [Amazon Open Source Code of Conduct](https://aws.github.io/code-of-conduct).
