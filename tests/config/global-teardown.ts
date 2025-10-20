import { FullConfig } from '@playwright/test';
import path from 'path';

/**
 * Global teardown for Playwright tests
 *
 * This teardown runs after all tests and cleans up resources,
 * including log collection and artifact organization.
 */
async function globalTeardown(config: FullConfig) {
  console.log('🧹 Starting Playwright global teardown...');

  try {
    const fs = require('fs').promises;
    const artifactsDir = path.join(config.projects[0]?.outputDir || 'test-results', 'artifacts');

    // Generate a summary report
    const summary = {
      timestamp: new Date().toISOString(),
      testRunComplete: true,
      artifactsDirectory: artifactsDir,
      screenshotCount: await countFiles(path.join(artifactsDir, 'screenshots')),
      logCount: await countFiles(path.join(artifactsDir, 'logs')),
      traceCount: await countFiles(path.join(artifactsDir, 'traces')),
    };

    await fs.writeFile(
      path.join(artifactsDir, 'summary.json'),
      JSON.stringify(summary, null, 2)
    );

    console.log('📊 Teardown summary generated');
    console.log(`   - Screenshots: ${summary.screenshotCount}`);
    console.log(`   - Logs: ${summary.logCount}`);
    console.log(`   - Traces: ${summary.traceCount}`);

  } catch (error) {
    console.warn('⚠️ Warning: Could not generate teardown summary:', error);
  }

  console.log('✅ Playwright global teardown complete');
}

async function countFiles(dir: string): Promise<number> {
  try {
    const fs = require('fs').promises;
    const files = await fs.readdir(dir);
    return files.length;
  } catch {
    return 0;
  }
}

export default globalTeardown;