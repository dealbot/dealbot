---
layout: default
title: Configuration
order: b
body_id: configuration
---
{::options parse_block_html="true" /}

<section id="intro">
# Configuring your Dealbot

Welcome to the family! Below you'll learn how to define cadences and triggers in order to make your Dealbot start working.

Jump to: [Configuration basics](#configuration-basics), [Defining triggers](#defining-triggers), [Custom cadences](#custom-cadences), [Sample configuration](#sample-configuration)
{: .jump}
</section>

<section>
## Configuration basics

  <div>
### Where your config lives

Your configuration is stored in an *environment variable* (`DEALBOT_CONFIG`) on your Dealbot server, which is probably over at Heroku.

### How to edit your configuration

* Go to your Heroku dashboard and find your Dealbot instance

* Choose the "Settings" tab and click the "Reveal" button

* Click the pencil icon next to the `DEALBOT_CONFIG` config var

### Format and structure

Dealbot configuration is in [YAML](http://yaml.org/) format. The overall structure looks something like this:

```yaml
company: ...
triggers:
  ...
cadences:
  ...
```

All of these sections are optional. In fact, a blank configuration is totally valid! But Dealbot won't do much of anything until you at least establish your first trigger.
  </div>
</section>

<section>
## Defining triggers

  <div>
In this section we're going to focus on the most important part of the Dealbot config: triggers.

Let's look at a complete `triggers` section and break it down from there:

```yaml
# snip
triggers:
  sdr:
    enroll:
      pipeline: 1
      stage: 2
    cadences:
      - 7x7
# snip
```

OK, under the `triggers` heading we can define multiple triggers. In this example, we've only defined one: `sdr` — this is a "handle" for the trigger and must consist of *letters, numbers, dashes, and underscores*.

### Enrolling

Within the `sdr` trigger, we have one `enroll` section that defines the "triggering" event. In this example, whenever a Deal enters Stage 2 of Pipeline 1 in your Pipedrive account, `sdr` will trigger.

Wait, how do you know the IDs of your Pipelines and Stages? That's an easy one. Just go to **Settings → Pipelines**. Click on the tab corresponding to the Pipeline you want and look at the end of the URL: there's your Pipeline ID. Now hover your cursor over the Stage you want and look at the end of the corresponding URL: that's your Stage ID.

### Cadences

Now you have to configure which cadence gets applied when the trigger happens. Refer to your cadence by its "handle" — again: letters, numbers, dashes, and underscores only. You have two options for referencing a cadence:

1. First, Dealbot will look elsewhere in your configuration to see if you've defined a custom cadence with this handle. The section on custom cadences below explains all that.

2. If no match is found, Dealbot will look in the [Dealbot Cadence Library](https://github.com/dealbot/cadences) for this cadence.

### Multiple cadences

One important thing to remember is that Dealbot will only ever apply **one** cadence to a Deal for a given trigger. The reason that you're invited to list *multiple* cadences for a trigger is that Dealbot will pick one at random when enrolling a Deal. This lets you A/B test different cadences against each other to find which work best.

You can also assign a `weight` parameter to any or all of your listed cadences if you want certain options to be randomly selected more often. For example:

```yaml
# snip
triggers:
  sdr:
    enroll:
      pipeline: 1
      stage: 2
    cadences:
      - 7x7
      - 5x12: 2
# snip
```

In this case, the `5x12` cadence will be randomly selected twice as often as the `7x7` cadence.

### Abandonment

If you've been following along, you may have noticed there's something important missing: the finish line. When using a cadence to guide outreach, there is generally an event that would cause you to abort the cadence: for example, moving the deal to negotiation!

Dealbot lets you define this event with the `abandon` option. For example:

```yaml
# snip
triggers:
  sdr:
    enroll:
      pipeline: 1
      stage: 2
    cadences:
      - 7x7
      - 5x12: 2
    abandon:
      pipeline: 1
      stage: 4
# snip
```

### Multiple triggers

Finally, remember that Dealbot can be used for different workflows throughout your organization. The above example focuses on a common use case: B2B sales development performed by SDRs. At [Faraday](http://faraday.io), we use Dealbot for all kinds of repeatable outreach flows, including, for example, our post-onboarding Customer Success communications:

```yaml
# snip
triggers:
  sdr:
    enroll:
      pipeline: 1
      stage: 2
    cadences:
      - 7x7
      - 5x12: 2
    abandon:
      pipeline: 1
      stage: 4
  post-onboard:
    enroll:
      pipeline: 3
      stage: 2
    cadences:
      - new-account
# snip
```

Anytime an customer or other contact (represented by a Deal) needs systematic outreach triggered by some event, Dealbot can help queue things up so that nothing falls through the cracks.
  </div>
</section>

<section>
## Custom cadences

  <div>

In this section we'll look at the process for defining cadences unique to your organization that don't exist or belong in the [Dealbot Cadence Library](https://github.com/dealbot/cadences). Let's look at an example to start:

``` yaml
# snip
cadences:
  2x4:
    cadence:
      1:
        - channel: call
          title: Intro call
          notes: Leave voicemail
      4:
        - channel: email
          title: Breakup email
# snip
```

Once inside the `cadences` section, any YAML Dealbot finds will be treated as a block of [CadenceML](https://github.com/dealbot/CadenceML), the open serialization format we created to help sales pros share cadences with each other.

If you're curious about writing your own custom cadences, we suggest checking out the CadenceML docs to get started.

  </div>
</section>

<section>
## Sample configuration

  <div>
Sometimes the easiest way to get started is to look at a full-on example. Here is a production-grade sample configuration adapted from our own at [Faraday](http://faraday.io):

```yaml
company: Acme Products
triggers:
  sdr:
    enroll:
      pipeline: 1
      stage: 2
    abandon:
      pipeline: 1
      stage: 4
    cadences:
      - 7x7
      - 5x12: 2
  onboarding:
    enroll:
      pipeline: 2
      stage: 1
    cadences:
      - onboard
cadences:
  onboard:
    cadence:
      20:
        - channel: email
          title: AE followup
```
  </div>
</section>