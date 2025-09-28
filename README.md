# ToucanTix Senior Rails Developer Technical Assessment

## Venue Event Capacity Manager - Starter Repository

Welcome! This is the starter repository for the ToucanTix technical assessment. Your challenge is to build a capacity-controlled event management system with a GraphQL API.

## Challenge Overview

**Time Expectation:** ~3 hours

The time allocations in each section are suggestions to help you prioritize. We care most about your decisions, communication, and approach — complete what you can and document your thinking. Quality and thoughtfulness are more important than finishing everything.

**Scenario:**
ToucanTix needs a new feature for venues to manage capacity-controlled events with different ticket types. Serengeti Park wants to run a special 'Evening Safari' with limited slots.

## What's Provided

This starter repository includes:

- Rails API application configured with PostgreSQL
- GraphQL gem installed and basic setup complete
- Venue model (already created and seeded)
- RSpec, FactoryBot, and testing gems configured
- Basic project structure

## What You Need to Implement

### Core Models to Create

- Event (belongs to Venue)
- TicketType (belongs to Event)
- Booking (tracks purchases)

### Must Support

1. Create an event with multiple ticket types (Adult, Child, Member)
2. Each ticket type has its own capacity and pricing
3. Atomic booking creation that prevents overbooking
4. GraphQL endpoint to check real-time availability
5. Handle concurrent bookings safely

### Part 1: Database & Models (~45 min suggested)

- PostgreSQL schema design
- Rails models with validations
- One migration file

### Part 2: Core Business Logic (~90 min suggested)

Implement a `CreateBookingService` that:

- Validates ticket availability
- Handles atomic operations to prevent race conditions
- Returns clear errors when capacity exceeded
- Uses appropriate locking strategy (pessimistic or optimistic)

**Critical Requirement:** Your solution MUST handle concurrent bookings safely. When 100 people try to book the last ticket simultaneously, only one should succeed.

### Part 3: GraphQL API (~45 min suggested)

Implement the following GraphQL schema:

```graphql
# Query for checking availability
query EventAvailability($eventId: ID!, $date: ISO8601Date!) {
  event(id: $eventId) {
    name
    ticketTypes {
      name
      price
      remainingCapacity(date: $date)
    }
  }
}

# Mutation for creating bookings
mutation CreateBooking($input: BookingInput!) {
  createBooking(input: $input) {
    booking {
      id
      confirmationCode
    }
    errors
  }
}

# BookingInput should include:
# - eventId: ID!
# - date: ISO8601Date!
# - ticketSelections: [TicketSelectionInput!]!
#
# TicketSelectionInput should include:
# - ticketTypeId: ID!
# - quantity: Int!
```

### Part 4: Testing & Documentation (~30 min suggested)

- Write tests demonstrating your booking logic works correctly
- Consider concurrent scenarios (note: realistic race condition testing is challenging — document your approach rather than building complex test infrastructure)
- Complete the "Your Solution" section below
- See `spec/requests/venues_spec.rb` for a working request spec template

## Your Solution

### Design Decisions

1. Why I chose [X approach] for handling capacity:
2. How I prevent race conditions:
3. Trade-offs I made given the time constraint:

### What I'd Add With More Time

- [ ] ...
- [ ] ...

### Questions I'd Ask the Product Team

- ...

## Evaluation Criteria

We're looking for:

- ✅ Database design that handles concurrent access
- ✅ Understanding of Rails transactions and locking
- ✅ Clean service object pattern
- ✅ GraphQL resolver efficiency (N+1 prevention)
- ✅ Test coverage on the critical path

Bonus points for:

- Considering multi-tenant isolation
- Caching strategies
- Edge cases (refunds, partial bookings)
- Clear documentation of decisions

## Tips

1. **Start with the models** - Get the associations right first
2. **Focus on the race condition** - This is the most critical part
3. **Write at least one integration test** - Show the full booking flow works
4. **Document your approach** - We value clear thinking over perfect code
5. **Use Rails conventions** - We're looking for idiomatic Rails code

## Submission

When complete:

1. Ensure all tests pass
2. Fill out the "Your Solution" section above
3. Commit your changes with clear, descriptive commit messages
4. Submit your work using the following method:

```bash
git bundle create toucan-challenge.bundle --all
```

Email us the `.bundle` file. We can clone it like a normal repo.

---

Feel free to use any Rails patterns you prefer (concerns, services, form objects, etc). We care more about clarity and correctness than following a specific pattern.
