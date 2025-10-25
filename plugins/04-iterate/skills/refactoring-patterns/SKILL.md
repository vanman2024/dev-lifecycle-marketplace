---
name: Refactoring Patterns
description: Common refactoring patterns and code improvement techniques. Use when refactoring code, improving structure, or when user mentions refactoring, code smells, or code quality improvements.
allowed-tools: Read(*), Write(*), Edit(*), Bash(*)
---

# Refactoring Patterns

This skill provides common refactoring patterns, code smell detection, and structural improvement techniques.

## What This Skill Provides

### 1. Code Smell Detection
- Identify duplicate code
- Detect complex functions
- Find poor naming
- Spot structural issues

### 2. Refactoring Patterns
- Extract Method
- Extract Class
- Rename for Clarity
- Simplify Conditionals
- Remove Duplication

### 3. Structural Improvements
- Module organization
- Dependency management
- Interface clarity
- Separation of concerns

### 4. Refactoring Scripts
- `detect-duplicates.sh` - Find duplicate code
- `complexity-check.sh` - Measure function complexity
- `naming-analysis.sh` - Analyze naming quality

## Instructions

### Detecting Code Smells

When analyzing code for refactoring opportunities:

1. **Long Methods** (> 50 lines)
   - Break into smaller functions
   - Use Extract Method pattern

2. **Duplicate Code**
   - Identify repeated patterns
   - Extract to shared utility

3. **Complex Conditionals**
   - Simplify with guard clauses
   - Use polymorphism or strategy pattern

4. **Poor Naming**
   - Use descriptive names
   - Follow naming conventions

### Common Refactoring Patterns

#### Extract Method

**Before:**
```javascript
function processOrder(order) {
  // validate
  if (!order.items) return false;
  if (!order.customer) return false;

  // calculate
  let total = 0;
  for (let item of order.items) {
    total += item.price * item.quantity;
  }

  // save
  db.save(order);
}
```

**After:**
```javascript
function processOrder(order) {
  if (!validateOrder(order)) return false;
  const total = calculateTotal(order.items);
  saveOrder(order);
}

function validateOrder(order) {
  return order.items && order.customer;
}

function calculateTotal(items) {
  return items.reduce((sum, item) =>
    sum + (item.price * item.quantity), 0);
}

function saveOrder(order) {
  db.save(order);
}
```

#### Simplify Conditionals

**Before:**
```python
if user.is_active and user.has_permission and not user.is_banned:
    allow_access()
else:
    deny_access()
```

**After:**
```python
def can_access(user):
    return user.is_active and user.has_permission and not user.is_banned

if can_access(user):
    allow_access()
else:
    deny_access()
```

#### Extract Class

**Before:**
```javascript
class User {
  name;
  email;
  street;
  city;
  zip;

  getAddress() {
    return `${this.street}, ${this.city} ${this.zip}`;
  }
}
```

**After:**
```javascript
class Address {
  constructor(street, city, zip) {
    this.street = street;
    this.city = city;
    this.zip = zip;
  }

  toString() {
    return `${this.street}, ${this.city} ${this.zip}`;
  }
}

class User {
  name;
  email;
  address;

  constructor(name, email, address) {
    this.name = name;
    this.email = email;
    this.address = address;
  }
}
```

## Refactoring Checklist

When refactoring code:

- [ ] Preserve existing functionality (no behavior changes)
- [ ] Run existing tests after each change
- [ ] Improve readability and maintainability
- [ ] Reduce complexity where possible
- [ ] Maintain backward compatibility
- [ ] Update documentation if structure changes
- [ ] Add tests for new extracted methods

## Complexity Metrics

**Cyclomatic Complexity** - Number of paths through code
- 1-10: Simple, low risk
- 11-20: Moderate, medium risk
- 21-50: Complex, high risk
- 50+: Very complex, very high risk

**Target**: Keep functions under complexity of 10

## Best Practices

- Refactor in small, incremental steps
- Run tests after each refactoring
- Commit refactorings separately from features
- Don't change functionality during refactoring
- Use descriptive names for extracted methods
- Keep functions focused on single responsibility

## Success Criteria

- ✅ Code smells are identified and addressed
- ✅ Functions are small and focused
- ✅ Duplication is eliminated
- ✅ Naming is clear and descriptive
- ✅ Complexity is reduced
- ✅ Tests still pass after refactoring

---

**Plugin**: 04-iterate
**Skill Type**: Patterns + Analysis
**Auto-invocation**: Yes (via description matching)
