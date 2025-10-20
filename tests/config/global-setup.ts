import { chromium, FullConfig } from '@playwright/test';
import path from 'path';

/**
 * Global setup for Playwright tests
 *
 * This setup runs before all tests and prepares the testing environment,
 * including directory setup and initial browser configuration.
 */
async function globalSetup(config: FullConfig) {
  console.log('🚀 Starting Playwright global setup...');

  const browsers = [chromium];

  // Setup artifact directories
  const artifactsDir = path.join(config.projects[0]?.outputDir || 'test-results', 'artifacts');

  try {
    // Ensure artifact directories exist
    const fs = require('fs').promises;
    await fs.mkdir(path.join(artifactsDir, 'screenshots', 'baseline'), { recursive: true });
    await fs.mkdir(path.join(artifactsDir, 'screenshots', 'current'), { recursive: true });
    await fs.mkdir(path.join(artifactsDir, 'screenshots', 'diff'), { recursive: true });
    await fs.mkdir(path.join(artifactsDir, 'logs'), { recursive: true });
    await fs.mkdir(path.join(artifactsDir, 'traces'), { recursive: true });

    console.log('✅ Artifact directories created');
  } catch (error) {
    console.warn('⚠️ Warning: Could not create artifact directories:', error);
  }

  // Launch browsers to warm them up
  for (const browserType of browsers) {
    try {
      const browser = await browserType.launch();
      console.log(`🌐 ${browserType.name()} browser warmed up`);
      await browser.close();
    } catch (error) {
      console.warn(`⚠️ Warning: Could not warm up ${browserType.name()} browser:`, error);
    }
  }

  console.log('✅ Playwright global setup complete');
}

export default globalSetup;