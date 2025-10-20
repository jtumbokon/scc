---
id: skill-001
type: skill
version: 1.0.0
description: Advanced dependency analysis and graph management for the modular system
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-19
---

# Dependency Analyzer Skill (skill-001)

## Purpose
Provides comprehensive dependency analysis, graph management, and relationship tracking for the Super-Claude hierarchical system.

## Core Capabilities

### 1. Dependency Graph Construction
- **Automatic Discovery**: Scans all modules and their metadata
- **Relationship Mapping**: Identifies parent-child dependencies
- **Circular Dependency Detection**: Prevents infinite loops
- **Version Compatibility**: Ensures compatible module versions
- **Impact Analysis**: Predicts effects of changes

### 2. Graph Visualization
- **Interactive Dependency Trees**: Visual representation of module relationships
- **Impact Visualization**: Shows cascading effects of changes
- **Version Graphs**: Tracks version evolution over time
- **Health Monitoring**: Real-time system health indicators

### 3. Conflict Resolution
- **Version Conflicts**: Detects and resolves version mismatches
- **Dependency Conflicts**: Identifies conflicting requirements
- **Circular References**: Automatically breaks circular dependencies
- **Missing Dependencies**: Highlights missing required modules

## Implementation Details

### Data Structures
```typescript
interface ModuleNode {
  id: string;
  type: 'rule' | 'template' | 'agent' | 'skill' | 'command' | 'hook';
  version: string;
  dependencies: string[];
  dependents: string[];
  metadata: ModuleMetadata;
  health: 'healthy' | 'warning' | 'error';
}

interface DependencyEdge {
  from: string;
  to: string;
  type: 'parent' | 'child' | 'peer' | 'conflict';
  strength: 'weak' | 'medium' | 'strong';
  version_constraint: string;
}

interface GraphMetrics {
  total_nodes: number;
  total_edges: number;
  max_depth: number;
  circular_dependencies: number;
  orphaned_nodes: number;
  health_score: number;
}
```

### Analysis Algorithms
1. **Topological Sort**: For dependency ordering
2. **Depth-First Search**: For circular dependency detection
3. **Breadth-First Search**: For impact analysis
4. **Dijkstra's Algorithm**: For optimal update paths

## Usage Examples

### Basic Dependency Analysis
```python
# Analyze current system state
analyzer = DependencyAnalyzer()
graph = analyzer.build_graph()

# Check for circular dependencies
circular_deps = analyzer.detect_circular_dependencies(graph)
if circular_deps:
    analyzer.resolve_circular_dependencies(circular_deps)

# Get impact analysis for module update
impact = analyzer.analyze_impact(
    module_id="naming-conventions",
    new_version="1.1.0",
    graph=graph
)
```

### Visualizing Dependencies
```python
# Generate dependency visualization
visualizer = GraphVisualizer()
visualizer.create_dependency_graph(
    graph=graph,
    output_format="svg",
    highlight_modules=["naming-conventions", "code-style"]
)

# Create impact visualization
visualizer.create_impact_analysis(
    module_id="security-rules",
    change_type="major_update",
    graph=graph
)
```

## Integration Points

### Required Modules
- All modules with valid metadata
- Version history registry
- Update log system

### Compatible Tools
- Graphviz (for visualization)
- NetworkX (for graph analysis)
- D3.js (for interactive visualizations)
- PlantUML (for documentation diagrams)

### Output Formats
- JSON (structured data)
- SVG/DOT (visualizations)
- CSV (metrics and reports)
- HTML (interactive dashboards)

## Performance Optimization

### Caching Strategy
- **Module Metadata Cache**: Cache module information
- **Graph Cache**: Store computed dependency graphs
- **Impact Analysis Cache**: Cache common impact analyses
- **Version Comparison Cache**: Cache version compatibility checks

### Parallel Processing
- **Multi-threaded Analysis**: Parallel module scanning
- **Concurrent Validation**: Simultaneous rule validation
- **Batch Processing**: Process modules in batches
- **Async Operations**: Non-blocking I/O operations

## Error Handling

### Common Issues
1. **Malformed Metadata**: Invalid module metadata
2. **Missing Dependencies**: Required modules not found
3. **Version Conflicts**: Incompatible version requirements
4. **Circular References**: Infinite dependency loops

### Resolution Strategies
1. **Automatic Fixes**: Apply known fix patterns
2. **User Prompts**: Request user decisions for conflicts
3. **Fallback Modes**: Graceful degradation
4. **Rollback Support**: Revert to previous stable state

## Monitoring and Alerts

### Health Metrics
- **Dependency Health**: Percentage of healthy dependencies
- **Version Compatibility**: Module version compatibility score
- **Update Success Rate**: Success rate of cascade updates
- **System Stability**: Overall system stability indicator

### Alert Conditions
- **Circular Dependencies Detected**: Immediate alert
- **Broken Dependencies**: High priority alert
- **Version Conflicts**: Medium priority alert
- **Orphaned Modules**: Low priority alert

## API Reference

### Core Methods
```typescript
class DependencyAnalyzer {
  buildGraph(): DependencyGraph
  analyzeImpact(moduleId: string, changes: Change[]): ImpactAnalysis
  detectCircularDependencies(): CircularDependency[]
  resolveConflicts(conflicts: Conflict[]): Resolution[]
  validateIntegrity(): ValidationResult
  optimizeGraph(): OptimizationResult
}
```

### Event Handlers
```typescript
interface DependencyEvents {
  onGraphUpdated: (graph: DependencyGraph) => void
  onConflictDetected: (conflict: Conflict) => void
  onCircularDependency: (cycle: CircularDependency) => void
  onVersionMismatch: (mismatch: VersionMismatch) => void
}
```

## Best Practices

### When to Use
- **Before Module Updates**: Analyze impact before making changes
- **After System Changes**: Validate system integrity after updates
- **Regular Maintenance**: Periodic health checks
- **Troubleshooting**: Diagnose complex dependency issues

### Performance Tips
- **Cache Results**: Cache expensive analysis operations
- **Incremental Updates**: Update graph incrementally when possible
- **Parallel Processing**: Use multi-threading for large graphs
- **Selective Analysis**: Analyze only relevant parts of the graph

---

**This skill ensures robust dependency management and system integrity for the modular hierarchy.**