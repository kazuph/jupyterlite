import { expect, test } from '@playwright/test';

test.describe.configure({ timeout: 300_000 });

test('Pyodide demo notebook runs to completion', async ({ page }) => {
  await page.goto('/lab/index.html?reset');

  await page.waitForSelector('#filebrowser');
  const notebookRow = page.locator('.jp-DirListing-item').filter({ hasText: 'pyodide-demo.ipynb' }).first();
  await notebookRow.waitFor({ state: 'visible' });
  await notebookRow.dblclick();

  const kernelDialog = page.getByRole('dialog', { name: 'Select Kernel' });
  let dialogVisible = false;
  try {
    await kernelDialog.waitFor({ state: 'visible', timeout: 30_000 });
    dialogVisible = true;
  } catch (error) {
    dialogVisible = false;
  }

  if (dialogVisible) {
    await kernelDialog.locator('select').selectOption('python');
    const rememberChoice = kernelDialog.getByRole('checkbox', { name: /always start/i });
    if (await rememberChoice.isEnabled()) {
      await rememberChoice.check();
    }
    await kernelDialog.getByRole('button', { name: /select/i }).click();
  }

  await page.waitForSelector('.lm-TabBar-tab', { state: 'visible' });
  await page.locator('.lm-TabBar-tab', { hasText: 'pyodide-demo.ipynb' }).click();

  await page.waitForSelector(
    '.jp-Notebook-ExecutionIndicator[title*="Kernel Status: Idle"]',
  );

  const pyodidePanel = page
    .locator('.jp-NotebookPanel')
    .filter({ hasText: 'Pyodide Runtime Demo' })
    .first();

  const codeCell = pyodidePanel.locator('.jp-Notebook .jp-CodeCell').first();
  await codeCell.click();
  await page.keyboard.press('Shift+Enter');

  const output = pyodidePanel.locator('.jp-Notebook .jp-OutputArea-output').first();
  await expect(output).toContainText('Python version:');
  await expect(output).toContainText('Pyodide platform:');
});
