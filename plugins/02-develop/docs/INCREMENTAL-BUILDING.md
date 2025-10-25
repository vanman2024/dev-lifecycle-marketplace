# Incremental Building with /lifecycle Command

## Smart Detection

The `/multiagent-build-system:lifecycle` command now detects existing plugins and offers safe options.

## Example Scenarios

### Scenario 1: Plugin Doesn't Exist
```bash
/multiagent-build-system:lifecycle develop
```
**Result:** Creates new plugin from scratch

---

### Scenario 2: Plugin Already Exists (like now!)
```bash
/multiagent-build-system:lifecycle develop
```

**Detection:**
```
✅ Plugin 'develop' already exists.

What would you like to do?

1. Add new commands/skills to existing plugin (SAFE)
   - Adds new commands without touching existing ones
   - Adds new skills without overwriting
   - Perfect for incremental development

2. Rebuild from scratch (DESTRUCTIVE - creates backup)
   - Backs up existing: plugins/develop.backup-20251022_173000/
   - Rebuilds entire plugin structure
   - Use if you want to start fresh

3. Cancel
   - Preserves existing plugin
   - No changes made
```

---

## Option 1: Add to Existing (SAFE)

**What happens:**

1. **Skips scaffold creation** - Existing plugin.json, README, etc. preserved
2. **Asks for new commands** - "What new commands to add?"
   - Example: "refactor, optimize"
3. **Creates only new commands** - Existing commands untouched
4. **Asks for new skills** - "What new skills to add?"
   - Example: "performance-analysis"
5. **Creates only new skills** - Existing skills preserved
6. **Validates everything** - Ensures consistency

**Example workflow:**
```
You: /multiagent-build-system:lifecycle develop

System: Plugin exists. Choose option:
You: 1 (Add to existing)

System: What new commands to add?
You: refactor, optimize

System: Creates:
  - plugins/develop/commands/refactor.md ✅
  - plugins/develop/commands/optimize.md ✅
  - Preserves existing 7 commands ✅

System: What new skills to add?
You: performance-analysis

System: Creates:
  - plugins/develop/skills/performance-analysis/ ✅
  - Preserves existing 4 skills ✅

Done! Added 2 commands + 1 skill to existing plugin.
```

---

## Option 2: Rebuild from Scratch (DESTRUCTIVE)

**What happens:**

1. **Backup created automatically:**
   ```
   plugins/develop → plugins/develop.backup-20251022_173000/
   ```

2. **Entire plugin rebuilt:**
   - New plugin.json
   - New README
   - Fresh command structure
   - Fresh skill structure

3. **You must recreate everything**

**Use when:**
- You want to completely redesign the plugin
- You made a mistake and want to start over
- You're okay losing current structure

---

## Option 3: Cancel (SAFE)

**What happens:**
- Nothing changes
- Existing plugin preserved exactly as-is
- You can review/edit manually

---

## Best Practices

### ✅ DO: Use Option 1 (Add to existing)
- Adding new commands to existing plugin
- Adding new skills
- Incremental development
- Building on existing work

### ⚠️ CAUTION: Use Option 2 (Rebuild)
- You have a backup strategy
- You're prepared to recreate everything
- You understand it's destructive

### ✅ DO: Use Option 3 (Cancel)
- You're not sure what to do
- You want to manually edit instead
- You just want to check if plugin exists

---

## Recovery from Accidental Rebuild

If you chose Option 2 by accident:

```bash
# Restore from backup
rm -rf plugins/develop
mv plugins/develop.backup-20251022_173000 plugins/develop
```

---

## Summary

The `/lifecycle` command is now **smart and safe**:
- ✅ Detects existing plugins
- ✅ Offers incremental building (Option 1)
- ✅ Creates backups before destructive actions (Option 2)
- ✅ Allows cancellation (Option 3)

**Never accidentally overwrites your work!**
