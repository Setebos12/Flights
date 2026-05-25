const BASE = "http://localhost:8080/api/analytics"

export async function fetchKpi() {
  const res = await fetch(`${BASE}/kpi`)
  if (!res.ok) throw new Error("KPI fetch failed")
  return res.json()
}

export async function fetchOccupancy({ airlineId, routeId, year, month } = {}) {
  const q = new URLSearchParams()
  if (airlineId) q.append("airlineId", airlineId)
  if (routeId)   q.append("routeId", routeId)
  if (year)      q.append("year", year)
  if (month)     q.append("month", month)
  const res = await fetch(`${BASE}/occupancy?${q}`)
  if (!res.ok) throw new Error("Occupancy fetch failed")
  return res.json()
}

export async function fetchOccupancySummary() {
  const res = await fetch(`${BASE}/occupancy/summary`)
  if (!res.ok) throw new Error("Occupancy summary fetch failed")
  return res.json()
}

export async function fetchSeasonality({ year, originCode, destCode } = {}) {
  const q = new URLSearchParams()
  if (year)       q.append("year", year)
  if (originCode) q.append("originCode", originCode)
  if (destCode)   q.append("destCode", destCode)
  const res = await fetch(`${BASE}/routes/seasonality?${q}`)
  if (!res.ok) throw new Error("Seasonality fetch failed")
  return res.json()
}

export async function fetchTopRoutes(limit = 10) {
  const res = await fetch(`${BASE}/routes/top?limit=${limit}`)
  if (!res.ok) throw new Error("Top routes fetch failed")
  return res.json()
}

export async function fetchRouteRevenue({ year, airlineId } = {}) {
  const q = new URLSearchParams()
  if (year)      q.append("year", year)
  if (airlineId) q.append("airlineId", airlineId)
  const res = await fetch(`${BASE}/routes/revenue?${q}`)
  if (!res.ok) throw new Error("Route revenue fetch failed")
  return res.json()
}

export async function fetchAirlineRanking() {
  const res = await fetch(`${BASE}/airlines/ranking`)
  if (!res.ok) throw new Error("Airline ranking fetch failed")
  return res.json()
}

export async function fetchPriceDistribution() {
  const res = await fetch(`${BASE}/prices/distribution`)
  if (!res.ok) throw new Error("Price distribution fetch failed")
  return res.json()
}
