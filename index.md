---
layout: default
title: Getting started
order: a
body_id: home
---
{::options parse_block_html="true" /}

<section id="intro">
# Free, lightweight, open-source sales automation for Pipedrive

From your friends at [Faraday](http://faraday.io)
</section>

<section class="question">
## What does Dealbot do?

* Watches for Deals entering certain pipeline stages
* Applies a configurable series of Activities (a "cadence") to those Deals
* Removes incomplete cadence Activities when the Deal progresses past a definable finish line
</section>

<section class="question">
## Any other special tricks?

* [Snooze and abort cadences](/slack) from Slack, FlowXO, and other messaging tools
* [Report cadence enrollments](/slack) to Slack
* Manage and apply multiple cadences for different situations: sales development, closing, customer success, even internal project management
</section>

<section class="question">
## What do I need?

* A [Pipedrive](https://pipedrive.com/taf/faraday1) account you love
* A free [Heroku](http://heroku.com) account
* About 15 minutes and some moderate technical ability to get things set up
</section>

<section class="question">
## OK, how do I get started?

1. Use this magic button to add a private instance of Dealbot to your Heroku account: <br /><br />[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/dealbot/dealbot)

2. The deploy process may ask you to log in to your Heroku account. Note that while Dealbot is designed to run in Heroku's free usage tier, **you must have a credit card on file** with Heroku to deploy Dealbot.

3. Fill out the required config fields and click "Deploy for Free." **Don't close the window!** You'll get an email telling you what to do next.
</section>

<section class="question">
## How do I uninstall?

1. Go to **Settings → Push notifications** and delete the two Dealbot-related entries you'll find there.

2. That's it! You can also delete your Dealbot instance on Heroku and remove Dealbot's custom field in your Pipedrive settings, but it's best to keep those around in case you change your mind.

3. If you do change your mind, just go back to your Dealbot's setup page and it will fix itself back up.
</section>