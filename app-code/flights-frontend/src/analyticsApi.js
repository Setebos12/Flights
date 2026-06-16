const BASE = "http://localhost:8080/api/analytics"

const authHeaders = () => {
  const token = localStorage.getItem("token")
  return token ? { Authorization: `Bearer ${token}` } : {}
}

const get = async (url) => {
  const res = await fetch(url, { headers: authHeaders() })
  if (!res.ok) throw new Error(`Fetch failed: ${res.status}`)
  return res.json()
}

export async function fetchKpi() {
  return get(`${BASE}/kpi`)
}

export async function fetchOccupancy({ airlineId, routeId, year, month } = {}) {
  const q = new URLSearchParams()
  if (airlineId) q.append("airlineId", airlineId)
  if (routeId)   q.append("routeId", routeId)
  if (year)      q.append("year", year)
  if (month)     q.append("month", month)
  return get(`${BASE}/occupancy?${q}`)
}

export async function fetchOccupancySummary() {
  return get(`${BASE}/occupancy/summary`)
}

export async function fetchSeasonality({ year, originCode, destCode } = {}) {
  const q = new URLSearchParams()
  if (year)       q.append("year", year)
  if (originCode) q.append("originCode", originCode)
  if (destCode)   q.append("destCode", destCode)
  return get(`${BASE}/routes/seasonality?${q}`)
}

export async function fetchTopRoutes(limit = 10) {
  return get(`${BASE}/routes/top?limit=${limit}`)
}

export async function fetchRouteRevenue({ year } = {}) {
  const q = new URLSearchParams()
  if (year)      q.append("year", year)
  return get(`${BASE}/routes/revenue?${q}`)
}

export async function fetchAirlineRanking() {
  return get(`${BASE}/airlines/ranking`)
}

export async function fetchPriceDistribution() {
  return get(`${BASE}/prices/distribution`)
}
