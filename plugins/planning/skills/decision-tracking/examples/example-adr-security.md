---
number: 0008
title: Implement OAuth 2.1 with PKCE for Authentication
date: 2025-02-05
status: accepted
deciders: [Security Lead, Tech Lead, CTO]
consulted: [Engineering Teams, Compliance Officer, External Security Auditor]
informed: [Product Team, Customer Success, Legal]
tags: [security, authentication, compliance]
domain: security
technologies: [OAuth 2.1, PKCE, Auth0, JWT]
impact: critical
effort: high
owner: Security Team
completion_date: 2025-03-20
review_cycle: quarterly
next_review: 2025-06-20
---

# 0008: Implement OAuth 2.1 with PKCE for Authentication

## Status

**accepted**

Decision was accepted on 2025-02-10 and implementation completed on 2025-03-20.

## Context

Our SaaS application currently uses a basic username/password authentication system with session cookies. As we scale and pursue enterprise customers, we need a more robust authentication strategy that:

- Supports Single Sign-On (SSO) for enterprise customers
- Enables social login (Google, Microsoft, GitHub)
- Meets SOC 2 Type II compliance requirements
- Provides secure mobile and SPA authentication
- Reduces password management burden
- Supports multi-factor authentication (MFA)
- Enables fine-grained authorization

### Technical Forces

**Current Authentication System:**
- Basic username/password with bcrypt hashing
- Session-based authentication with HTTP-only cookies
- 90-day password rotation policy
- No MFA support
- No SSO capability
- Manual password reset process
- Limited audit logging

**Requirements:**
- Support web app, mobile app (iOS/Android), and third-party API access
- Enable SSO with SAML 2.0 and OpenID Connect
- Implement MFA (TOTP, SMS, biometric)
- Support OAuth scopes for API authorization
- Refresh tokens for long-lived sessions
- Comprehensive audit logging
- Zero-trust security model

**Security Concerns:**
- Current system vulnerable to credential stuffing
- Password reuse across services
- Session fixation risks
- No rate limiting on login attempts
- Weak password reset mechanism
- Limited visibility into authentication events

### Business Forces

**Enterprise Sales Requirements:**
- Enterprise customers require SSO (80% of deals > $50K/year)
- Need to support Okta, Azure AD, Google Workspace
- Compliance requirements for SOC 2, GDPR, HIPAA
- Security questionnaires ask about OAuth 2.0 support

**User Experience:**
- 15% of support tickets are password-related
- Users want social login options
- Mobile users frustrated with frequent re-authentication
- Need seamless SSO across multiple products

**Risk Mitigation:**
- Recent increase in credential stuffing attacks (3 incidents in 6 months)
- Need to reduce liability from password storage
- Regulatory pressure to implement stronger authentication

### Team Forces

**Team Expertise:**
- Moderate understanding of OAuth 2.0 (2 engineers have experience)
- Limited experience with identity providers
- Strong general security knowledge
- No internal expertise in SAML implementation

**Available Resources:**
- Budget for authentication service: $500-1000/month
- Can allocate 2 engineers for 6 weeks
- Need solution operational within 2 months

### Stakeholder Forces

**Security Requirements:**
- Eliminate password storage where possible
- Implement defense in depth
- Support hardware security keys
- Enable comprehensive audit logging

**Compliance Requirements:**
- SOC 2 Type II audit in 4 months
- GDPR compliance for EU customers
- Support for customer-managed keys (future)

**Product Requirements:**
- Seamless user experience
- Support gradual migration from current system
- Enable A/B testing of authentication flows
- Mobile app parity with web experience

## Decision

We will implement **OAuth 2.1 with PKCE** as our authentication and authorization standard, using **Auth0** as the managed identity provider.

**Specifically:**

1. **OAuth 2.1 with PKCE:**
   - Use Authorization Code Flow with PKCE for all clients (web, mobile, native)
   - Implement refresh token rotation for enhanced security
   - Use short-lived access tokens (15 minutes)
   - Longer-lived refresh tokens (30 days) with automatic rotation

2. **Identity Provider:**
   - Use Auth0 as managed IdP (handles OAuth, SAML, OIDC)
   - Leverage Auth0's built-in MFA, anomaly detection, breached password detection
   - Use Auth0 extensibility for custom authentication rules
   - Maintain Auth0 as primary, with ability to migrate if needed

3. **Authentication Flows:**
   - Web SPA: Authorization Code Flow with PKCE
   - Mobile Apps: Authorization Code Flow with PKCE
   - Third-party API Access: Client Credentials Flow
   - Server-to-Server: Client Credentials Flow with mTLS

4. **Token Strategy:**
   - JWT access tokens with RSA-256 signing
   - Opaque refresh tokens stored in database
   - Include user ID, tenant ID, scopes in access token
   - 15-minute access token expiry, 30-day refresh token expiry

5. **SSO and Social Login:**
   - Support SAML 2.0 for enterprise SSO (via Auth0)
   - Enable Google, Microsoft, GitHub social login
   - Allow username/password as fallback
   - Implement account linking for multiple identity sources

6. **Security Features:**
   - Mandatory MFA for admin users
   - Optional MFA for all users
   - Rate limiting on authentication attempts
   - Anomaly detection (impossible travel, new device)
   - Breached password detection
   - Session management and revocation

### Considered Alternatives

#### Alternative 1: Basic Password Auth with Improvements

**Description:** Keep current system but add MFA, rate limiting, and better password policies.

**Pros:**
- Minimal learning curve for team
- No migration to external provider
- Lower ongoing costs ($0 vs $500-1000/month)
- Full control over authentication logic
- Simple implementation

**Cons:**
- No SSO support (blocks enterprise sales)
- No social login capability
- Team must maintain security infrastructure
- Vulnerable to password-based attacks
- Doesn't meet SOC 2 requirements
- High development effort for equivalent features
- Liability from password storage

**Why Not Chosen:**
- Cannot support enterprise SSO (critical business requirement)
- Significant engineering effort to match Auth0 features
- Ongoing maintenance burden on small team
- Doesn't address credential stuffing vulnerability
- Won't pass SOC 2 audit

#### Alternative 2: OpenID Connect Only (No Full OAuth 2.1)

**Description:** Implement only OIDC for authentication, not full OAuth 2.0 for authorization.

**Pros:**
- Simpler than full OAuth implementation
- Sufficient for authentication use cases
- Less complex token management
- Easier to understand and debug

**Cons:**
- No fine-grained authorization scopes
- Cannot support third-party API access
- Limited flexibility for future needs
- Doesn't support server-to-server auth
- No support for delegated authorization

**Why Not Chosen:**
- Roadmap includes third-party integrations (need OAuth scopes)
- Want to enable customer-built integrations
- Need fine-grained authorization for API
- OAuth 2.1 includes OIDC anyway

#### Alternative 3: Self-Hosted OAuth Server (Keycloak)

**Description:** Deploy and manage Keycloak as open-source OAuth/OIDC provider.

**Pros:**
- Open source, no per-user licensing fees
- Full control over authentication logic
- Can customize extensively
- Data sovereignty (all data stays with us)
- No vendor lock-in

**Cons:**
- Requires dedicated infrastructure ($300-500/month)
- Need expertise to operate securely
- Team must handle security patches
- No built-in anomaly detection or advanced security
- Significant operational overhead
- Need 24/7 monitoring and on-call
- Complex to scale and maintain HA

**Why Not Chosen:**
- Underestimating operational burden
- Would require dedicated engineer (>$500/month savings)
- Auth0's security features would take months to build
- Need to focus engineering on core product
- Want mature solution for SOC 2 audit

#### Alternative 4: Firebase Authentication

**Description:** Use Google's Firebase Auth for authentication.

**Pros:**
- Excellent mobile SDK support
- Built-in social login
- Easy to integrate
- Generous free tier
- Good documentation

**Cons:**
- Limited enterprise SSO support (no SAML)
- Tightly coupled to Google ecosystem
- Limited customization options
- Weak authorization features
- Not ideal for non-mobile use cases
- Vendor lock-in to Google

**Why Not Chosen:**
- No SAML support blocks enterprise sales
- Limited OAuth 2.0 capabilities
- Not designed for B2B SaaS
- Poor support for complex authorization

#### Alternative 5: AWS Cognito

**Description:** Use AWS Cognito as managed OAuth/OIDC provider.

**Pros:**
- AWS-native, good for our AWS infrastructure
- Lower cost than Auth0 at scale
- Supports OAuth 2.0, OIDC, SAML
- Good mobile SDK support

**Cons:**
- Complex to configure and customize
- Poor developer experience (team feedback)
- Limited built-in security features vs Auth0
- Weaker MFA options
- Less mature SSO implementation
- Documentation gaps

**Why Not Chosen:**
- Team found Cognito UX frustrating in prototype
- Auth0 has better enterprise SSO support
- Cognito's security features less comprehensive
- Auth0's extensibility superior for custom logic

### Why This Decision

OAuth 2.1 with PKCE using Auth0 is the optimal choice because:

1. **Meets All Business Requirements:**
   - Enterprise SSO via SAML and OIDC ✓
   - Social login (Google, Microsoft, GitHub) ✓
   - Mobile app support with PKCE ✓
   - Third-party API authorization ✓
   - SOC 2 compliance features ✓

2. **Security Best Practices:**
   - OAuth 2.1 incorporates latest security guidance
   - PKCE protects against authorization code interception
   - Short-lived access tokens limit exposure
   - Refresh token rotation prevents token theft
   - Auth0's built-in security (anomaly detection, breached passwords)

3. **Operational Efficiency:**
   - Auth0 handles security patches and updates
   - Built-in monitoring and alerting
   - 99.99% SLA on availability
   - Team focuses on product, not auth infrastructure
   - Faster time to market (2 months vs 6+ months self-hosted)

4. **Developer Experience:**
   - Well-documented SDKs for web, iOS, Android
   - Active community and support
   - Good integration with our stack (Node.js, React, React Native)
   - Excellent admin dashboard for operations team

5. **Cost-Effective:**
   - $800/month for 10,000 users (Pro plan)
   - Eliminates password-related support tickets (save 5 hours/week)
   - Faster enterprise sales (worth $5,000+/month)
   - Reduced security incident risk (hard to quantify but significant)

6. **Future-Proof:**
   - Easy to add new identity sources
   - Supports advanced features (passwordless, biometric)
   - Can migrate away if needed (standard protocols)
   - Enables customer-built integrations with OAuth

## Consequences

### Positive Consequences

**Security Improvements:**
- **Eliminated Password Storage**: Passwords handled by Auth0, reducing our liability
- **MFA Support**: Built-in TOTP, SMS, push notification, biometric authentication
- **Breach Detection**: Auth0's breached password database prevents compromised credentials
- **Anomaly Detection**: Automatic detection of impossible travel, new devices, suspicious patterns
- **Rate Limiting**: Built-in protection against brute force attacks
- **Audit Logging**: Comprehensive logs of all authentication events for compliance

**Business Enablers:**
- **Enterprise SSO**: Can now sell to enterprise customers requiring SSO (estimated $500K+ annual revenue impact)
- **Social Login**: Reduced friction for new user signup (estimated 15% conversion improvement)
- **Mobile Experience**: Seamless authentication in mobile apps without exposing credentials
- **Compliance**: Meets SOC 2, GDPR, HIPAA authentication requirements
- **Support Reduction**: 70% reduction in password-related support tickets (save 3.5 hours/week)

**Development Velocity:**
- **Faster Integration Development**: OAuth scopes enable third-party integrations
- **Standardized Auth**: Common authentication across all products
- **Less Maintenance**: Team doesn't maintain authentication infrastructure
- **Better Testing**: Can use Auth0 test environment for auth testing

**User Experience:**
- **Single Sign-On**: Users authenticate once across all our products
- **Social Login**: One-click login with Google/Microsoft/GitHub
- **Passwordless Options**: Can enable magic links, biometric in future
- **Session Management**: Users can view/revoke sessions from all devices

### Negative Consequences

**Vendor Dependency:**
- **Lock-in Risk**: Dependent on Auth0 for critical authentication service
- **Cost Scaling**: Pricing increases with user base ($800/month → $2,000/month at 25K users)
- **Service Outages**: Auth0 downtime prevents all authentication (mitigated by 99.99% SLA)
- **Feature Limitations**: Constrained by Auth0's feature set and roadmap

**Implementation Complexity:**
- **Migration Effort**: 6 weeks to migrate from current system
- **Learning Curve**: Team needs 1-2 weeks to learn OAuth 2.1 and Auth0 APIs
- **Token Management**: Complexity of managing token lifecycle (refresh, revocation)
- **Testing Complexity**: Auth flows harder to test than simple password auth

**Operational Changes:**
- **New Monitoring**: Need to monitor token generation, refresh rates, Auth0 health
- **Debugging**: Distributed auth makes debugging authentication issues more complex
- **Compliance**: Need to ensure Auth0 subprocessor listed in privacy policy
- **Support Training**: Support team needs training on Auth0 troubleshooting

**Technical Debt:**
- **Dual Auth System**: Must support both old and new auth during migration (6 weeks)
- **Migration Scripts**: Need scripts to migrate existing users
- **Session Management**: Need to handle existing sessions during transition
- **Rollback Complexity**: Difficult to roll back once users are on OAuth

### Neutral Consequences

**Process Changes:**
- Establish OAuth scope review process for new features
- Create runbook for common Auth0 operations
- Define policy for refresh token expiry
- Implement user identity verification for account recovery

**Monitoring Requirements:**
- Track authentication success/failure rates
- Monitor token generation and refresh patterns
- Alert on Auth0 rate limit approaches
- Dashboard for authentication anomalies

**Documentation Needs:**
- Document OAuth flows for team
- Create integration guide for third-party developers
- Write troubleshooting guide for support team
- Maintain list of configured identity providers

### Risks and Mitigation

| Risk | Likelihood | Impact | Mitigation Strategy |
|------|------------|--------|---------------------|
| Auth0 outage blocks all users | Low | Critical | Implement cache layer for token validation, graceful degradation mode |
| Migration breaks existing sessions | Medium | High | Gradual rollout with feature flags, maintain dual auth for 2 weeks |
| Costs exceed budget | Medium | Medium | Monitor user growth, negotiate enterprise pricing, plan for breakeven at 50K users |
| Users confused by SSO flow | Low | Medium | Clear UX messaging, help documentation, support team training |
| Token leakage via XSS | Low | High | Strict CSP, HttpOnly cookies for refresh tokens, short access token expiry |
| Scope creep in permissions | Medium | Medium | Establish OAuth scope governance, require approval for new scopes |

## Implementation

### Required Changes

#### Code Changes
- Install Auth0 SDKs (auth0-js for web, react-native-auth0 for mobile)
- Implement Authorization Code Flow with PKCE
- Build token management service (generation, refresh, revocation)
- Create middleware for JWT verification
- Implement OAuth scope enforcement
- Build account migration system for existing users
- Add MFA enrollment flows

#### Configuration Changes
- Create Auth0 tenant and applications
- Configure OAuth flows and grant types
- Set up social identity providers (Google, Microsoft, GitHub)
- Configure MFA policies
- Set token expiration policies
- Define OAuth scopes and permissions
- Configure webhook for user events

#### Infrastructure Changes
- Add Redis for token blocklist (revoked tokens)
- Configure Auth0 custom domain (auth.ourapp.com)
- Set up Auth0 log streaming to Datadog
- Configure CDN for Auth0 Universal Login
- Add monitoring for Auth0 health and quotas

#### Documentation Changes
- Create OAuth 2.1 integration guide
- Document authentication flows for each client type
- Write runbook for Auth0 operations
- Create troubleshooting guide
- Document scope definitions and usage
- Write user-facing MFA setup guide

### Migration Strategy

#### Phase 1: Auth0 Setup (Week 1)
- **Duration**: 1 week
- **Activities**:
  - Create Auth0 tenant and applications
  - Configure development environment
  - Set up social identity providers
  - Configure basic MFA
  - Implement prototype with one flow
- **Success Criteria**:
  - Can authenticate test user via Auth0
  - Social login working in dev environment
  - MFA enrollment flow functional
  - Tokens validated correctly

#### Phase 2: Core Implementation (Weeks 2-3)
- **Duration**: 2 weeks
- **Activities**:
  - Implement all OAuth flows (web, mobile, API)
  - Build token management service
  - Add JWT verification middleware
  - Implement refresh token rotation
  - Create account migration mechanism
  - Add scope-based authorization
- **Success Criteria**:
  - All flows working in staging
  - Token lifecycle managed correctly
  - Authorization working with scopes
  - Migration tested with sample users
  - Performance meets requirements (<200ms token validation)

#### Phase 3: Migration and Rollout (Weeks 4-5)
- **Duration**: 2 weeks
- **Activities**:
  - Migrate user accounts to Auth0
  - Gradual rollout with feature flags (5% → 25% → 50% → 100%)
  - Support both old and new auth systems
  - Monitor authentication success rates
  - Train support team
- **Success Criteria**:
  - 100% users migrated successfully
  - Authentication success rate >99.5%
  - No increase in support tickets
  - Old auth system can be deprecated

#### Phase 4: Enterprise SSO and Polish (Week 6)
- **Duration**: 1 week
- **Activities**:
  - Set up enterprise SSO for pilot customers
  - Implement admin dashboard for auth management
  - Add comprehensive monitoring
  - Optimize performance
  - Complete documentation
- **Success Criteria**:
  - First enterprise customer using SSO
  - Admin dashboard operational
  - All monitoring in place
  - Documentation complete

### Rollback Plan

**Triggers for Rollback:**
- Auth0 outage lasting >1 hour
- Authentication success rate drops below 95%
- Critical security vulnerability discovered
- Migration fails for >5% of users
- Cost exceeds budget by >50%

**Rollback Steps:**
1. Activate feature flag to disable Auth0
2. Re-enable old authentication system
3. Invalidate all OAuth sessions (force re-login)
4. Restore database backup if needed
5. Notify users of temporary service disruption

**Partial Rollback Option:**
- Keep Auth0 for new users only
- Revert existing users to old system
- Investigate and fix issues before re-enabling

**Data Preservation:**
- Auth0 user profiles exported daily to S3
- Token usage logs retained for 90 days
- Can reconstruct state from exports

**Timeline:**
- Can rollback to old system in <1 hour
- Full data restoration: 2-4 hours

## Validation and Success Criteria

### Metrics to Track

**Security Metrics:**
- Authentication success rate: Target >99.5%
- Failed authentication attempts: Monitor for brute force patterns
- MFA adoption rate: Target 80% of users within 6 months
- Anomaly detection events: Track and investigate all flagged events
- Token refresh rate: Should match session duration patterns

**Business Metrics:**
- Enterprise deals closed (with SSO): Baseline 0, target 5+ in 6 months
- Social login adoption: Target 40% of new signups within 3 months
- Password reset tickets: Reduce from 15% to <5% of support volume
- Time to complete signup: Reduce by 30% with social login

**Technical Metrics:**
- Authentication latency: <200ms for token validation
- Auth0 uptime: >99.9% (per SLA)
- API rate limit buffer: Maintain 30% headroom
- Token generation time: <100ms

**User Satisfaction:**
- Authentication-related support tickets: Reduce by 70%
- User-reported auth issues: <1% of users
- Enterprise customer satisfaction with SSO: >8/10

### Success Indicators

**3 Months (Short-term):**
- All users migrated to Auth0
- Zero security incidents related to authentication
- Social login represents 35%+ of new signups
- Support tickets reduced by 60%

**6 Months (Medium-term):**
- 5+ enterprise customers using SSO
- MFA adoption at 70%+
- Authentication success rate consistently >99.5%
- Team comfortable with OAuth and Auth0

**12 Months (Long-term):**
- SOC 2 Type II certification obtained
- Third-party integrations using OAuth scopes
- Passwordless options (magic links) available
- Zero authentication-related security breaches

### Review Schedule

- **Weekly during migration** (Feb-March 2025): Monitor migration progress, address issues
- **30-day review** (April 20, 2025): Evaluate migration success, user feedback
- **90-day review** (June 20, 2025): Assess business impact, security improvements
- **6-month review** (September 20, 2025): Full retrospective, SOC 2 readiness check
- **Quarterly reviews thereafter**: Review security posture, cost, and evolving requirements

## References

### Internal References
- [Authentication Migration Plan](https://docs.internal/auth-migration)
- [OAuth Scope Definitions](https://docs.internal/oauth-scopes)
- [Auth0 Runbook](https://docs.internal/auth0-ops)
- [Security Compliance Checklist](https://docs.internal/security-compliance)

### External References
- [OAuth 2.1 Specification](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-v2-1-07)
- [RFC 7636: Proof Key for Code Exchange](https://datatracker.ietf.org/doc/html/rfc7636)
- [Auth0 Documentation](https://auth0.com/docs)
- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)

### Tools and Resources
- Auth0 for identity provider
- auth0-js SDK for web
- react-native-auth0 for mobile
- Redis for token blocklist
- Datadog for Auth0 log streaming
- Postman for OAuth flow testing

## Notes

### Open Questions Resolved
- ✓ Which OAuth flows to support? Answer: Authorization Code with PKCE for all clients
- ✓ How long should tokens live? Answer: 15min access, 30-day refresh with rotation
- ✓ Self-hosted vs managed? Answer: Managed (Auth0) for operational efficiency
- ✓ Migration strategy for existing users? Answer: Gradual rollout with feature flags

### Future Considerations
- Implement passwordless authentication (magic links, WebAuthn) in 6-12 months
- Add biometric authentication for mobile apps
- Explore customer-managed encryption keys for enterprise
- Consider Auth0 Actions for custom authentication logic
- Evaluate device fingerprinting for additional security
- Plan for multi-region Auth0 deployment for global users

### Assumptions
- Auth0 maintains 99.99% SLA
- Team can learn OAuth 2.1 in 1-2 weeks
- Users will accept SSO authentication flow
- Social login providers (Google, Microsoft) remain stable
- Auth0 pricing remains competitive
- No major OAuth security vulnerabilities discovered

### Dependencies
- Requires budget approval for Auth0 ($800/month)
- Need 2 engineers allocated for 6 weeks
- Requires Redis infrastructure for token management
- Depends on Datadog for log streaming
- Need custom domain (auth.ourapp.com) configured

---

*Date: 2025-02-05*
*Deciders: Security Lead, Tech Lead, CTO*
*Status: accepted*
*Completion Date: 2025-03-20*
