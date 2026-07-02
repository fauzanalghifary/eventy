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

1. I use pessimistic locking to prevent overbooking.
   - The booking service locks the matching `ticket_types` rows before counting existing bookings. If two requests try to 
   book the last ticket at the same time, one request waits, then checks capacity again after the first request finishes.

2. The locking is correct, but it is not perfect for scale. 
   - Because I lock the ticket type row, bookings for the same ticket type on different dates also wait for each other.
   For this take-home I think that trade-off is acceptable. In a larger system, I would add a `ticket_type_availabilities` 
   table so capacity can be locked per ticket type per date.

3. I keep capacity simple.
   - Each ticket type has a `capacity`, and remaining capacity is calculated from existing bookings for the requested
   date. I did not store a separate `remaining_capacity` value because it could get out of sync with the booking records.

4. I put the booking flow in `CreateBookingService`.
   - The service checks the event, checks the selected ticket types, checks capacity, then creates the booking and booking
   items in one transaction. This keeps the important booking logic out of GraphQL.

5. I batch the GraphQL availability counts to avoid N+1 queries.
   - `remainingCapacity` uses GraphQL dataloader, so an event with many ticket types does not run one booking count query
   per ticket type.

### What I'd Add With More Time

- [ ] Add a `ticket_type_availabilities` table, so bookings for different dates do not block each other.
- [ ] Add an `event_occurrences` table, so users cannot book an event on a day it does not run.
- [ ] Store customer info and support cancelled/refunded bookings.
- [ ] Add an `organization`/`company` table to separate data between venue operators.

### Questions I'd Ask the Product Team

- If one ticket type is sold out, should the whole booking fail?
- Does an event happen once, or can it happen on many dates?
- Does ticket capacity reset for each date?
- What customer details do we need to store?
- If a booking is cancelled or refunded, should the tickets become available again?

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
