# Resolvinator

Resolvinator is a comprehensive system designed to manage content, projects, risks, resources, and attachments within a Phoenix application. It leverages behavior modules and 

## Core Behaviors

The application uses several behavior modules, each implemented as a macro using `__using__/1`, to provide shared functionality:

### ContentBehavior

**Key Features:**
- Common content fields (name, description, status, visibility, etc.)
- Embedded schemas for Voting and Moderation
- Self-referential relationships
- Description management
- Comment support
- Status workflow (draft → review → published → archived)

### RiskBehavior

**Key Features:**
- Risk assessment fields
- Priority and status management
- Probability and impact tracking
- Metadata support

### ImpactBehavior

**Key Features:**
- Impact assessment
- Area categorization
- Severity and likelihood tracking
- Cost estimation
- Timeframe management

### InventoryBehavior

**Key Features:**
- Resource tracking
- Status management
- Category support
- Project association
- Metadata and notes

### AttachmentBehavior

**Key Features:**
- File metadata management
- Polymorphic associations
- Content type validation
- Size tracking

## Relationships and Extensions

### Content Relationships

Each content type has specific relationships:
- Problems → Solutions, Lessons, Advantages
- Solutions → Problems, Lessons, Advantages
- Lessons → Problems, Solutions, Advantages
- Advantages → Problems, Solutions, Lessons

### Common Patterns

- All behaviors require a `type_name` and `table_name`
- Use of embedded schemas for complex attributes
- Consistent status workflows
- Metadata support across all types
- Project and creator associations
- Comment capability integration

### Schema Extensions

Behaviors support extension through:
- Additional fields
- Custom relationships
- Embedded schemas
- Validation rules

## Common Functionality

All behaviors provide:
- Base changeset validation
- Required field validation
- Status management
- Relationship handling
- Metadata support
- Creator tracking

This architecture promotes code reuse and consistent behavior across different types of entities while maintaining flexibility for specific requirements.

## Getting Started

To start your Phoenix server:

1. Run `mix setup` to install and setup dependencies.
2. Start the Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`.

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Deployment

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn More

- Official website: [Phoenix Framework](https://www.phoenixframework.org/)
- Guides: [Phoenix Guides](https://hexdocs.pm/phoenix/overview.html)
- Docs: [Phoenix Docs](https://hexdocs.pm/phoenix)
- Forum: [Elixir Forum](https://elixirforum.com/c/phoenix-forum)
- Source: [Phoenix GitHub](https://github.com/phoenixframework/phoenix)
