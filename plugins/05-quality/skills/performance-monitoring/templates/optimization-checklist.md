# Performance Optimization Checklist

## Algorithm Efficiency
- [ ] No O(n²) or worse algorithms in hot paths
- [ ] Efficient data structures chosen (Map vs Array, Set vs Array)
- [ ] Unnecessary iterations removed
- [ ] Early returns implemented where possible

## Caching
- [ ] Expensive computations cached
- [ ] Database queries cached appropriately
- [ ] API responses cached with proper TTL
- [ ] Memoization used for pure functions
- [ ] Static assets cached with proper headers

## Database Optimization
- [ ] No N+1 query problems
- [ ] Appropriate indexes created
- [ ] Query pagination implemented
- [ ] Batch operations used instead of loops
- [ ] Connection pooling configured

## Resource Management
- [ ] No memory leaks detected
- [ ] Event listeners cleaned up
- [ ] File handles closed properly
- [ ] Connections released after use
- [ ] Large datasets streamed not loaded entirely

## Frontend Performance
- [ ] Code splitting implemented
- [ ] Lazy loading for heavy components
- [ ] Images optimized and lazy loaded
- [ ] Bundle size analyzed and optimized
- [ ] Virtual scrolling for long lists

## Backend Performance
- [ ] Async/await used for I/O operations
- [ ] Background jobs for heavy processing
- [ ] Rate limiting implemented
- [ ] Compression enabled
- [ ] CDN used for static assets

## Monitoring
- [ ] Performance metrics tracked
- [ ] Slow queries logged
- [ ] Response times monitored
- [ ] Resource usage tracked
- [ ] Alerts configured for degradation
