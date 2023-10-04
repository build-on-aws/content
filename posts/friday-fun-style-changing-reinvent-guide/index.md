---
title: "Fun on a Friday with Prompt Engineering and thinking about re:Invent 2023"
description: "Prithee, kind attendees of the grand assembly of AWS re:Invent, heed this counsel for a prosperous sojourn. Don attire that grants thee comfort for thy feet, as the day is long and filled with much ambulation."
tags:
    - gen-ai
    - reinvent
    - prompt-engineering
    - bedrock
authorGithubAlias: cobusbernard
authorName: Cobus Bernard
date: 2023-09-29
images:
    thumbnail: ./images/pirate.jpeg
---
|ToC|
|---|

Friday. 13:44. Been a busy week, and I'm trying to finish off my last admin tasks. Instead, I decide to have a bit of fun. [re:Invent](https://reinvent.awsevents.com/) is just around the corner, and we're currently in what is affectionately called "pre:Invent season". Due to this, I started reading some guides people have written in the past with tips & tricks to help others get the most out of the event. I've only been to re:Invent twice so far, with vastly different experiences. First time as a customer in 2018, and last year, as an employee. The main difference for me was a 2h flight with zero timezone changes, versus my previous ~23h flights, and a 9h time difference. For context, I moved from Cape Town, South Africa to Seattle at the end of 2021.

Luckily, I will have the same 2h flight this year, and when I went searching for guides to read, I saw multiple pages of results, so I won't even try to write a new one. Instead, I'm going to have some fun and try to make them more interesting. Since generative AI and large language models (LLMs) are all the rage right now, I wanted to test out how they perform with changing the style and tone of content. I've dabbled a bit with this as part of trying to build out a style guide before, and using the LLMs to validate if content adheres to it, but that was serious work with no room for making jokes. So here we are.

I found this [AWS Blog post](https://aws.amazon.com/blogs/industries/ready-set-reinvent-how-to-prepare-for-aws-reinvent-2022/?sc_channel=el&sc_campaign=genaiwave&sc_content=friday-fun-style-changing-reinvent-guide&sc_geo=mult&sc_country=mult&sc_outcome=acq) from last year, and at the bottom, it has a nice list of bullet points to make the most out of re:Invent. I decided to use this list as the input data to modify the style using my prompts, and then proceeded to test out the styles & formats with a few different models using [Amazon Bedrock]. Just to avoid any confusion, the responses below contain the generated text after providing the prompts and those bullet points.

## Attempt 1: Change the style

For the first set of experiments, I focussed on changing the style, and boy, did it deliver.

![A book with Shakespeare written on the spine.](./images/shakespeare.jpeg "I am not bound to please thee with my answer. - The Merchant of Venice")

### Indeed, fair requester, prepare thine ears for a narrative of AWS re:Invent, woven with the gravity of epochs past

**The first prompt I used was:**

*Using the following text, can you please change the style to be 16th century English, and make it more dramatic by comparing mistakes you could make with historical events prior to the 17th century?*

**The response:**

*Prepare to embark upon an odyssey, as grand as that of yore, whilst navigating the exalted corridors of AWS re:Invent. Let me impart unto thee words of counsel, steeped in ancient lore, to ensure that thy journey resembles not the tragic missteps of bygone eras.*

***1. Customize thy pilgrimage with the mobile app.***<br>
*Just as mariners of old relied upon their astrolabes and charts, let the AWS Events mobile app be thy guiding star. Navigate the seas of sessions, chart thy course, heed timely missives, and acquaint thyself with the vast terrains of the re:Invent realm.*

***2. Adorn thy feet with steadfast footwear.***<br>
*The perils of the Bataan Death March await those ill-equipped. The vastness of re:Invent, akin to the treks of olden pilgrimages, requires footwear both sturdy and comfortable. Tread wisely, lest thou find thyself lamenting like Caesar after his tragic crossing of the Rubicon.*

***3. Compute thy passage from one domain to another.***<br>
*Remember the vastness of Xerxes' Persian Empire, and how it took messengers days to traverse. The re:Invent domain, spanning six grand halls, demands careful consideration of the time between one's engagements, be it on foot or aboard the modern-day carriages.*

***4. Miss not the grand sessions – chart thy schedule aforetime.***<br>
*Ere you find yourself in a predicament akin to Hannibal at the gates of Rome without adequate preparation, plan thy ventures. Seats in these gatherings are as coveted as places at King Arthur's Round Table. Arrive with promptness, for, like the fleeting grains of an hourglass, they are claimed swiftly.*

***5. A novice to the world of the Cloud? Seek ye foundational knowledge.***<br>
*Much like young squires in the days of knighthood, approach with humility. Drown not in the depths of advanced discourse, but begin with the rudiments, much as one would learn the art of the blade before challenging a seasoned knight.*

***6. Seek further enlightenment at the Grand Expo.***<br>
*In a manner reminiscent of Marco Polo's tales of the Orient, the Expo at The Venetian offers treasures manifold. Engage with the sagely AWS denizens, delve into the Marketplace's wonders, and behold the tapestries of success woven by partners in the AWS Partner Network Booth.*

***7. Revel with us at the grand fest of re:Play.***<br>
*After days of intense enlightenment, reminiscent of the weary Crusaders longing for respite, partake in the grand celebration that is re:Play. Lose thyself in harmonious melodies, or should thy heart desire, engage in games as fierce and thrilling as the ancient gladiatorial combats.*

***8. But above all, revel in merriment and joy!***<br>
*Much as the courts of yore bubbled with jubilation during grand feasts, let thy spirit be light and cheerful. Connect, engage, and celebrate the rare confluence of minds and mirth. Embrace the splendour of Las Vegas, and let the essence of re:Invent infuse your soul with glee.*

*With these words, I bid thee embark on this grand journey, armed with wisdom and ready to seize the boundless opportunities that lie ahead at AWS re:Invent.*

### With a heart full o' rum and adventure, set forth on this grand escapade through AWS re:Invent

Ok, I did not expect it to be this good / bad, but that was quite good in my opinion. Next, me matey, let's see if it survives another day, or if it will be walking the plank!

![Pirate with a knife in their mouth typing on a laptop](./images/pirate.jpeg "How the pirate-speak LLM works behind the scenes to provide you with these tips.")

**Prompt:**
*Using the following text, can you please change the style to be in over-the-top pirate speak and more dramatic?*

**Response:**

*Ahoy there, matey! Set sail on this swashbucklin' journey through the vast seas of AWS re:Invent, and take heed of these tips from this old sea dog, lest ye find yerself lost at sea or worse, marooned!*

***1. Customize yer voyage with the mobile app.***<br>
*Avast! If yer trusty compass be the key to the open seas, then the AWS Events mobile app be the very chart ye need to navigate the treacherous waters of re:Invent. Plunder sessions, mark yer treasure spots, and keep an eye out for parley updates, all whilst getting the lay o' the land!*

***2. Strap on yer trusty sea boots.***<br>
*Argh! Ye wouldn't set foot on a ship's deck with wobbly legs, now would ya? The vast decks of re:Invent be no different. Make sure ye have shoes fit for a pirate king, so ye can swagger from bow to stern without a hitch!*

***3. Reckon the tides when sailin' from one port to the next.***<br>
*Yarr! Remember, mate, the re:Invent ship spans across six harbors! Whether ye be hoofin' it or hitchin' a ride on a scallywag's shuttle, best know how long ye be sailin' before ye weigh anchor.*

***4. Don't be missin' any tales of adventure – chart yer course ahead o' time.***<br>
*Don't be caught off guard like Blackbeard at Ocracoke Inlet! Plan yer escapades. Seats be as rare as a mermaid's tear, so be there afore the other buccaneers to secure a spot to hear the yarns.*

***5. Green to the Cloudy seas or AWS? Start with the tales of old.***<br>
*If ye be a greenhorn to the vast Cloudy Ocean or AWS, fret not! Instead of diving headfirst into the Kraken’s lair, start with the legends of old and familiar tales, then build up to the epics.*

***6. Dock at the Expo for treasures galore!***<br>
*Hoist the Jolly Roger and head to the Expo at The Venetian! Dive into the AWS Lagoon, plunder knowledge from the wise sea witches and wizards, then seek out the mystical artifacts at the AWS Marketplace. And don't forget to swap tales with fellow sea dogs at the AWS Partner Network Booth.*

***7. Party like a pirate at re:Play!***<br>
*If ye still have some rum left in yer belly after sailin' the high seas of knowledge, join the grand shindig that be re:Play. Dance a jig to the fiddlers, or if ye fancy a challenge, try yer hand at a game of cannonball dodge or archery on the poop deck.*

***8. But mark me words, have a rollickin' good time!***<br>
*Whether ye be spinning yarns with an old shipmate or challengin' a new rival to a duel, re:Invent be a chance like no other! So hoist yer flag, raise a toast, and make the most of yer time at this grand fleet gathering.*

Apologies to all the spell checkers out there, this one will trigger a bunch!

## Attempt 2: Change the format

Next up, I wanted to see how good LLMs are at changing the format, and again, I was not disappointed!

### Certainly! Let's navigate AWS re:Invent through the lyrical avenues of poetry

**For the first prompt, I used:**

*Using the following text, can you please change the style and rewrite it as a poem that is more dramatic?*

**Response:**

*In the vast digital domain, where the Clouds hold sway,*<br>
*AWS re:Invent beckons, guiding our way.*

*With the mobile app's gleam, our journey we chart,*<br>
*Mapping sessions and dreams, where tech and art depart.*

In shoes snug and steady, we tread the vast floor,*<br>
*From session to session, always craving more.*

*The expansive grounds, over six venues they spread,*<br>
*We calculate each move, with foresight we tread.

*Sessions aplenty, choices galore,*<br>
*Plan in advance, for knowledge to store.*

*If new to the Cloud's vast shimmering sky,*<br>
*Begin with basics, then let your aspirations fly.

*The Expo stands grand, a beacon of might,*<br>
*With AWS mavens and tools to ignite.*

*As day turns to dusk, at re:Play we unite,*<br>
*With melodies and games, dancing in the night.*

*But beyond tech and tools, amidst the bright fun,*<br>
*Connect, learn, and grow, 'til the event is done.*

Doubt this will pluck anyone's heartstrings, but good rhythm and rhyme.

### Throw your hands up, from dawn to dusk, At AWS re:Invent, innovation's a must!

I was introduced to "Nerd Core" with a video of Seth Vargo doing a rap about tech years and years ago, and it caught me by surprise as I had never considered this combination of style for technical content! So off we go, let's see how we can make these tips & tricks more entertaining!

**Prompt:**

*Using the following text, can you rewrite it as a rap song please?*

**And the response:**

*Roll up to re:Invent, got my app on hand,*
*Navigating sessions, best in the land.*
*Comfy shoes on my feet, I'm ready to go,*
*From one venue to the next, keepin' up with the flow.*

*Across six venues, gotta calculate the time,*
*Every move, every step, gotta make it rhyme.*
*Sessions lined up, ain't missing a beat,*
*From intro to advanced, I'm stayin' elite.*

*AWS, re:Invent, we risin' above,*
*Tech and dreams blend, push comes to shove.*
*Connect, learn, play, it's more than just code,*
*In the heart of Vegas, we on success mode.*

*Expo's the place, deep diving the scene,*
*AWS experts around, their insights so keen.*
*Marketplace buzzin', solutions in sight,*
*Partner stories inspiring, shining so bright.*

*As the day winds down, re:Play's where it's at,*
*Beats droppin', DJ's spinnin', wear your party hat.*
*But remember the essence, in all that you do,*
*It's about coming together, the old and the new.*

*AWS, re:Invent, we risin' above,*
*Tech and dreams blend, push comes to shove.*
*Connect, learn, play, it's more than just code,*
*In the heart of Vegas, we on success mode.*

*New to the cloud? Start slow, no rush,*
*Mix it up, feel the vibe, feel the hush.*
*Deepen connections, forge the way,*
*This ain't just an event, it's a new day.*

*AWS, re:Invent, we risin' above,*
*Tech and dreams blend, push comes to shove.*
*Connect, learn, play, it's more than just code,*
*In the heart of Vegas, we on success mode.*

## Attempt 3: Extend the content

Now that we've dropped the mic, let's look at something more real-world. Using generative AI to augment content is where I find the most value - to see if I missed any important points that I should include. I don't want it to write for me, just help me improve my writing. With this in mind, I asked the following:

*Are there any additional tips you would give while attending re:Invent based on the previous input points?*

**Response:**

***1. Stay Hydrated and Eat Well.***<br>
*Las Vegas can be quite dry, so carry a refillable water bottle. Plus, with so many sessions and activities, it's easy to skip meals. Make sure to fuel up with a good breakfast, and grab a healthy snack when you can.*

***Network and Connect.***<br>
*Beyond sessions, re:Invent offers ample opportunities for networking. Bring plenty of business cards, and don't be shy about introducing yourself. The connections you make could lead to future collaborations or job opportunities.*

***Utilize Quiet Zones.***<br>
*With all the hustle and bustle, you might need a moment to relax and recharge. Look out for designated quiet zones to take a breather or review your notes.*

***Take Advantage of Hands-on Labs.***<br>
*These are self-paced technical training sessions that allow you to get hands-on practice with AWS services and solutions. If you're keen to experiment, don't miss these.*

***Backup Power is a Savior.***<br>
*With heavy app usage, note-taking, and social media updates, your devices can run out of juice quickly. Carry a portable charger or power bank to stay connected.*

***Engage on Social Media.***<br>
*Using the event hashtag (e.g., #reInvent) can keep you updated on any last-minute changes, popular sessions, or impromptu meetups. Plus, it's a great way to share your insights and learn from others.*

***Remember Your Well-being.***<br>
*Between sessions, it's essential to stretch your legs, get some fresh air, and perhaps even meditate for a few minutes. This will help keep your energy levels up and your mind alert.*

***Consider Post-Event Workshops.***<br>
*Some workshops or extended sessions might happen a day after the primary event. Look into these for deep dives into specific topics.*

## Conclusion

While these attempts were purely for my entertainment, I have found LLMs also useful to help with crafting response emails, especially ones where I need to tone things down a bit, or to more clearly communicate the finer points of a nuanced, complex idea. If you are just getting started, take a look at the [ABCs of Generative AI](/posts/the-abcs-of-generative-ai), and have a look at [this curated collection](/generative-ai) of content. Now I'm off to update to MacOS 13.6 before logging off for the week, and remember folks: be polite to your helpful assistants by saying "please" and "thank you", even though they tell you they don't have feelings if you ask them!
