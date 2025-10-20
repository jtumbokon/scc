---
id: rule-026
type: rule
version: 1.0.0
description: No while(true) loops - use recursive pump pattern for stream processing instead of disabling no-constant-condition rule
parents: [CLAUDE.md]
children: []
auto_cascade: true
last_updated: 2025-10-20
---

# No ESLint Disable Constant Condition Rule (rule-026)

## Purpose
The ESLint rule `no-constant-condition` prevents loops with constant conditions like `while (true)`. While seemingly useful for infinite loops (like processing streams), this pattern is often a code smell that can hide bugs and make code harder to reason about. Instead of disabling this rule, use recursive patterns that better represent asynchronous, chunk-by-chunk processing.

## Requirements

### MUST (Critical)
- **NEVER disable** the `no-constant-condition` ESLint rule
- **NEVER use** `// eslint-disable-next-line no-constant-condition`
- **NEVER use** `while (true)` loops for stream processing
- **ALWAYS use** recursive pump functions for asynchronous iteration
- **Process streams** with proper base case conditions (`done` from reader)

### SHOULD (Important)
- **Use recursive patterns** that clearly express the start/process/end flow
- **Implement proper error handling** within recursive functions
- **Manage state effectively** across recursive calls when needed
- **Follow async/await patterns** consistently in stream processing

### MAY (Optional)
- **Use async generators** for complex stream processing scenarios
- **Implement backpressure handling** for high-volume streams
- **Add streaming utilities** for common patterns across the application
- **Use third-party stream libraries** when additional functionality is needed

## Core Pattern: Recursive Stream Processing

### ❌ Bad - While True Loop with ESLint Disable
```typescript
// ❌ FORBIDDEN
private async handleSSEStream(response: Response): Promise<void> {
  const reader = response.body?.getReader();
  if (!reader) return;

  try {
    // eslint-disable-next-line no-constant-condition
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;

      const chunk = decoder.decode(value, { stream: true });
      // Process chunk...
    }
  } finally {
    reader.releaseLock();
  }
}

// ❌ ALSO FORBIDDEN - Same issue in different context
async function processWebSocket(socket: WebSocket) {
  // eslint-disable-next-line no-constant-condition
  while (true) {
    const message = await waitForMessage(socket);
    if (message.type === 'close') break;
    processMessage(message);
  }
}
```

### ✅ Good - Recursive Pump Pattern
```typescript
// ✅ CORRECT - Clean recursive stream processing
private async handleSSEStream(response: Response): Promise<void> {
  const reader = response.body?.getReader();
  if (!reader) return;

  const decoder = new TextDecoder();

  // Define recursive pump function
  const pump = async (): Promise<void> => {
    const { done, value } = await reader.read();

    // Base case: stream finished
    if (done) return;

    // Process current chunk
    const chunk = decoder.decode(value, { stream: true });
    await this.processChunk(chunk);

    // Recursive step: process next chunk
    return pump();
  };

  try {
    await pump();
  } finally {
    reader.releaseLock();
  }
}

// ✅ ALSO CORRECT - WebSocket with recursion
async function processWebSocket(socket: WebSocket) {
  const waitForMessage = (): Promise<WebSocketMessage> => {
    return new Promise(resolve => {
      socket.onmessage = (event) => resolve(JSON.parse(event.data));
    });
  };

  const pump = async (): Promise<void> => {
    const message = await waitForMessage(socket);

    if (message.type === 'close') return;

    await processMessage(message);
    return pump();
  };

  await pump();
}
```

## Advanced Recursive Patterns

### Pattern 1: State-Aware Stream Processing
```typescript
// ✅ GOOD - Recursive function with state management
class StreamProcessor {
  private buffer = '';
  private processedCount = 0;

  async processStream(response: Response): Promise<ProcessingResult> {
    const reader = response.body?.getReader();
    if (!reader) throw new Error('No reader available');

    const pump = async (accumulatedData: string[] = []): Promise<string[]> => {
      const { done, value } = await reader.read();

      if (done) {
        return accumulatedData;
      }

      const chunk = new TextDecoder().decode(value, { stream: true });
      const processed = await this.processChunk(chunk);

      return pump([...accumulatedData, processed]);
    };

    try {
      const results = await pump();
      return { results, count: results.length };
    } finally {
      reader.releaseLock();
    }
  }

  private async processChunk(chunk: string): Promise<string> {
    this.buffer += chunk;

    // Process complete messages from buffer
    const messages = this.extractMessages(this.buffer);
    this.buffer = messages.remaining;

    this.processedCount += messages.complete.length;
    return this.formatOutput(messages.complete);
  }

  private extractMessages(buffer: string): { complete: string[], remaining: string } {
    // Implementation for message extraction logic
    const delimiter = '\n\n';
    const delimiterIndex = buffer.lastIndexOf(delimiter);

    if (delimiterIndex === -1) {
      return { complete: [], remaining: buffer };
    }

    const completeMessages = buffer
      .slice(0, delimiterIndex)
      .split(delimiter)
      .filter(msg => msg.trim());

    const remaining = buffer.slice(delimiterIndex + delimiter.length);

    return { complete: completeMessages, remaining };
  }
}
```

### Pattern 2: Error-Resilient Stream Processing
```typescript
// ✅ GOOD - Recursive pattern with robust error handling
class ResilientStreamProcessor {
  async processWithRetry(response: Response, maxRetries = 3): Promise<void> {
    const reader = response.body?.getReader();
    if (!reader) return;

    let retryCount = 0;
    const decoder = new TextDecoder();

    const pump = async (): Promise<void> => {
      try {
        const { done, value } = await reader.read();

        if (done) return;

        const chunk = decoder.decode(value, { stream: true });
        await this.processChunk(chunk);

        // Reset retry count on successful processing
        retryCount = 0;

        return pump();
      } catch (error) {
        console.error('Error processing chunk:', error);

        if (retryCount >= maxRetries) {
          throw new Error(`Max retries (${maxRetries}) exceeded`);
        }

        retryCount++;
        console.log(`Retrying... attempt ${retryCount}/${maxRetries}`);

        // Wait before retrying
        await this.delay(Math.pow(2, retryCount) * 1000);

        return pump();
      }
    };

    try {
      await pump();
    } finally {
      reader.releaseLock();
    }
  }

  private async processChunk(chunk: string): Promise<void> {
    // Implementation that might throw errors
    if (chunk.includes('ERROR')) {
      throw new Error('Simulated processing error');
    }

    console.log('Processed chunk:', chunk.slice(0, 50) + '...');
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
```

### Pattern 3: Async Generator Alternative
```typescript
// ✅ GOOD - Async generator for complex scenarios
class AsyncStreamProcessor {
  async* streamGenerator(reader: ReadableStreamDefaultReader<Uint8Array>): AsyncGenerator<string> {
    const decoder = new TextDecoder();

    while (true) {
      const { done, value } = await reader.read();

      if (done) break;

      const chunk = decoder.decode(value, { stream: true });
      yield chunk;
    }
  }

  async processWithGenerator(response: Response): Promise<void> {
    const reader = response.body?.getReader();
    if (!reader) return;

    try {
      for await (const chunk of this.streamGenerator(reader)) {
        await this.processChunk(chunk);
      }
    } finally {
      reader.releaseLock();
    }
  }

  private async processChunk(chunk: string): Promise<void> {
    // Processing implementation
    console.log('Processing:', chunk);
  }
}
```

## Specific Use Cases

### Use Case 1: Server-Sent Events (SSE)
```typescript
// ✅ GOOD - SSE processing with recursion
class SSEProcessor {
  private eventHandlers = new Map<string, (data: string) => void>();

  onEvent(eventType: string, handler: (data: string) => void): void {
    this.eventHandlers.set(eventType, handler);
  }

  async processSSE(response: Response): Promise<void> {
    const reader = response.body?.getReader();
    if (!reader) return;

    const decoder = new TextDecoder();
    let buffer = '';

    const pump = async (): Promise<void> => {
      const { done, value } = await reader.read();

      if (done) return;

      buffer += decoder.decode(value, { stream: true });
      buffer = this.processBuffer(buffer);

      return pump();
    };

    try {
      await pump();
    } finally {
      reader.releaseLock();
    }
  }

  private processBuffer(buffer: string): string {
    const lines = buffer.split('\n');
    let remainingData = '';

    for (let i = 0; i < lines.length - 1; i++) {
      const line = lines[i].trim();

      if (line.startsWith('data: ')) {
        const data = line.slice(6);
        this.emitEvent('message', data);
      } else if (line.startsWith('event: ')) {
        const eventType = line.slice(7);
        this.emitEvent(eventType, '');
      } else if (line === '') {
        // Empty line indicates end of an event
        this.emitEvent('end', '');
      }
    }

    // Keep the last incomplete line in buffer
    return lines[lines.length - 1];
  }

  private emitEvent(eventType: string, data: string): void {
    const handler = this.eventHandlers.get(eventType);
    if (handler) {
      handler(data);
    }
  }
}
```

### Use Case 2: File Upload Processing
```typescript
// ✅ GOOD - Large file upload with chunked processing
class FileUploadProcessor {
  async processUpload(
    file: File,
    chunkSize = 1024 * 1024, // 1MB chunks
    onProgress?: (progress: number) => void
  ): Promise<void> {
    const totalSize = file.size;
    let processedSize = 0;
    let offset = 0;

    const processChunk = async (): Promise<void> => {
      if (offset >= totalSize) {
        onProgress?.(100);
        return;
      }

      const chunk = file.slice(offset, offset + chunkSize);
      await this.uploadChunk(chunk, offset);

      offset += chunkSize;
      processedSize = Math.min(offset, totalSize);
      const progress = (processedSize / totalSize) * 100;

      onProgress?.(progress);

      return processChunk();
    };

    await processChunk();
  }

  private async uploadChunk(chunk: Blob, offset: number): Promise<void> {
    const formData = new FormData();
    formData.append('chunk', chunk);
    formData.append('offset', offset.toString());

    const response = await fetch('/api/upload', {
      method: 'POST',
      body: formData,
    });

    if (!response.ok) {
      throw new Error(`Upload failed: ${response.statusText}`);
    }
  }
}
```

### Use Case 3: WebSocket Message Processing
```typescript
// ✅ GOOD - WebSocket with proper recursion
class WebSocketProcessor {
  private messageQueue: WebSocketMessage[] = [];
  private isProcessing = false;

  constructor(private socket: WebSocket) {
    this.setupSocketListeners();
  }

  private setupSocketListeners(): void {
    this.socket.onmessage = (event) => {
      const message = JSON.parse(event.data);
      this.messageQueue.push(message);
      this.processQueue();
    };
  }

  private async processQueue(): Promise<void> {
    if (this.isProcessing || this.messageQueue.length === 0) {
      return;
    }

    this.isProcessing = true;

    const processNext = async (): Promise<void> => {
      if (this.messageQueue.length === 0) {
        this.isProcessing = false;
        return;
      }

      const message = this.messageQueue.shift();
      if (!message) {
        this.isProcessing = false;
        return;
      }

      try {
        await this.processMessage(message);
      } catch (error) {
        console.error('Error processing message:', error);
      }

      return processNext();
    };

    await processNext();
  }

  private async processMessage(message: WebSocketMessage): Promise<void> {
    switch (message.type) {
      case 'data':
        await this.handleDataMessage(message);
        break;
      case 'notification':
        await this.handleNotification(message);
        break;
      case 'command':
        await this.handleCommand(message);
        break;
      default:
        console.warn('Unknown message type:', message.type);
    }
  }

  private async handleDataMessage(message: DataMessage): Promise<void> {
    // Implementation for data messages
    console.log('Processing data:', message.payload);
  }

  private async handleNotification(message: NotificationMessage): Promise<void> {
    // Implementation for notifications
    console.log('Notification:', message.text);
  }

  private async handleCommand(message: CommandMessage): Promise<void> {
    // Implementation for commands
    console.log('Command:', message.command, message.args);
  }
}

interface WebSocketMessage {
  type: string;
  [key: string]: any;
}

interface DataMessage extends WebSocketMessage {
  payload: any;
}

interface NotificationMessage extends WebSocketMessage {
  text: string;
}

interface CommandMessage extends WebSocketMessage {
  command: string;
  args: any[];
}
```

## Migration Guide

### Converting While True Loops

**Step 1: Identify the Pattern**
```typescript
// Look for this pattern:
// eslint-disable-next-line no-constant-condition
while (true) {
  const result = await someAsyncOperation();
  if (result.done) break;
  processResult(result);
}
```

**Step 2: Extract to Recursive Function**
```typescript
// Convert to:
const pump = async (): Promise<void> => {
  const result = await someAsyncOperation();
  if (result.done) return;
  processResult(result);
  return pump();
};

await pump();
```

**Step 3: Add State Management if Needed**
```typescript
// Add state tracking through recursion:
const pump = async (state: ProcessingState): Promise<ProcessingState> => {
  const result = await someAsyncOperation();
  if (result.done) return state;

  const newState = processResult(result, state);
  return pump(newState);
};

const finalState = await pump(initialState);
```

## Validation Checklist
- [ ] No `while (true)` loops in the codebase
- [ ] No `eslint-disable-next-line no-constant-condition` comments
- [ ] Stream processing uses recursive pump patterns
- [ ] Async iteration has proper base case conditions
- [ ] Error handling is implemented correctly in recursive functions
- [ ] State management works across recursive calls
- [ ] Memory usage is reasonable for recursive patterns
- [ ] All async operations are properly awaited

## Enforcement
This rule is enforced through:
- ESLint `no-constant-condition` rule configuration
- Code review validation
- Automated testing for stream processing patterns
- Pair programming for complex async scenarios
- Documentation and team education on recursive patterns

Using recursive patterns instead of `while (true)` loops creates more maintainable, testable, and correct asynchronous code while maintaining compliance with linting rules.