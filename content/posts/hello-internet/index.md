+++
title = 'Hello, Internet! - Designing this website'
date = 2024-06-04T04:16:48+01:00
draft = false
+++
I finally got around to rewriting my website (for the 17th or 18th time by this point), this time using Hugo and my own custom theme.
The source code for the website before this can be found [here](https://github.com/skiletro/skiletro.github.io/tree/old)! This blog post is going to outline the creation process of this site, as well as my future intentions for this blog.

## The Design Process
I used Figma to create the initial mockup of the website, using both the regular design functionality, and their FigJam board feature!
Before I even began desiging what I wanted the website to look like, I assembled a (small) collage of websites to act as inspiration.

{{<figure src="moodboard.jpg" title="The moodboard/collage created">}}

I knew I wanted to create something inspired by old websites on Geocities, and their newer counterparts on Neocities, so I am pretty happy with the handful of websites I chose to take inspiration from.
After this, I started the actual design process.
The final produced I ended up with is quite similar to the mockup, including the grainy gradient background which was initially designed in Figma, and then manually edited to reduce the filesize and (hopefully) improve performance on some browsers: it turns out Firefox really isn't really happy when you apply a 250 deviation gaussian blur on an SVG file.

{{<figure src="figmashowcase.jpg" title="Figma window showing the process, and some layers">}}

A somewhat notable part of the design process that didn't make the cut was an accent to anchor links that I thought *might* look cool.

{{<figure src="anchorshowcase.jpg" title="Some fun design I thought might work for the website">}}

The idea was that every link would have a little cursor icon next to it to show that it is clickable through the use of CSS pseudo-elements, but in practise it was quite clunky and cluttered up the page.

## Implementation
Unsure where I wanted to go with the site, and even if I wanted a blog in the first place, I decided that the best course of action was just to write it in plain HTML and CSS and go from there.
This allowed me to not worry about confirming to any particular guidelines that may be laid out had I created a theme for something like Jekyll or WordPress.
This process went very smoothly, and leads me on to part two of the implementation process: converting to a Hugo theme.

At this point, using Hugo had been on my mind for a while anyway so I thought "why not?".
Converting what I had written into a usable Hugo theme was a bit of a challenge to begin with, but using resources such as the [official documentation](https://gohugo.io/commands/hugo_new_theme/), [a blogpost by retrolog](https://retrolog.io/blog/creating-a-hugo-theme-from-scratch/), and looking at the source code of [existing themes](https://github.com/joeroe/risotto), it quickly came together. The end of this process is ending with me finishing this blog post! There are still a few things that I would like to tweak, however for now (as of the time of writing), I am happy with what I've done.

## What now?
I want to use this blog to talk about things that I find interesting, such as any unique development work that I complete, or anything else I want to yap about. As you can probably tell by this post, my writing skills aren't the best, so I would also like to use this blog as a way to further my writing skills. Thats it, I hope you stick around to see what else I talk about!