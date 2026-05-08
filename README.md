# Billetto Events

An event-driven Ruby on Rails application built using [Rails Event Store](https://railseventstore.org/?utm_source=chatgpt.com) following a lightweight Domain-Driven Design (DDD) architecture inspired by Billetto’s internal backend patterns.

The application fetches public events from the Billetto API, stores them locally, and allows authenticated users to upvote or downvote events using an event-driven voting system.

---

# Features

- Fetch and ingest events from Billetto API
- Event listing page
- Event-driven voting system
- Upvote / Downvote functionality
- Authentication using [Clerk](https://clerk.com?utm_source=chatgpt.com)
- Read-model based vote counting
- Thin controllers with command-based architecture
- Async event handlers using Sidekiq
- RSpec test coverage

---

# Tech Stack

- Ruby on Rails
- PostgreSQL
- [Rails Event Store](https://railseventstore.org/?utm_source=chatgpt.com)
- Sidekiq
- RSpec
- Clerk Authentication

---

# Architecture Overview

This project follows an event-driven architecture with domain separation inspired by Billetto’s engineering guidelines.

## High-Level Flow

```text
Controller
  ↓
Command Bus
  ↓
Domain Command
  ↓
Domain Object
  ↓
Publish Domain Event (Fact)
  ↓
Event Handlers / Read Models
  ↓
Updated Query Models
```

---

# Domain Structure

```text
app/domain/
  events/
  voting/

app/read_models/
app/integrators/
```

## Domain Modules

### Events
Responsible for:
- Fetching Billetto events
- Ingesting external API data
- Managing event lifecycle

### Voting
Responsible for:
- Upvotes / Downvotes
- Vote events
- Vote counting read models

---

# Event-Driven Voting

Instead of directly mutating counters in the database, votes are stored as immutable domain events.

Example events:

- `Voting::EventUpvoted`
- `Voting::EventDownvoted`

These events are published to Rails Event Store and asynchronously processed by read model handlers.

## Why Event Sourcing?

Using events instead of direct counter updates provides:

- Auditability
- Replayability
- Better debugging capabilities
- Async scalability
- Clear separation between write and read concerns

---

# Read Models

Vote totals are maintained using asynchronous read models.

Example:

```text
Voting::EventUpvoted
  ↓
ReadModels::VoteCounter
  ↓
event_vote_counts table updated
```

This keeps reads efficient while preserving immutable event history.

---

# Commands

Business actions are implemented as commands.

Examples:

- `Voting::Upvote`
- `Voting::Downvote`
- `Events::IngestEvents`

Controllers only parse params and dispatch commands through the command bus.

Example:

```ruby
command_bus.call(
  Voting::Upvote.new(
    event_id: params[:id],
    user_id: current_user.id
  )
)
```

---

# Domain Events (Facts)

Domain events represent immutable business facts.

Example:

```ruby
Voting::EventUpvoted.strict(
  data: {
    event_id: event.id,
    user_id: current_user.id
  }
)
```

Events are published into streams to support traceability and replayability.

---

# Authentication

Authentication is implemented using [Clerk](https://clerk.com?utm_source=chatgpt.com).

Only authenticated users can vote on events.

User identifiers are included in domain events for traceability.

---

# API Integration

The Billetto API integration is isolated behind a dedicated client.

Responsibilities include:

- External API communication
- Error handling
- Data validation
- Idempotent ingestion
- Retry-safe processing

Events are identified using external IDs to prevent duplicate ingestion.

---

# Async Processing

Read models and event handlers are processed asynchronously using Sidekiq.

This improves:

- Scalability
- Responsiveness
- Decoupling
- Failure isolation

---

# Trade-offs

This architecture intentionally introduces additional complexity compared to a traditional CRUD application.

## Advantages

- Strong audit trail
- Replayable domain history
- Better separation of concerns
- Easier debugging of business workflows
- Scalable async processing

## Trade-offs

- Eventual consistency
- More moving parts
- Increased operational complexity
- Additional infrastructure requirements

---

# Future Improvements

Potential future enhancements include:

- Event replay tooling
- Dead-letter queue support
- Redis caching layer
- Background ingestion scheduling
- Observability dashboards
- Rate limiting
- Webhook-based synchronization
- More advanced process managers

---

# Setup Instructions

## Prerequisites

- Ruby 3.x
- PostgreSQL
- Redis

---

## Installation

Clone the repository:

```bash
git clone <repo_url>
cd billetto_events
```

Install dependencies:

```bash
bundle install
```

Setup database:

```bash
rails db:create
rails db:migrate
```

Start Redis:

```bash
redis-server
```

Start Sidekiq:

```bash
bundle exec sidekiq
```

Start Rails server:

```bash
rails server
```

---

# Environment Variables

Create `.env` file:

```env
BILLETTO_API_KEY=your_api_key
CLERK_SECRET_KEY=your_clerk_secret
CLERK_PUBLISHABLE_KEY=your_clerk_publishable_key
```

---

# Running Tests

```bash
bundle exec rspec
```

---

# Testing Strategy

The test suite focuses on:

- Command behavior
- Event publication
- Authentication restrictions
- Read model correctness
- Request flows

---

# Design Decisions

## Thin Controllers

Controllers contain no business logic and only dispatch commands.

## Commands Over Service Objects

Commands make workflows explicit and easier to trace.

## Event Store for Voting

Votes are modeled as immutable business facts rather than mutable counters.

## Read Models

Read models provide optimized query performance while maintaining event history.

---

# Notes

The focus of this assignment was backend architecture, event-driven design, scalability, and maintainability rather than frontend polish.

Frontend implementation was intentionally kept minimal to prioritize domain modeling and system design.
