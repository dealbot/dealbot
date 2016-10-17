<img src="https://cdn.rawgit.com/dealbot/dealbot/master/dealbot.svg" alt="Dealbot" width="200" />

Dealbot is a lightweight sales (semi-)automation system that hooks into [Pipedrive](https://pipedrive.com/taf/faraday1) to schedule tasks based on predefined cadences.

[![Build Status](https://travis-ci.org/dealbot/dealbot.svg?branch=master)](https://travis-ci.org/dealbot/dealbot) [![Coverage Status](https://coveralls.io/repos/github/dealbot/dealbot/badge.svg?branch=master)](https://coveralls.io/github/dealbot/dealbot?branch=master)

## What does Dealbot do?

**Website:** http://dealbot.faraday.io

Dealbot watches for deals to move into certain stages of certain pipelines and then applies one or more cadences to those deals. Then all you have to do is watch your Activites tab in Pipedrive to know what outreach action to take on a given day!

### What's a cadence?

A cadence is a series of activities (like calls, emails, etc.) on a certain schedule. See our [cadence library](../../../cadences) for some examples.

### What's Pipedrive?

Pipedrive is a CRM system, like Salesforce but more visual and simpler. You use Pipedrive to manage your sales and other customer-facing processes.

### Isn't this what SalesLoft, Outreach.io, etc. are for?

Definitely. Those tools are way more powerful than Dealbot. But sometimes all you need is just a little automation to make things sing. Plus you can't beat the price!

## Installation

### Deploy

Dealbot is designed to be deployed on Heroku.

1. Click the deploy button: [![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

2. Log in to Heroku or create an account. Note that while Dealbot is designed to run in Heroku's free usage tier, **you must have a credit card on file** with Heroku to deploy Dealbot.

3. Fill out the required config fields and click "Deploy for Free."

4. When the deploy process is complete, click the "View" button to complete Dealbot's setup.

5. You'll be prompted for authentication. Within a minute or two you should receive an email containing your Dealbot instance's secret API key—that's your username. Password is blank.

### Configure

After deploying with the Heroku button above, you will be redirected to your Dealbot instance's setup page which includes instructions for [configuring your Dealbot](http://dealbot.faraday.io/configuration). 

## Contributing

Dealbot is under active development but has seen heavy use at Faraday for several months so far. We'd love your contributions!

### To contribute

Please submit a Pull Request. You can even get started with just a README change, and we can discuss code changes from there.

## Brought to you by Faraday

![Faraday](https://cdn.rawgit.com/rossmeissl/9ca9523390a01aeb5458b520cd2b1252/raw/6367682fc0157c1a00d65f32ee399373cee03b96/faraday_logo.svg)

[Faraday](http://www.faraday.io) is a beautiful, map-driven customer outreach and analytics platform. Visualize your customers and explore hundreds of built-in household level attributes. Build audiences of customers, leads, and brand new prospects, then reach them online and off.

Faraday started the [Dealbot](../../../dealbot) project to share the open-source sales automation system we built on top of Pipedrive. We love the Pipedrive CRM and felt it needed only a little bit more to become the engine for our whole sales team.