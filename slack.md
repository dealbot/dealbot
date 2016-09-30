---
layout: default
title: Slack setup
order: c
body_id: slack
---
{::options parse_block_html="true" /}

<section id="intro">
# Setting up Slack and other messaging apps

Dealbot can control cadences and report activity on Slack and other messaging platforms.

Jump to: [About the Slack integration](#about-the-slack-integration), [Commands](#commands), [How to set up Slack](#how-to-set-up-slack), [Other messaging platforms](#other-messaging-platforms)
{: .jump}
</section>

<section>
## About the Slack integration

  <div>
This is an **optional** feature for Dealbot that allows you to "snooze" and "abort" cadences on deals by sending messages in Slack and other messaging platforms. For example:

```
/dealbot snooze 123 3
```

That would snooze Deal #123 by 3 days: any incomplete cadence steps have their dates pushed back by 3 business days.

When configured, Dealbot will also notify a Slack channel you choose when a Deal is enrolled in a cadence.
  </div>
</section>

<section>
## Commands

  <div>

Dealbot currently supports two commands from Slack and other messaging platforms:

* **`snooze <Deal ID> <number of business days>`** — Take any *incomplete* cadence Activities on the Deal and push them back by a number of business days. Useful if you take a vacation or get jammed up.

* **`abort <Deal ID> <trigger/cadence identifier>`** — Delete any incomplete cadence Activites on the Deal. Identify the trigger/cadence with `trigger_name/cadence_name` or `trigger_name/` if you don't know/care which cadence was selected. If you're using this command a lot, it may be a sign that you have not set up your cadence abandonment conditions. See [Configuration](/configuration) for more on that.

Have an idea for a new command? Let us know!

  </div>
</section>

<section>
## How to set up Slack

  <div>

### Set up the `/dealbot` command

1. Find the Slack section your Dealbot setup page and copy the webhook URL you find there.

1. Go to the [create new slash command](https://slack.com/apps/new/A0F82E8CA) page on Slack. Fill out the fields like so:
  * **Command:** `/dealbot` (or whatever you'd like!)
  * **URL:** paste the webhook URL you copied
  * **Method:** POST
  * **Customize name:** `Dealbot`
  * **Customize icon:** [Here's one you can use!](https://cdn.rawgit.com/dealbot/dealbot/gh-pages/assets/dealbot-totem.png)

1. Try it! Get the ID of a Deal on Pipedrive that's had a cadence applied and in Slack say: `/dealbot snooze <ID> 1` for a 1-day snooze.

### Create an incoming webhook

1. Go to the [create new incoming webhook](https://slack.com/apps/new/A0F7XDUAZ-incoming-webhooks) page on Slack. Choose a channel for the notifications and hit the "Add" button.

1. Scroll down to the "Integration Settings" section and:
  * **Webhook URL**: Hit the "Copy URL" link to put this URL in your clipboard—we'll need it later
  * **Descriptive Label**: Use `Dealbot`
  * **Customize Name**: Use `Dealbot`
  * **Customize Icon**: [Here's one you can use!](https://cdn.rawgit.com/dealbot/dealbot/gh-pages/assets/dealbot-totem.png)

1. After hitting "Save Settings" go to your [Heroku dashboard](https://dashboard.heroku.com/apps) and find your Dealbot instance.

1. Go to the Settings tab and click the "Reveal Config Vars" button.

1. At the bottom of the list of config vars, there's an empty row to add a new config var. Use:
  * **KEY**: `SLACK_INCOMING_WEBHOOK_URL`
  * **VALUE**: Paste the URL you copied in step 2

1. Click "Add" to register the config var, wait a minute or two for Heroku to restart your Dealbot, and test it out!

  </div>
</section>

<section>
## Other messaging platforms

  <div>

You can use other messaging and bot platforms to send snooze and abort commands to Dealbot.

* Use the webhook URL from the Slack section on your Dealbot's setup page.

* Make sure your platform will POST JSON to Dealbot's webhook URL. Dealbot will look for a top-level `text`, `message`, or `body` key, in that order. The value should be the complete command—Dealbot will tolerate prefixes like `@dealbot: ` if your messenger of choice includes that.

If you use Dealbot with a messaging platform other than Slack, please let us know so we can write docs for it!

  </div>
</section>

