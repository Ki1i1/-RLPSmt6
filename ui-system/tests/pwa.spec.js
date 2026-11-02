import { mkdir, writeFile } from 'node:fs/promises'
import { fileURLToPath } from 'node:url'
import { test, expect } from '@playwright/test'
import tailwindConfig from '../tailwind.config.js'

const evidenceDir = fileURLToPath(new URL('../../output/modul-4/', import.meta.url))

test('manifest, ikon, dan instalasi PWA valid', async ({ page, context }) => {
  await page.goto('/')
  const manifestUrl = await page.locator('link[rel="manifest"]').getAttribute('href')
  const manifest = await page.evaluate(async (url) => (await fetch(url)).json(), manifestUrl)
  expect(manifest.name).toContain('SensorNodes')
  expect(manifest.display).toBe('standalone')
  expect(manifest.start_url).toBe('/')
  expect(manifest.scope).toBe('/')
  expect(manifest.theme_color).toBe(tailwindConfig.theme.extend.colors.tech.primary)
  await expect(page.locator('meta[name="theme-color"]')).toHaveAttribute('content', manifest.theme_color)
  expect(manifest.icons.map((icon) => icon.sizes)).toEqual(expect.arrayContaining(['192x192', '512x512']))
  expect(manifest.icons.some((icon) => icon.purpose === 'maskable')).toBe(true)

  for (const icon of manifest.icons) {
    const dimensions = await page.evaluate(async (src) => {
      const image = new Image()
      image.src = src
      await image.decode()
      return `${image.naturalWidth}x${image.naturalHeight}`
    }, icon.src)
    expect(dimensions).toBe(icon.sizes)
  }

  await page.evaluate(() => navigator.serviceWorker.ready)
  const session = await context.newCDPSession(page)
  const { installabilityErrors } = await session.send('Page.getInstallabilityErrors')
  // Context Playwright terisolasi (incognito), sehingga instalasi UI dinonaktifkan.
  // Semua kesalahan manifest/ikon/HTTPS tetap harus gagal dalam tes ini.
  expect(installabilityErrors.filter(({ errorId }) => errorId !== 'in-incognito')).toEqual([])
  await session.detach()
})

test('dashboard dapat dimuat ulang dan dibuka kembali saat offline', async ({ page, context }, testInfo) => {
  const pageErrors = []
  page.on('pageerror', (error) => pageErrors.push(error.message))
  await page.goto('/')
  await expect(page.getByRole('status').filter({ hasText: 'Online' })).toBeVisible()
  await page.evaluate(() => navigator.serviceWorker.ready)
  await page.waitForFunction(() => navigator.serviceWorker.controller !== null)

  const cacheEntries = await page.evaluate(async () => {
    const names = await caches.keys()
    const entries = await Promise.all(names.map(async (name) => {
      const cache = await caches.open(name)
      return (await cache.keys()).map((request) => new URL(request.url).pathname)
    }))
    return entries.flat()
  })
  expect(cacheEntries).toContain('/index.html')
  expect(cacheEntries.some((path) => path.endsWith('.js'))).toBe(true)
  expect(cacheEntries.some((path) => path.endsWith('.css'))).toBe(true)

  await context.setOffline(true)
  await expect(page.getByRole('alert')).toContainText('Anda sedang offline')
  await page.reload({ waitUntil: 'load' })
  await expect(page.getByRole('heading', { name: 'Dashboard Monitoring Suhu' })).toBeVisible()
  await expect(page.getByRole('alert')).toContainText('cache lokal')
  await expect(page.locator('#sensor-grid article')).toHaveCount(3)
  await expect(page.getByRole('article', { name: 'Suhu Ruangan Q2.1' })).toContainText('24.5')
  await expect(page.getByRole('article', { name: 'Suhu Ruangan Q2.2' })).toContainText('28.2')
  await expect(page.getByRole('article', { name: 'Suhu Ruangan Q2.3' })).toContainText('33.2')
  expect(await page.evaluate(() => navigator.onLine)).toBe(false)
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth)).toBe(true)

  await page.getByRole('button', { name: 'Gunakan tampilan ringkas' }).click()
  await expect(page.getByText('INTEGRITY STATUS', { exact: true })).toHaveCount(0)
  await page.getByRole('button', { name: 'Tampilkan detail' }).click()
  await expect(page.getByText('INTEGRITY STATUS', { exact: true })).toHaveCount(3)

  await mkdir(evidenceDir, { recursive: true })
  await page.evaluate(() => window.scrollTo(0, 0))
  await expect(page.getByRole('alert')).toBeInViewport()
  await page.screenshot({ path: `${evidenceDir}/offline-${testInfo.project.name}.png`, fullPage: true })
  await page.close()
  const reopened = await context.newPage()
  reopened.on('pageerror', (error) => pageErrors.push(error.message))
  await reopened.goto('/')
  await expect(reopened.getByRole('alert')).toContainText('Anda sedang offline')
  await expect(reopened.locator('#sensor-grid article')).toHaveCount(3)

  await context.setOffline(false)
  await expect(reopened.getByRole('alert')).toHaveCount(0)
  await expect(reopened.getByRole('status').filter({ hasText: 'Online' })).toBeVisible()
  await reopened.reload()
  await expect(reopened.locator('#sensor-grid article')).toHaveCount(3)
  expect(pageErrors).toEqual([])

  await writeFile(`${evidenceDir}/offline-${testInfo.project.name}.json`, JSON.stringify({
    testedAt: new Date().toISOString(),
    browser: context.browser().version(),
    viewport: testInfo.project.use.viewport,
    offlineReload: 'passed',
    offlineNewTab: 'passed',
    offlineInteraction: 'passed',
    reconnect: 'passed',
    horizontalOverflow: false,
    pageErrors,
    cacheEntries,
  }, null, 2))
})
