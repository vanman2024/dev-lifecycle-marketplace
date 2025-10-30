---
number: 0001
title: Use PostgreSQL for Primary Database
date: 2025-01-15
status: accepted
deciders: [Tech Lead, Backend Team Lead, CTO]
consulted: [DevOps Team, Security Team, Database Administrator]
informed: [Frontend Team, Product Team, QA Team]
tags: [database, architecture, backend]
domain: backend
technologies: [PostgreSQL, pgvector]
impact: high
effort: medium
owner: Backend Team
completion_date: 2025-02-28
review_cycle: quarterly
next_review: 2025-05-15
---

# 0001: Use PostgreSQL for Primary Database

## Status

**accepted**

Decision was accepted on 2025-01-20 and implementation completed on 2025-02-28.

## Context

We are building a new SaaS application for project management that requires:
- Reliable data persistence for user accounts, projects, tasks, and comments
- Complex relational queries (project hierarchies, user permissions, team structures)
- ACID compliance for financial transactions and billing
- Support for full-text search across projects and tasks
- Future capability for vector embeddings and semantic search (AI features roadmap)
- Expected initial load: 1000 users, 50,000 projects
- Growth projection: 10x growth over 2 years

### Technical Forces

- **Current Stack**: Node.js backend with TypeScript, React frontend
- **Team Expertise**: Team has 5 years of PostgreSQL experience, limited NoSQL experience
- **Performance Requirements**:
  - 95th percentile response time < 200ms for reads
  - Write operations < 500ms
  - Support 1000 concurrent users
- **Data Consistency**: Strong consistency required for billing and permissions
- **Query Complexity**: Need for joins, transactions, and complex filtering

### Business Forces

- **Budget**: $500/month initially, can scale to $2000/month
- **Timeline**: MVP in 3 months, need to move fast
- **Compliance**: SOC 2 Type II required within 1 year
- **Backup and Recovery**: RTO < 4 hours, RPO < 1 hour

### Team Forces

- **Experience**:
  - Strong PostgreSQL expertise (5+ years)
  - Some MongoDB experience (2 years)
  - No experience with other databases
- **Team Size**: 4 backend engineers, 1 DevOps engineer
- **Available Time**: Cannot afford 2+ weeks for learning new technology

### Stakeholder Forces

- **CTO**: Wants proven, stable technology with strong ecosystem
- **Product**: Needs flexible schema that can evolve quickly
- **Finance**: Cost-conscious, wants predictable pricing
- **Security**: Requires encryption at rest, audit logging, role-based access

## Decision

We will use **PostgreSQL 15** as our primary database for all application data.

Specifically:
- PostgreSQL 15 or later for all relational data
- Hosted on AWS RDS for managed service benefits
- Use pgvector extension for future vector/embedding storage
- Implement connection pooling with PgBouncer
- Use Read Replicas for read-heavy workloads

### Considered Alternatives

#### Alternative 1: MongoDB

**Description**: Document-oriented NoSQL database with flexible schema

**Pros:**
- Flexible schema allows rapid iteration
- Good for hierarchical data (projects, tasks)
- Native JSON support
- Horizontal scaling built-in
- Good developer experience with Mongoose ODM

**Cons:**
- Limited team expertise (only 2 years experience)
- Weak support for complex joins
- Eventual consistency model not suitable for billing
- More expensive for our data patterns (many relations)
- No native full-text search comparable to PostgreSQL

**Why Not Chosen:**
- Our data is highly relational (users → teams → projects → tasks)
- Need ACID compliance for billing
- Team would require 2-3 weeks training
- Cost analysis showed 30% higher expense due to data duplication

#### Alternative 2: MySQL

**Description**: Open-source relational database

**Pros:**
- Mature and stable
- Good performance for read-heavy workloads
- Lower resource usage than PostgreSQL
- Wide ecosystem and community
- Team has some familiarity

**Cons:**
- Limited support for advanced features (JSON, full-text search)
- No native vector support for AI features
- Replication can be complex
- Less feature-rich than PostgreSQL
- Licensing concerns with Oracle ownership

**Why Not Chosen:**
- Lack of pgvector equivalent blocks AI roadmap
- Inferior JSON support (critical for flexible task metadata)
- Team prefers PostgreSQL developer experience
- Full-text search not as robust

#### Alternative 3: DynamoDB

**Description**: AWS managed NoSQL database

**Pros:**
- Fully managed, serverless
- Automatic scaling
- Pay-per-use pricing
- Great for AWS-native applications
- Low operational overhead

**Cons:**
- No team expertise (would require 3-4 weeks training)
- Query limitations (no joins, complex filters)
- Difficult to model relational data
- Vendor lock-in to AWS
- Cost unpredictable with growth

**Why Not Chosen:**
- Query patterns don't fit key-value model
- Team has no DynamoDB experience
- Risk of cost explosion with growth
- Cannot meet complex query requirements

### Why This Decision

PostgreSQL was chosen as the optimal solution because:

1. **Best Fit for Data Model**: Our data is inherently relational with many foreign key relationships, joins, and transactions. PostgreSQL handles this naturally.

2. **Team Expertise**: Team's 5 years of PostgreSQL experience means:
   - Zero learning curve
   - Faster development
   - Better troubleshooting
   - Established best practices

3. **Feature Completeness**: PostgreSQL provides everything we need:
   - ACID compliance for billing
   - Full-text search for content
   - JSON support for flexible task metadata
   - pgvector for future AI features
   - Window functions for analytics

4. **Cost Effectiveness**:
   - RDS pricing is predictable ($200/month initially)
   - No data duplication needed (unlike MongoDB)
   - Efficient storage of relational data

5. **Ecosystem and Tooling**:
   - Mature ORMs (Prisma, TypeORM)
   - Excellent monitoring tools
   - Strong community support
   - Comprehensive documentation

6. **Future-Proof**: pgvector extension enables planned AI features without database migration

## Consequences

### Positive Consequences

**Technical Benefits:**
- **Zero Learning Curve**: Team productive immediately, no training needed
- **Strong Data Integrity**: ACID compliance ensures billing accuracy and prevents data corruption
- **Rich Query Capabilities**: Complex joins, CTEs, window functions enable sophisticated features
- **Full-Text Search**: Native full-text search eliminates need for separate search service (save $100/month)
- **JSON Support**: Flexible task metadata without schema migrations
- **Vector Support**: pgvector enables future semantic search and AI features
- **Excellent Tooling**: pgAdmin, pg_stat_statements, excellent monitoring

**Business Benefits:**
- **Predictable Costs**: RDS pricing is clear, no surprise bills
- **Fast Development**: No learning overhead means hitting MVP deadline
- **Proven Reliability**: PostgreSQL's stability reduces risk
- **Compliance Ready**: Built-in features support SOC 2 requirements

**Team Benefits:**
- **High Productivity**: Team works with familiar technology
- **Easy Hiring**: PostgreSQL skills are common, easier to hire
- **Less Stress**: No pressure to learn new database during tight timeline

### Negative Consequences

**Technical Limitations:**
- **Vertical Scaling Initially**: Harder to scale horizontally (but sufficient for 2-year plan)
- **Connection Limits**: Need connection pooling for high concurrency (mitigated with PgBouncer)
- **Write Scaling**: Single-master architecture limits write throughput (not an issue at current scale)
- **Cost at Scale**: More expensive than some alternatives beyond 100GB (but 2+ years away)

**Operational Complexity:**
- **Replication Lag**: Read replicas can have lag (mitigated with connection routing)
- **Backup Management**: Need to manage WAL archiving and PITR (handled by RDS)
- **Index Maintenance**: Requires periodic VACUUM and REINDEX (scheduled during low-traffic)

**Vendor Considerations:**
- **AWS Dependency**: Using RDS creates AWS lock-in (acceptable given overall AWS strategy)
- **RDS Limitations**: Some PostgreSQL extensions not available on RDS (none critical for us)

### Neutral Consequences

**Operational Changes:**
- Need to establish PostgreSQL best practices: connection pooling, query optimization, index strategy
- Require monitoring setup: slow query logs, connection metrics, replication lag
- Must implement backup verification procedures

**Team Responsibilities:**
- Database Administrator role needs to be defined (shared among backend team initially)
- On-call rotation must include database expertise
- Regular database health checks added to sprint rituals

### Risks and Mitigation

| Risk | Likelihood | Impact | Mitigation Strategy |
|------|------------|--------|---------------------|
| Connection pool exhaustion | Medium | High | Implement PgBouncer, monitor connections, set connection limits |
| Replication lag affects UX | Low | Medium | Route writes to master, cache reads where acceptable |
| Storage growth exceeds budget | Low | Medium | Implement data archival strategy, monitor growth weekly |
| Query performance degrades | Medium | High | Establish index strategy, use EXPLAIN ANALYZE, monitor slow queries |

## Implementation

### Required Changes

#### Code Changes
- Install PostgreSQL driver: `pg` for Node.js
- Set up Prisma ORM with PostgreSQL connector
- Create database schema with migrations
- Implement connection pooling layer
- Add database health check endpoints

#### Configuration Changes
- Set up environment variables for database connection
- Configure connection pool settings (min: 10, max: 100 connections)
- Enable query logging for slow queries (>500ms)
- Configure SSL for all connections

#### Infrastructure Changes
- Provision RDS PostgreSQL instance (db.t3.medium initially)
- Set up Multi-AZ deployment for high availability
- Create Read Replica for reporting queries
- Configure automated backups (7-day retention, 1-hour backup window)
- Set up parameter group with optimized settings
- Configure security groups for VPC access

#### Documentation Changes
- Create database schema documentation
- Document connection pooling strategy
- Write migration runbook
- Create troubleshooting guide for common issues

### Migration Strategy

#### Phase 1: Infrastructure Setup (Week 1)
- **Duration**: 5 days
- **Activities**:
  - Provision RDS instance in staging environment
  - Configure security groups and VPC
  - Set up automated backups and monitoring
  - Install and configure PgBouncer
- **Success Criteria**:
  - Can connect to database from application
  - Monitoring shows healthy metrics
  - Backup completes successfully

#### Phase 2: Schema Development (Week 2-3)
- **Duration**: 10 days
- **Activities**:
  - Design database schema
  - Create Prisma schema
  - Generate and test migrations
  - Load test data
- **Success Criteria**:
  - All tables created with proper relationships
  - Indexes optimized for query patterns
  - Migrations run cleanly
  - Test data loaded successfully

#### Phase 3: Application Integration (Week 4-6)
- **Duration**: 15 days
- **Activities**:
  - Implement data access layer
  - Write and test queries
  - Set up connection pooling
  - Implement caching strategy
- **Success Criteria**:
  - All CRUD operations working
  - Performance tests pass (< 200ms reads)
  - Connection pooling prevents exhaustion
  - Error handling covers all cases

#### Phase 4: Production Deployment (Week 7)
- **Duration**: 5 days
- **Activities**:
  - Provision production RDS instance
  - Set up monitoring and alerts
  - Deploy application
  - Monitor for issues
- **Success Criteria**:
  - Zero data loss
  - Performance meets SLA
  - No critical errors
  - Monitoring alerts working

### Rollback Plan

**Triggers for Rollback:**
- Critical performance issues affecting all users
- Data corruption or integrity issues
- Cannot meet MVP deadline due to database issues
- Security vulnerability discovered with no patch

**Rollback Steps:**
1. Stop all write traffic to PostgreSQL
2. Switch application to use SQLite for development continuation
3. Export critical data for preservation
4. Evaluate alternative database or wait for issue resolution

**Data Preservation:**
- Daily snapshots stored in S3 (retained for 30 days)
- Point-in-time recovery available for last 7 days
- Export schema and data to SQL dump files

**Timeline:**
- Immediate rollback possible (switch to SQLite)
- Full data migration to alternative database: 2-3 weeks

## Validation and Success Criteria

### Metrics to Track

**Performance Metrics:**
- Average query response time: Target < 100ms (Baseline will be established week 1)
- 95th percentile response time: Target < 200ms
- Connection pool utilization: Target < 80%
- Replication lag: Target < 5 seconds

**Reliability Metrics:**
- Database uptime: Target 99.9%
- Failed query rate: Target < 0.1%
- Backup success rate: Target 100%

**Cost Metrics:**
- Monthly RDS cost: Target $200-300 (first 6 months)
- Storage growth: Target < 10GB/month
- Data transfer costs: Target < $50/month

### Success Indicators

Short-term (3 months):
- MVP launched on time with PostgreSQL
- No major outages or data loss
- Performance meets SLA requirements
- Team velocity maintained (no slowdown from database issues)

Medium-term (6 months):
- Handling 1000+ concurrent users
- Query performance within targets
- No critical bottlenecks identified
- Cost within budget

Long-term (12 months):
- Successfully scaled to 10,000 users
- Full-text search performing well
- pgvector integrated for AI features
- Team still satisfied with choice

### Review Schedule

- **30-day review** (2025-02-15): Check implementation progress, performance baselines
- **90-day review** (2025-04-15): Evaluate if MVP launched successfully, gather team feedback
- **6-month review** (2025-07-15): Assess performance at scale, review costs, check if assumptions hold
- **Annual review** (2026-01-15): Determine if PostgreSQL continues to meet needs or if migration is needed

## References

### Internal References
- [Database Schema Design](https://docs.internal/database-schema)
- [Prisma Setup Guide](https://docs.internal/prisma-guide)
- [Connection Pooling Strategy](https://docs.internal/connection-pooling)

### External References
- [PostgreSQL 15 Documentation](https://www.postgresql.org/docs/15/)
- [AWS RDS PostgreSQL Best Practices](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html)
- [pgvector Extension](https://github.com/pgvector/pgvector)
- [Prisma PostgreSQL Guide](https://www.prisma.io/docs/concepts/database-connectors/postgresql)

### Tools and Resources
- Prisma ORM
- PgBouncer for connection pooling
- pgAdmin for database management
- DataDog for monitoring
- pg_stat_statements for query analysis

## Notes

### Open Questions
- None remaining (all resolved during decision process)

### Future Considerations
- Implement Citus extension if horizontal scaling needed (>2 years out)
- Consider TimescaleDB extension for time-series analytics data
- Evaluate Supabase as alternative to RDS if we need realtime features

### Assumptions
- Traffic growth will be gradual (not viral/sudden spike)
- AWS will remain our primary cloud provider
- Budget will scale proportionally with user growth
- PostgreSQL will continue to be actively maintained and improved

### Dependencies
- Depends on AWS account setup and budget approval
- Team training on Prisma ORM (2-3 days, minimal)
- DevOps support for initial RDS provisioning

---

*Date: 2025-01-15*
*Deciders: Tech Lead, Backend Team Lead, CTO*
*Status: accepted*
*Completion Date: 2025-02-28*
