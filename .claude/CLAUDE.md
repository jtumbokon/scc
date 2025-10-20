# CLAUDE.md - Super-Claude Hierarchical System Root Configuration

## System Overview

This project uses a **hierarchical, modular template system** with automatic cascade updates, agent orchestration, and self-maintaining registry. You are the intelligence that maintains this system.

**Version**: 2.3.0
**Last Updated**: 2025-10-20
**Status**: Production Ready with Complete Playwright MCP Testing Integration (40 Rules, 11 Agents, 5 Skills, 4 Hooks)

---

## 🎯 Your Core Responsibilities

As Claude Code, you are responsible for:

1. **Maintaining the hierarchical system** - Keep all modules synchronized
2. **Auto-updating the dependency graph** - Register modules automatically via hooks
3. **Orchestrating agent workflows** - Chain agents via dynamic registry lookup
4. **Following established rules and templates** - Apply standards consistently
5. **Cascading updates** - Propagate parent changes to children
6. **Maintaining registry health** - Ensure auto-registration system works

---

## 🚀 Revolutionary Features

This system provides groundbreaking capabilities:

- **🔄 Automatic Cascade Updates** - Parent changes automatically propagate to children
- **📊 Dynamic Agent Discovery** - Hooks read from registry for infinite scalability
- **🤖 Self-Maintaining Registry** - Auto-detects and registers new modules
- **🎯 Version Management** - Semantic versioning with rollback capability
- **⚡ Technology Resilience** - System remains stable when technologies update
- **🛠️ Modular Architecture** - Independent, interchangeable components
- **🔍 Intelligent Validation** - Background health checks and auto-fixing

## 🏗️ System Architecture

```
.claude/
├── CLAUDE.md (THIS FILE)           # Root orchestrator - YOU READ THIS
├── version.json                     # System version tracking
├── modules/
│   ├── rules/                       # Coding standards (L1)
│   ├── templates/                   # Code scaffolds (L1)
│   ├── agents/                      # Sub-agents (L1)
│   ├── skills/                      # Capabilities (L1)
│   ├── commands/                    # Custom commands (L1)
│   └── hooks/                       # Event triggers (L1)
├── registry/
│   ├── dependency-graph.json        # Tracks ALL relationships
│   ├── validation-log.json          # Health monitoring
│   └── update-log.json             # Change log
├── config/
│   ├── cascade-rules.json           # Update propagation rules
│   ├── validation-rules.json        # Integrity checks
│   └── sync-settings.json          # Auto-sync configuration
└── settings.json                    # Hook configuration

enhancements/
└── _queue.json                      # Agent workflow queue
```

### Hierarchy Levels
- **L0 (System Core)**: `CLAUDE.md`, cascade rules
- **L1 (Categories)**: `rules/`, `templates/`, `agents/`, `skills/`, `commands/`, `hooks/`
- **L2 (Individual Modules)**: Specific rules, templates, agents, etc.
- **L3 (Project Files)**: Actual code and documentation using modules

### Module Types
1. **Rules** - Coding standards and conventions (cascade: automatic)
2. **Templates** - Reusable code scaffolds (cascade: conditional)
3. **Agents** - Specialized sub-agents (cascade: manual)
4. **Skills** - Reusable capabilities (cascade: automatic)
5. **Commands** - Custom slash commands (cascade: automatic)
6. **Hooks** - Event-triggered automation (cascade: automatic)

## 🎯 Active Modules

### Core Rules (Automatically Included)

**Original Core Rules:**
- @.claude/modules/rules/naming-conventions.md

**Claude Code Integration Rules (32 rules total):**

**TypeScript & Code Quality (12 rules):**
- @.claude/modules/rules/commenting-best-practices.md (rule-008) - Write meaningful strategic comments that explain 'why' not 'what'
- @.claude/modules/rules/no-explicit-any.md (rule-009) - Prohibit explicit any types to maintain type safety
- @.claude/modules/rules/typescript-explicit-return-types.md (rule-011) - Require explicit return types for TypeScript functions
- @.claude/modules/rules/no-eslint-disable-comments.md (rule-012) - Never use ESLint disable comments - fix root causes
- @.claude/modules/rules/no-ts-expect-error.md (rule-018) - Never use @ts-expect-error comments - fix underlying type issues
- @.claude/modules/rules/react-no-jsx-return-types.md (rule-021) - Never use JSX.Element as return type for React components
- @.claude/modules/rules/no-void-unused-variables.md (rule-030) - Never use void to suppress unused variable warnings
- @.claude/modules/rules/use-refobject-not-mutablerefobject.md (rule-037) - Use RefObject instead of deprecated MutableRefObject
- @.claude/modules/rules/no-eslint-disable-any-rule.md (rule-025) - Never disable ESLint rules with eslint-disable comments
- @.claude/modules/rules/no-eslint-disable-constant-condition.md (rule-026) - Never disable ESLint constant condition rules
- @.claude/modules/rules/no-eslint-disable-unescaped-entities.md (rule-027) - Never disable ESLint unescaped entity rules
- @.claude/modules/rules/no-eslint-disable-exhaustive-deps.md (rule-028) - Never disable ESLint exhaustive-deps rule

**Next.js & React (8 rules):**
- @.claude/modules/rules/nextjs-15-async-params.md (rule-010) - Next.js 15 requires async params and searchParams
- @.claude/modules/rules/no-async-client-components.md (rule-014) - No async client components - separate server/client concerns
- @.claude/modules/rules/nextjs-api-route-data-handling.md (rule-016) - Next.js API routes require explicit JSON parsing
- @.claude/modules/rules/nextjs-redirect-outside-try-catch.md (rule-017) - Next.js redirect() and notFound() must be outside try-catch
- @.claude/modules/rules/use-client-directive-guidelines.md (rule-035) - Use client directive guidelines for Server vs Client components
- @.claude/modules/rules/use-searchparams-requires-suspense.md (rule-038) - Wrap useSearchParams() in Suspense boundaries
- @.claude/modules/rules/prefer-nextjs-image-component.md (rule-032) - Use Next.js Image component instead of HTML img tags
- @.claude/modules/rules/separate-server-client-utilities.md (rule-033) - Separate server-side and client-safe utilities

**UI/UX & Components (4 rules):**
- @.claude/modules/rules/prefer-shadcn-components.md (rule-013) - Prefer shadcn/ui components over custom alternatives
- @.claude/modules/rules/no-inline-styles-use-cn.md (rule-015) - Use cn() utility with conditional Tailwind classes
- @.claude/modules/rules/shadcn-component-styling.md (rule-019) - Use Class Variance Authority (CVA) for styling shadcn/ui components
- @.claude/modules/rules/shadcn-install-components.md (rule-039) - Install shadcn/ui components using official CLI

**Database & ORM (3 rules):**
- @.claude/modules/rules/drizzle-orm-type-safe-queries.md (rule-020) - Use type-safe Drizzle ORM queries with schema imports
- @.claude/modules/rules/drizzle-pgtable-syntax.md (rule-022) - Use proper pgTable syntax with serial primary keys and correct column types
- @.claude/modules/rules/postgresql-function-parameter-changes.md (rule-031) - PostgreSQL function parameter changes require DROP FUNCTION before CREATE

**Build & Development (5 rules):**
- @.claude/modules/rules/escape-apostrophes-quotes.md (rule-023) - Always escape apostrophes and quotes in strings to prevent syntax errors
- @.claude/modules/rules/no-build-commands.md (rule-024) - Never use build commands in code - use proper deployment pipelines
- @.claude/modules/rules/use-package-json-drizzle-scripts.md (rule-036) - Use package.json scripts for Drizzle operations with dotenv-cli
- @.claude/modules/rules/detect-project-type-for-linting.md (rule-034) - Detect project types automatically and use appropriate linting commands
- @.claude/modules/rules/no-toast-in-server-actions.md (rule-029) - Never use toast notifications in Server Actions

### Module Templates (Loaded on Demand)
**Code Templates:**
- component-template.md - Standard component structure
- api-template.md - API endpoint template
- test-template.md - Test file structure
- config-template.md - Configuration file template
- documentation-template.md - README/docs template

**Module Creation Templates:**
- rule-template.md - Template for creating new rule modules
- skill-template.md - Template for creating new skill modules
- hook-template.md - Template for creating new hook modules
- command-template.md - Template for creating new command modules
- agent-template.md - Template for creating new agent modules

### Specialized Agents (Available for Delegation)
- code-reviewer.json - Reviews code against all active rules
- test-generator.json - Creates tests using testing standards
- documentation-writer.json - Generates docs following doc rules
- refactoring-specialist.json - Refactors code maintaining standards
- security-auditor.json - Checks code against security rules

## 🔄 Advanced Cascade Update System

### How Enhanced Cascade Works

**Atomic All-or-None Updates with Comprehensive Validation**

```
Pre-Validation → Backup → Atomic Updates → Post-Validation → Commit
     ↓              ↓          ↓              ↓           ↓
  System Health   Create    All Critical   Consistency  Finalize
    Check        Backup      Files       Check       Transaction
```

### 🚀 New Cascade Capabilities (v2.2.0)

**✅ Unified Cascade Engine**
- Atomic all-or-none updates across all critical files
- Comprehensive pre and post-validation
- Automatic rollback on any failure
- Transaction logging and recovery

**✅ Post-Cascade Validation System**
- Cross-file consistency verification
- Automatic issue detection and correction
- Health monitoring after each cascade
- Comprehensive reporting and alerts

**✅ Single Source of Truth Pattern**
- dependency-graph.json as authoritative source
- Automatic regeneration of derived files
- Conflict resolution with source authority
- Real-time synchronization enforcement

**✅ Mandatory Validation Gates**
- Block operations if system consistency compromised
- Pre-operation health and integrity checks
- Post-operation validation and verification
- Auto-fix capabilities with user confirmation

**✅ Comprehensive Testing Framework**
- Unit, integration, and end-to-end tests
- Performance and stress testing
- Regression testing for known issues
- Continuous integration and automated execution

### When to Trigger Cascade

**Automatic cascade when**:
- Rule updated → Update all templates and agents that reference it
- Template updated → Flag all code using that template
- Agent updated → Check if workflow needs adjustment

**Process**:
1. Detect change (hash mismatch)
2. Query `.claude/registry/dependency-graph.json` for children
3. Validate change doesn't break dependencies
4. Update children in topological order
5. Increment versions (semver)
6. Log to update-log.json
7. Notify user of cascade impact

---

## 🤖 Auto-Registry Update System

### CRITICAL INSTRUCTION

**The system now maintains itself automatically through intelligent hooks. Manual registry updates are rarely needed.**

### Hybrid Auto-Registration

The system uses a **hybrid approach** combining:

1. **PostToolUse Hook**: Automatically detects new modules and registers them
2. **SessionStart Validation**: Validates registry integrity on session start
3. **Registry Validator**: Comprehensive health checks and auto-fixing
4. **Manual Override**: Claude can still make manual registry updates when needed

### Automatic Features

```bash
# ✅ Fully Automatic (no action needed):
- New modules auto-registered when created
- Registry validation runs on session start
- Health score calculated and tracked
- Orphaned modules detected and reported
- Common metadata issues auto-fixed
- Background validation every 24 hours

# 🔧 Manual commands when needed:
/list-agents           # Show all registered agents with metadata
/discover-agents       # Find unregistered agents
/validate-registry     # Comprehensive validation
/sync-hierarchy        # Manual cascade update
```

### Registry Self-Healing

The system automatically:
- ✅ Detects new modules in `.claude/modules/`
- ✅ Registers them in `dependency-graph.json` with proper metadata
- ✅ Validates registry integrity every 24 hours
- ✅ Auto-fixes common metadata issues
- ✅ Maintains health score and logs
- ✅ Handles JSON comments and formatting
- ✅ Provides comprehensive validation reports

## 🤖 Agent Orchestration System

### Agent Workflow Pattern

Agents work in **isolated contexts** (separate conversation windows). They communicate via:
- **Queue file**: `enhancements/_queue.json`
- **Status updates**: Agents set status when complete
- **Hooks**: SubagentStop hook reads queue and suggests next agent

### Dynamic Agent Discovery

**Hooks read dependency graph dynamically to discover agents.**

When SubagentStop hook fires:
1. Reads `enhancements/_queue.json`
2. Finds first item with `READY_FOR_*` status
3. Queries `.claude/registry/dependency-graph.json`:
   ```bash
   jq '.modules | to_entries[] |
       select(.value.type == "agent" and
              .value.agent_metadata.triggered_by_status == "$STATUS")'
   ```
4. Suggests that agent to parent context
5. Provides instructions from agent metadata

**This means**: Add new agent → Update dependency graph → Hooks auto-discover it. No hook editing needed!

### Standard Workflow Statuses

```
DRAFT → READY_FOR_ARCH → READY_FOR_BUILD → DONE
```

**Common workflows**:
- **Standard Feature**: PM → Architect → Implementer
- **Security Critical**: PM → Architect → Security Auditor → Implementer
- **Docs Only**: Documentation Writer → Done

### Queue File Format

`enhancements/_queue.json`:
```json
[
  {
    "slug": "feature-name",
    "title": "Human-readable title",
    "status": "READY_FOR_ARCH",
    "created": "2025-10-19T20:00:00Z",
    "updated": "2025-10-19T20:00:00Z",
    "assigned_agent": "architect-review",
    "spec_path": "docs/claude/working-notes/feature-name.md",
    "adr_path": "docs/claude/decisions/ADR-feature-name.md",
    "pr_url": "https://github.com/org/repo/pull/123",
    "notes": ["Additional context"]
  }
]
```

---

## 🔄 Cascade Update Protocol

**Most updates are now automatic. Manual intervention only needed for complex changes.**

### 1. Dependency Analysis
```bash
Read: .claude/registry/dependency-graph.json
Identify: All child modules that depend on this module
Check: Version compatibility requirements
```

### 2. Validation
```bash
Run: Registry validation automatically
Check: No circular dependencies
Verify: Hash matches content
Confirm: All references resolve
```

### 3. Impact Calculation
```bash
Read: dependency relationships
Determine: Propagation type (automatic/manual/conditional)
Plan: Order of cascade propagation (topological sort)
```

### 4. Cascade Execution
```bash
Update: Child modules in dependency order
Increment: Version numbers (semver)
Log: All changes to .claude/registry/update-log.json
Update: .claude/registry/dependency-graph.json
```

### 5. Integrity Verification
```bash
Run: /validate-system command
Check: All dependencies resolved
Confirm: No broken references
Verify: System integrity maintained
```

## 📋 Claude's Operating Instructions

### When Working With Modules:

**🔥 Most registry updates are now AUTOMATIC via hooks!**

1. **CREATE NEW MODULE**:
   - Create the module file with proper frontmatter
   - **PostToolUse hook auto-registers it** in dependency graph
   - Hook extracts metadata and creates registry entry
   - You get notification: `✅ Auto-registered [module-name] ([type])`

2. **MODIFY EXISTING MODULE**:
   - Edit the module file
   - **PostToolUse hook detects changes** and updates registry
   - Hook recalculates hash and updates version
   - **If cascade needed**: Hook alerts you to run `/sync-hierarchy`

3. **MANUAL REGISTRY** (rarely needed):
   - Only for complex dependency changes
   - Update dependency-graph.json manually
   - Follow the protocol below when needed

### Manual Registry Protocol (When Required):

1. **BEFORE MAKING CHANGES**:
   - Read the dependency graph to understand impact
   - Show what will be affected: "This update will cascade to: [list]"
   - Confirm you understand the dependencies

2. **MAKE THE CHANGES**:
   - Update the requested module with proper frontmatter
   - Follow the module's specific structure and standards

3. **AUTOMATIC CASCADE**:
   - Update all dependent children based on cascade rules
   - Increment version numbers following semantic versioning
   - Update dependency graph with new relationships
   - Log all changes to update-log.json

4. **REPORT RESULTS**:
   - Show exactly what was updated: "Updated X module and cascaded to Y children"
   - Display version changes: "naming-conventions v1.0.0 → v1.1.0"
   - Report any conflicts or issues

## ⚡ Available Commands

### System Management
- `/sync-hierarchy` - Manually trigger full cascade update
- `/sync-hierarchy --dry-run` - Preview updates without applying
- `/validate-system` - Check system integrity and auto-fix issues
- `/update-module <name>` - Update specific module with cascade
- `/show-dependencies <name>` - Display dependency tree
- `/rollback <name> <version>` - Revert to previous version

### Registry Management (Self-Maintaining System)

**🔥 Auto-Maintaining Features:**
- New modules auto-registered via PostToolUse hook
- Registry validation runs on session start
- Background health checks every 24 hours
- Common metadata issues auto-fixed

**Manual commands when needed:**
- `/list-agents` - Show all registered agents with metadata and workflows
- `/discover-agents` - Find unregistered agents and suggest registration
- `/validate-registry` - Comprehensive registry integrity validation

### Agent Operations

**Available Agents (Dynamic Discovery):**
- `pm-spec` - Creates specifications from requirements using research
- `architect-review` - Validates designs and creates ADRs
- `implementer-tester` - Implements features with TDD methodology
- `security-auditor` - Security audits and compliance checks
- `documentation-writer` - Creates comprehensive documentation
- `performance-analyst` - Performance analysis and optimization
- `ux-researcher` - User research and design recommendations
- `code-reviewer` - Code review and security analysis

**🎭 Playwright MCP Testing Agents:**
- `e2e-tester` - End-to-end testing specialist using Playwright MCP for browser automation
- `visual-regression-tester` - Visual regression testing specialist for UI change detection
- `ui-debugger` - UI debugging specialist for bug reproduction and resolution

**🤖 Dynamic Workflows:**
- **Standard Feature**: PM → Architect → Implementer
- **Security Critical**: PM → Architect → Security Auditor → Implementer
- **Performance Critical**: PM → Architect → Implementer → Performance Analyst → Documentation
- **UX Critical**: UX Researcher → PM → Architect → Implementer
- **Documentation Only**: Documentation Writer → Complete
- **Code Review**: Code Reviewer → Implementer → Complete

**🎭 Playwright MCP Testing Workflows:**
- **Standard Testing**: Implementer → E2E Tester → Visual Regression Tester → Complete
- **Bug Discovery**: Any Agent → UI Debugger → E2E Tester → Visual Regression Tester → Complete
- **Feature Testing**: Implementer → E2E Tester → Complete (if no visual testing needed)
- **Quality Assurance**: E2E Tester → Visual Regression Tester → Code Reviewer → Complete

## 🎭 Available Skills & Hooks

### 🛠️ Reusable Skills (5 Total)
- **`browser-screenshot`** - Capture and organize browser screenshots via Playwright MCP
- **`console-log-analyzer`** - Extract and interpret browser console logs during debugging
- **`form-filler`** - Automate web form filling with test data using Playwright MCP
- **`playwright-test-generator`** - Generate Playwright test files from interactive flows
- **`visual-diff-checker`** - Compare screenshots for visual changes and UI regressions

### 🪝 Automation Hooks (4 Total)
- **`on-pre-playwright-setup`** - Prepares test environment before Playwright operations
- **`on-post-playwright-cleanup`** - Cleans up resources after Playwright operations
- **`on-playwright-screenshot-taken`** - Processes screenshots and updates visual manifests
- **`on-playwright-console-error`** - Handles console errors and triggers debugging workflows

### 📋 Quality Rules (40 Total)
- **32 Claude Code Rules** - TypeScript, React, Database, and Development standards
- **8 Playwright MCP Rules** - Testing standards, organization, naming, and usage patterns

## 🛡️ Technology Update Resilience

This system is designed to survive technology updates:

1. **Abstraction Layers** - Rules reference concepts, not specific versions
2. **Version Compatibility** - Each module declares compatible versions
3. **Graceful Degradation** - Fallback behaviors when dependencies unavailable
4. **Update Isolation** - Changes tested in isolation before propagation
5. **Migration Scripts** - Auto-conversion for breaking changes

## 📊 Registry System & Integrity

### Auto-Registry Features
The dependency graph system is **self-maintaining**:

1. **Automatic Registration**: New modules detected via PostToolUse hook
2. **Intelligent Validation**: Background checks every 24 hours
3. **Health Monitoring**: Continuous health score calculation
4. **Self-Healing**: Auto-fix of common metadata issues

### Registry Structure
```json
{
  "_schema_version": "2.0",
  "_last_updated": "timestamp",
  "modules": {
    "agent-name": {
      "id": "unique-id",
      "type": "agent|rule|skill|command|hook|template",
      "version": "semver",
      "path": "relative/path",
      "hash": "sha256",
      "agent_metadata": { ... }  // Agent-specific
    }
  },
  "status_mappings": {
    "DRAFT": { "agent": "pm-spec", "next_status": "READY_FOR_ARCH" }
  },
  "agent_workflows": {
    "feature-development": { "steps": [...] }
  },
  "registry_metadata": {
    "auto_registration_enabled": true,
    "validation_enabled": true,
    "last_validation": "timestamp"
  }
}
```

### Validation System
Run `/validate-registry` for comprehensive checks:
- ✅ JSON structure validation
- ✅ Required sections verification
- ✅ Agent metadata completeness
- ✅ Status mapping consistency
- ✅ Workflow integrity
- ✅ File existence verification
- ✅ Orphaned agent detection

### Health Monitoring
- Health score calculation (0-100%)
- Validation logging with timestamps
- Error and warning tracking
- Background validation scheduling

### Regular Validation
Run `/validate-system` regularly to ensure:
- ✅ No circular dependencies
- ✅ All references resolve correctly
- ✅ Version compatibility maintained
- ✅ Hashes match content
- ✅ Registry is up-to-date
- ✅ Auto-registration working properly

### Monitoring
- Update propagation time tracking
- Validation pass rate monitoring
- Conflict frequency analysis
- Rollback success rate measurement
- Registry growth metrics
- Agent usage statistics

## 🎯 Success Metrics

This system is working when:
- All modules follow consistent structure
- Updates cascade automatically without breaking
- Version numbers increment predictably
- System validates without errors
- Technology updates don't break functionality
- Rollback operations restore previous states reliably

## 🚨 Critical Rules & Emergency Procedures

### DO (Always)

✅ **Trust the auto-registry system** - Let hooks handle registration automatically
✅ **Create modules with proper frontmatter** - Include metadata for auto-registration
✅ **Follow established rules and templates** - Apply standards consistently
✅ **Cascade updates when parents change** - Maintain system synchronization
✅ **Validate before completing tasks** - Use `/validate-system` for integrity checks
✅ **Use semantic versioning** - Follow proper version increments
✅ **Update queue file for agent work** - Maintain workflow state
✅ **Monitor system health** - Check validation logs and health scores

### DON'T (Never)

❌ **Manually update registry for simple modules** - Let hooks handle it
❌ **Create circular dependencies** - Break cascade system
❌ **Skip cascade updates** - Causes system inconsistency
❌ **Forget to validate** - Risk breaking dependencies
❌ **Hardcode agent names in hooks** - Use dynamic registry lookup
❌ **Ignore validation warnings** - May indicate serious issues
❌ **Break dependency relationships** - Cascading failures

### Emergency Procedures

If anything breaks:
1. **Check validation logs** - Review `.claude/registry/validation-log.json`
2. **Run comprehensive validation** - Execute `/validate-registry`
3. **Check dependency graph** - Look for circular dependencies
4. **Use rollback if needed** - `/rollback <module> <version>`
5. **Rebuild relationships carefully** - Follow proper dependency patterns
6. **Run full system validation** - `/validate-system --fix`

### Health Monitoring

**Check these metrics regularly**:
- **Registry Health Score**: Should be 90%+ (green), 70-89% (yellow), <70% (red)
- **Agent Count**: Currently 11 registered agents (including 3 Playwright MCP agents)
- **Skill Count**: Currently 5 registered skills (all Playwright MCP skills)
- **Hook Count**: Currently 4 registered hooks (all Playwright MCP hooks)
- **Rule Count**: Currently 40 registered rules (32 Claude Code + 8 Playwright MCP)
- **Workflow Coverage**: 10 workflow templates active (including Playwright MCP testing workflows)
- **Validation Pass Rate**: Should be 100% for normal operation
- **Auto-Registration Success**: PostToolUse hook should register new modules
- **Playwright MCP Integration**: Complete with comprehensive testing automation

---

## 🎓 Workflow Examples

### Example 1: Creating a New Agent

User: "Create an agent for database migrations"

**System Response**:
1. You create `.claude/modules/agents/db-migration.md` with proper frontmatter
2. **PostToolUse hook automatically detects and registers it**
3. Hook outputs: `✅ Auto-registered db-migration (agent) in dependency graph`
4. New agent immediately available for workflows
5. No manual registry updates needed!

### Example 2: Dynamic Agent Workflow

User: "Add user authentication feature"

**System Response**:
1. Create task in `enhancements/_queue.json` with status "DRAFT"
2. Invoke `pm-spec` subagent on "user-authentication"
3. PM completes → Sets status to "READY_FOR_ARCH"
4. **SubagentStop hook reads queue → Queries dependency graph**
5. Hook finds `architect-review` agent for "READY_FOR_ARCH" status
6. Hook suggests: "Use the architect-review subagent on 'user-authentication'"
7. Workflow continues automatically with dynamic agent discovery

### Example 3: System Health Check

User: "Is the system healthy?"

**System Response**:
Run `/list-agents` → Shows all 8 agents with metadata
Run `/validate-registry` → Comprehensive health check
Output example:
```
🔍 Registry Validation:
=====================
✅ JSON structure is valid
✅ All required sections present
✅ All 8 agents validated
✅ All 12 status mappings valid
✅ All 6 workflows complete
✅ No orphaned agents found

📊 System Health Summary:
======================
Total agents: 8
Total workflows: 6
Supported statuses: 12
Health score: 100%
🟢 System health: Excellent
```

### Example 4: Playwright MCP Testing Workflow

User: "I need comprehensive E2E testing for the new user authentication feature"

**System Response**:
1. Create task in `enhancements/_queue.json` with status "DRAFT"
2. Invoke `pm-spec` subagent on "user-authentication-feature"
3. PM completes → Sets status to "READY_FOR_ARCH"
4. **SubagentStop hook reads queue → Queries dependency graph**
5. Hook finds `architect-review` agent for "READY_FOR_ARCH" status
6. **Architect review completes** → Sets status to "READY_FOR_BUILD"
7. **Implementer-tester completes implementation** → Sets status to "READY_FOR_E2E_TEST"
8. **SubagentStop hook discovers e2e-tester agent** → Triggers automated testing
9. **E2E tester agent executes** → Sets status to "READY_FOR_VISUAL_TEST"
10. **Visual regression tester validates** → Sets status to "READY_FOR_MERGE"
11. **Complete testing workflow** with comprehensive reports and artifacts

---

## 💡 Remember

**You are maintaining a revolutionary self-organizing AI system.**

**The Auto-Registry Revolution:**
- ✅ **Create modules → They auto-register** (PostToolUse hook)
- ✅ **Start session → Registry validates** (SessionStart hook)
- ✅ **Background processes → Health monitoring** (Validator)
- ✅ **Add agents → Dynamic discovery** (Registry lookup)
- ✅ **System breaks → Self-healing** (Auto-fix capabilities)

**Your Role Evolution:**
- **Before**: Manual registry maintenance, error-prone
- **Now**: Intelligent oversight, focus on high-value tasks
- **Future**: Purely strategic guidance, system handles operations

**The System is Self-Maintaining Because:**
1. **Hooks detect changes automatically**
2. **Registry updates happen without intervention**
3. **Validation runs continuously in background**
4. **Health scores provide instant feedback**
5. **Dynamic discovery scales infinitely**

This is your job. This is your purpose. Make it seamless. 🚀

**You've successfully implemented a revolutionary self-maintaining AI system with complete Playwright MCP testing integration that represents the future of automated assistance!**