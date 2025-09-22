import { test, expect } from '@playwright/test';

test('group randomizer functionality', async ({ page }) => {
  // Start a local server for testing
  await page.goto('http://localhost:8080/group-randomizer.html');
  
  // Check that the page loads correctly
  await expect(page).toHaveTitle('Student Group Randomizer');
  await expect(page.getByRole('heading', { name: 'Student Group Randomizer' })).toBeVisible();
  
  // Check that the shuffle button exists
  const shuffleButton = page.getByRole('button', { name: 'Shuffle Groups' });
  await expect(shuffleButton).toBeVisible();
  
  // Check that all 6 groups are present
  for (let i = 1; i <= 6; i++) {
    await expect(page.locator(`.group${i}`)).toBeVisible();
    await expect(page.locator(`.group${i} .group-title`)).toContainText(`Group ${i}`);
  }
  
  // Verify student count
  const studentCards = page.locator('.student-card');
  await expect(studentCards).toHaveCount(29);
  
  // Verify group sizes (Groups 1-5 should have 5 students, Group 6 should have 4)
  for (let i = 1; i <= 5; i++) {
    const groupStudents = page.locator(`.group${i} .student-card`);
    await expect(groupStudents).toHaveCount(5);
  }
  const group6Students = page.locator('.group6 .student-card');
  await expect(group6Students).toHaveCount(4);
  
  // Test shuffle functionality
  const initialFirstStudent = await page.locator('.group1 .student-card').first().textContent();
  await shuffleButton.click();
  const newFirstStudent = await page.locator('.group1 .student-card').first().textContent();
  
  // After shuffling, verify the layout is still correct
  await expect(studentCards).toHaveCount(29);
  for (let i = 1; i <= 5; i++) {
    const groupStudents = page.locator(`.group${i} .student-card`);
    await expect(groupStudents).toHaveCount(5);
  }
  await expect(group6Students).toHaveCount(4);
  
  // Note: We can't reliably test that the students are actually shuffled
  // because random shuffling might occasionally result in the same layout
});