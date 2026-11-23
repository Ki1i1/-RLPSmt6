import { expect, test } from '@playwright/test'

test('dashboard mengambil data BFF, memuat ulang status lampu, dan menyimpan data terakhir', async ({ page, context }) => {
  const sensors = Array.from({ length: 5 }, (_, index) => ({
    id: `S${index + 1}`,
    deviceName: `Sensor ${index + 1}`,
    reading: { current: 27 + index, unit: '°C', isOptimal: index < 3 },
    status: { battery: '85%', lastSeen: '2026-10-19T00:00:00.000Z' },
  }))
  let light = { isOn: true, brightness: 75 }
  let available = true

  const respond = (route, data) => route.fulfill({
    status: available ? 200 : 503,
    json: available ? data : {},
    headers: { 'access-control-allow-origin': '*' },
  })
  await context.route('**/sensor/web/analytics', (route) => respond(route, sensors))
  await context.route('**/light-control/web', (route) => respond(route, light))

  await page.goto('/')
  await expect(page.getByText('BFF terhubung')).toBeVisible()
  await expect(page.locator('#sensor-grid article')).toHaveCount(5)
  await expect(page.getByRole('article', { name: 'Sensor 5' })).toContainText('Kritis')
  const lightStatus = page.getByRole('region', { name: 'Status lampu' })
  await expect(lightStatus).toContainText('Menyala')
  await expect(lightStatus).toContainText('75%')

  light = { isOn: false, brightness: 0 }
  const refresh = page.getByRole('button', { name: 'Muat ulang data' })
  await refresh.click()
  await expect(lightStatus).toContainText('Mati')
  await expect(lightStatus).toContainText('0%')

  available = false
  await refresh.click()
  await expect(page.getByText('Data BFF gagal dimuat.')).toBeVisible()
  await expect(page.getByText('Data terakhir dari BFF')).toBeVisible()
  await expect(lightStatus).toContainText('Mati')

  await page.evaluate(() => navigator.serviceWorker.ready)
  await page.waitForFunction(() => navigator.serviceWorker.controller !== null)
  await context.setOffline(true)
  await page.reload()
  await expect(page.getByRole('alert')).toContainText('data BFF terakhir dari cache lokal')
  await expect(page.locator('#sensor-grid article')).toHaveCount(5)
  await expect(lightStatus).toContainText('Mati')
})
