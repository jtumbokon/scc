---
id: rule-031
type: rule
version: 1.0.0
description: PostgreSQL function parameter changes require DROP FUNCTION before CREATE - never use CREATE OR REPLACE for parameter name changes
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# PostgreSQL Function Parameter Changes Rule (rule-031)

## Purpose
PostgreSQL's `CREATE OR REPLACE FUNCTION` has strict limitations when changing function signatures, particularly parameter names. Attempting to change parameter names (even while keeping the same types and order) results in PostgreSQL errors because parameter name changes are treated as signature modifications not allowed with `OR REPLACE`.

The database requires using `DROP FUNCTION` first, then recreating the function with the new signature.

## Requirements

### MUST (Critical)
- **NEVER use `CREATE OR REPLACE FUNCTION`** when changing parameter names
- **ALWAYS use `DROP FUNCTION IF EXISTS`** with the exact current signature before recreating
- **INCLUDE complete function signatures** in DROP statements (parameter types, not just names)
- **USE `IF EXISTS`** to prevent errors if the function doesn't exist
- **CHANGE to `CREATE FUNCTION`** (not `CREATE OR REPLACE`) after dropping

### SHOULD (Important)
- **Use PostgreSQL system types** in DROP statements (e.g., `double precision` not `float`)
- **CREATE rollback migrations** that restore original function signatures
- **TEST migrations** with exact error message signatures when available
- **GROUP function changes** logically in migration files
- **DOCUMENT parameter changes** with clear reasoning

### MAY (Optional)
- **QUERY system catalog** to find exact function signatures
- **USE migration templates** for consistency across function changes
- **VALIDATE function dependencies** before dropping
- **CREATE backup functions** during critical migrations

## Forbidden Pattern

### ❌ NEVER Use CREATE OR REPLACE for Parameter Changes
```sql
-- ❌ FORBIDDEN - Parameter name change with OR REPLACE
CREATE OR REPLACE FUNCTION match_text_chunks (
    query_embedding vector(768),
    p_user_id uuid,
    p_match_threshold float DEFAULT 0.7,
    p_match_count int DEFAULT 10,
    p_embedding_types text[] DEFAULT NULL  -- ❌ Changed from p_content_types
)
RETURNS TABLE (...)
LANGUAGE plpgsql
AS $$
BEGIN
    -- function body
END;
$$;

-- Error: PostgresError: cannot change name of input parameter "p_content_types"
```

## Correct Migration Pattern

### ✅ ALWAYS Drop First, Then Recreate
```sql
-- ✅ CORRECT - Drop existing function with exact signature
DROP FUNCTION IF EXISTS match_text_chunks(vector, uuid, double precision, integer, text[]);

-- ✅ CORRECT - Create new function (not OR REPLACE)
CREATE FUNCTION match_text_chunks (
    query_embedding vector(768),
    p_user_id uuid,
    p_match_threshold float DEFAULT 0.7,
    p_match_count int DEFAULT 10,
    p_embedding_types text[] DEFAULT NULL  -- ✅ New parameter name works
)
RETURNS TABLE (
    chunk_id uuid,
    content text,
    similarity_score float,
    metadata jsonb
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- function body with new parameter names
    RETURN QUERY
    SELECT
        chunks.id,
        chunks.content,
        (query_embedding <=> chunks.embedding) as similarity_score,
        chunks.metadata
    FROM chunks
    WHERE chunks.embedding_type = ANY(p_embedding_types)
      AND (query_embedding <=> chunks.embedding) <= p_match_threshold
    ORDER BY similarity_score DESC
    LIMIT p_match_count;
END;
$$;
```

## Function Signature Mapping

### PostgreSQL Type System Mapping

| Written Type | PostgreSQL System Type | Use in DROP Statement |
|--------------|---------------------|----------------------|
| `vector(768)` | `vector` | `vector` |
| `uuid` | `uuid` | `uuid` |
| `float` | `double precision` | `double precision` |
| `double` | `double precision` | `double precision` |
| `int` | `integer` | `integer` |
| `integer` | `integer` | `integer` |
| `text[]` | `text[]` | `text[]` |
| `varchar(255)` | `character varying(255)` | `character varying(255)` |
| `boolean` | `boolean` | `boolean` |
| `timestamp` | `timestamp without time zone` | `timestamp without time zone` |
| `timestamptz` | `timestamp with time zone` | `timestamp with time zone` |

### Common Function Signatures

```sql
-- Simple function signatures
DROP FUNCTION IF EXISTS simple_function(text);
DROP FUNCTION IF EXISTS user_function(uuid, integer);
DROP FUNCTION IF EXISTS search_function(vector, double precision);

-- Complex function signatures
DROP FUNCTION IF EXISTS complex_function(
    uuid,
    integer[],
    text,
    double precision DEFAULT 0.5,
    boolean DEFAULT false
);

-- Function with variadic parameters
DROP FUNCTION IF EXISTS variadic_function(text, variadic integer[]);

-- Function with table return type
DROP FUNCTION IF EXISTS table_return_function(uuid)
RETURNS TABLE (id uuid, name text, created_at timestamp);
```

## Migration Scenarios

### Scenario 1: Parameter Name Changes
```sql
-- ❌ BEFORE (Failed approach)
CREATE OR REPLACE FUNCTION process_data(
    input_data jsonb,
    p_user_id uuid,      -- Changing from user_id
    processing_type text  -- Changing from type
);

-- ✅ AFTER (Correct approach)
-- Drop with exact old signature
DROP FUNCTION IF EXISTS process_data(jsonb, uuid, text);

-- Recreate with new parameter names
CREATE FUNCTION process_data(
    input_data jsonb,
    p_user_id uuid,      -- ✅ New name
    processing_type text  -- ✅ New name
)
RETURNS TABLE (
    result jsonb,
    processed_at timestamp
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Function implementation using new parameter names
    RETURN QUERY
    SELECT
        input_data || jsonb_build_object(
            'processed_by', p_user_id,
            'processing_type', processing_type,
            'processed_at', NOW()
        ) as result,
        NOW() as processed_at;
END;
$$;
```

### Scenario 2: Parameter Type Changes
```sql
-- Change vector dimensions and type
-- Drop with old signature
DROP FUNCTION IF EXISTS similarity_search(vector, double precision, integer);

-- Recreate with new types
CREATE FUNCTION similarity_search(
    query_vector vector(1536),    -- ✅ Changed dimensions
    similarity_threshold numeric,  -- ✅ Changed from double precision
    max_results int               -- ✅ Same type
)
RETURNS TABLE (
    id uuid,
    content text,
    score float
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Function implementation
    RETURN QUERY
    SELECT
        docs.id,
        docs.content,
        (query_vector <=> docs.embedding) as score
    FROM documents docs
    WHERE (query_vector <=> docs.embedding) <= similarity_threshold
    ORDER BY score DESC
    LIMIT max_results;
END;
$$;
```

### Scenario 3: Adding/Removing Parameters
```sql
-- Add new optional parameter
-- Drop with current signature
DROP FUNCTION IF EXISTS send_notification(uuid, text);

-- Recreate with additional parameter
CREATE FUNCTION send_notification(
    user_id uuid,
    message text,
    priority text DEFAULT 'normal'  -- ✅ Added parameter
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    -- Implementation using new parameter
    INSERT INTO notifications (user_id, message, priority, created_at)
    VALUES (user_id, message, priority, NOW());

    RETURN TRUE;
END;
$$;
```

### Scenario 4: Multiple Function Updates
```sql
-- Multiple related functions in one migration

-- Drop all functions first
DROP FUNCTION IF EXISTS match_documents(vector, uuid, double precision, integer, text[]);
DROP FUNCTION IF EXISTS rank_results(uuid[], double precision);
DROP FUNCTION IF EXISTS process_embedding(vector);

-- Recreate all functions with updated signatures
CREATE FUNCTION match_documents(
    query_embedding vector(768),
    user_id uuid,
    match_threshold float DEFAULT 0.7,
    max_results int DEFAULT 10,
    content_filters text[] DEFAULT NULL
)
RETURNS TABLE (
    document_id uuid,
    title text,
    content_preview text,
    relevance_score float
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Implementation
END;
$$;

CREATE FUNCTION rank_results(
    document_ids uuid[],
    boost_factor numeric DEFAULT 1.0
)
RETURNS TABLE (
    document_id uuid,
    rank_score numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Implementation
END;
$$;

CREATE FUNCTION process_embedding(
    text_content text,
    embedding_model text DEFAULT 'text-embedding-ada-002'
)
RETURNS vector(1536)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Implementation
END;
$$;
```

## Debugging Function Signatures

### Query System Catalog for Exact Signatures
```sql
-- Find exact function signatures
SELECT
    p.proname as function_name,
    pg_get_function_identity_arguments(p.oid) as signature,
    pg_get_function_result(p.oid) as return_type,
    p.prosrc as source_code
FROM pg_proc p
WHERE p.proname = 'match_text_chunks'
ORDER BY p.proname;

-- Find all functions with specific pattern
SELECT
    p.proname,
    pg_get_function_identity_arguments(p.oid) as signature,
    pg_get_userbyid(p.proowner)::text as owner
FROM pg_proc p
WHERE p.proname LIKE '%match%'
  AND pg_get_function_identity_arguments(p.oid) LIKE '%vector%';

-- Find overloaded functions (same name, different signatures)
SELECT
    p.proname,
    pg_get_function_identity_arguments(p.oid) as signature,
    oid
FROM pg_proc p
WHERE p.proname = 'search_function'
ORDER BY oid;
```

### Function Dependencies
```sql
-- Find functions that depend on other functions
SELECT
    ns.nspname as schema_name,
    p.proname as function_name,
    pg_get_function_identity_arguments(p.oid) as signature,
    d.refobjid::regproc as depends_on
FROM pg_proc p
JOIN pg_namespace ns ON p.pronamespace = ns.oid
JOIN pg_depend d ON d.objid = p.oid
WHERE d.deptype = 'e'
  AND d.refclassid = 'pg_proc'::regclass;
```

## Migration Templates

### Standard Migration Template
```sql
-- Custom SQL migration file: update_function_parameters.sql
-- Update match_text_chunks function: Renamed p_content_types to p_embedding_types
-- Changed parameter name to better reflect actual usage for embedding type filtering

-- Step 1: Drop existing function with exact signature
DROP FUNCTION IF EXISTS match_text_chunks(
    vector,
    uuid,
    double precision,
    integer,
    text[]
);

-- Step 2: Recreate function with new parameter names
CREATE FUNCTION match_text_chunks(
    query_embedding vector(768),
    p_user_id uuid,
    p_match_threshold float DEFAULT 0.7,
    p_match_count int DEFAULT 10,
    p_embedding_types text[] DEFAULT NULL  -- Renamed from p_content_types
)
RETURNS TABLE (
    chunk_id uuid,
    content text,
    similarity_score float,
    metadata jsonb
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Function implementation using new parameter names
    RETURN QUERY
    SELECT
        chunks.id,
        chunks.content,
        (query_embedding <=> chunks.embedding) as similarity_score,
        chunks.metadata
    FROM chunks
    WHERE chunks.user_id = p_user_id
      AND (p_embedding_types IS NULL OR chunks.embedding_type = ANY(p_embedding_types))
      AND (query_embedding <=> chunks.embedding) <= p_match_threshold
    ORDER BY similarity_score DESC
    LIMIT p_match_count;
END;
$$;

-- Step 3: Add comments for documentation
COMMENT ON FUNCTION match_text_chunks(vector, uuid, double precision, integer, text[]) IS
'Matches text chunks based on embedding similarity. Updated to use p_embedding_types parameter for better clarity.';
```

### Down Migration Template
```sql
-- Down migration: restore_original_function_parameters.sql
-- Restore original parameter names for match_text_chunks function

-- Drop current function
DROP FUNCTION IF EXISTS match_text_chunks(vector, uuid, double precision, integer, text[]);

-- Recreate with original parameter names
CREATE FUNCTION match_text_chunks(
    query_embedding vector(768),
    p_user_id uuid,
    p_match_threshold float DEFAULT 0.7,
    p_match_count int DEFAULT 10,
    p_content_types text[] DEFAULT NULL  -- ✅ Restore original name
)
RETURNS TABLE (
    chunk_id uuid,
    content text,
    similarity_score float,
    metadata jsonb
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Original function implementation
    RETURN QUERY
    SELECT
        chunks.id,
        chunks.content,
        (query_embedding <=> chunks.embedding) as similarity_score,
        chunks.metadata
    FROM chunks
    WHERE chunks.user_id = p_user_id
      AND (p_content_types IS NULL OR chunks.content_type = ANY(p_content_types))
      AND (query_embedding <=> chunks.embedding) <= p_match_threshold
    ORDER BY similarity_score DESC
    LIMIT p_match_count;
END;
$$;
```

## Rollback and Recovery Strategies

### Safe Migration Practices
```sql
-- Create backup function before dropping
CREATE OR REPLACE FUNCTION match_text_chunks_backup AS $$
BEGIN
    -- Copy current function body here
    RETURN TABLE (chunk_id uuid, content text, similarity_score float, metadata jsonb);
END;
$$ LANGUAGE plpgsql;

-- Test new function with temporary name
CREATE FUNCTION match_text_chunks_test(...) AS $$
BEGIN
    -- New implementation
END;
$$ LANGUAGE plpgsql;

-- Test the new function
SELECT * FROM match_text_chunks_test(...) LIMIT 1;

-- If tests pass, proceed with actual migration
DROP FUNCTION IF EXISTS match_text_chunks(...);
CREATE FUNCTION match_text_chunks(...) AS $$
BEGIN
    -- New implementation
END;
$$ LANGUAGE plpgsql;

-- Keep backup for recovery if needed
-- DROP FUNCTION IF EXISTS match_text_chunks_backup;
```

### Recovery from Failed Migration
```sql
-- If migration fails, recover with backup
DROP FUNCTION IF EXISTS match_text_chunks;
CREATE OR REPLACE FUNCTION match_text_chunks AS $$
BEGIN
    -- Restore from backup implementation
    RETURN TABLE (chunk_id uuid, content text, similarity_score float, metadata jsonb);
END;
$$ LANGUAGE plpgsql;
```

## Validation Checklist
- [ ] Never use `CREATE OR REPLACE FUNCTION` for parameter changes
- [ ] Always use `DROP FUNCTION IF EXISTS` with exact signature
- [ ] Use correct PostgreSQL system types in DROP statements
- [ ] Change to `CREATE FUNCTION` after dropping
- [ ] Include complete parameter type signatures
- [ ] Test function behavior after migration
- [ ] Create rollback migration for parameter changes
- [ ] Validate function dependencies before dropping
- [ ] Document changes with clear reasoning
- [ ] Use system catalog queries to verify signatures when unsure

## Real-World Example

This rule comes from a real migration where changing `p_content_types` to `p_embedding_types` failed:

```sql
-- ❌ FAILED APPROACH
CREATE OR REPLACE FUNCTION match_text_chunks (
    query_embedding vector(768),
    p_user_id uuid,
    p_match_threshold float DEFAULT 0.7,
    p_match_count int DEFAULT 10,
    p_embedding_types text[] DEFAULT NULL  -- Changed from p_content_types
);

-- Error: PostgresError: cannot change name of input parameter "p_content_types"
-- Hint: Use DROP FUNCTION match_text_chunks(vector,uuid,double precision,integer,text[]) first.

-- ✅ WORKING APPROACH
DROP FUNCTION IF EXISTS match_text_chunks(vector, uuid, double precision, integer, text[]);

CREATE FUNCTION match_text_chunks (
    query_embedding vector(768),
    p_user_id uuid,
    p_match_threshold float DEFAULT 0.7,
    p_match_count int DEFAULT 10,
    p_embedding_types text[] DEFAULT NULL  -- ✅ Now works
);
```

By following this rule, PostgreSQL function migrations will work reliably and prevent signature change errors that can block database deployments.