import { useEffect, useState } from "react"
import {
  LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip,
  Legend, ResponsiveContainer
} from "recharts"
import { fetchSeasonality } from "../../analyticsApi"

const MONTH_NAMES = ["—","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
const LINE_COLORS = [
  "hsl(220,80%,65%)", "hsl(160,70%,55%)", "hsl(45,85%,60%)",
  "hsl(280,70%,65%)", "hsl(0,70%,62%)"
]

function CustomTooltip({ active, payload, label }) {
  if (!active || !payload?.length) return null
  return (
    <div className="analytics-tooltip">
      <div className="analytics-tooltip-label">{label}</div>
      {payload.map(p => (
        <div key={p.name} className="analytics-tooltip-row">
          <span style={{ color: p.color }}>{p.name}:</span>
          <strong>{typeof p.value === "number" ? p.value.toLocaleString() : p.value}</strong>
        </div>
      ))}
    </div>
  )
}

function buildMonthlyData(rows, selectedRoute) {
  // Group by month; if a route is selected, filter first
  const filtered = selectedRoute
    ? rows.filter(r => `${r.originCode}→${r.destCode}` === selectedRoute)
    : rows

  const byMonth = {}
  for (const r of filtered) {
    const key = MONTH_NAMES[r.depMonth] ?? r.depMonth
    if (!byMonth[key]) byMonth[key] = { month: key, passengers: 0, flights: 0 }
    byMonth[key].passengers += Number(r.totalPassengers ?? 0)
    byMonth[key].flights    += Number(r.totalFlights ?? 0)
  }
  return Object.values(byMonth).sort((a, b) =>
    MONTH_NAMES.indexOf(a.month) - MONTH_NAMES.indexOf(b.month)
  )
}

export default function SeasonalityChart() {
  const [data, setData] = useState([])
  const [chartData, setChartData] = useState([])
  const [routes, setRoutes] = useState([])
  const [selectedRoute, setSelectedRoute] = useState("")
  const [metric, setMetric] = useState("passengers") // "passengers" | "flights"
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    fetchSeasonality()
      .then(rows => {
        setData(rows)
        // Unique routes
        const uniqueRoutes = [...new Set(rows.map(r => `${r.originCode}→${r.destCode}`))]
        setRoutes(uniqueRoutes)
        setChartData(buildMonthlyData(rows, ""))
      })
      .catch(e => setError(e.message))
      .finally(() => setLoading(false))
  }, [])

  const handleRouteChange = (route) => {
    setSelectedRoute(route)
    setChartData(buildMonthlyData(data, route))
  }

  if (loading) return <div className="analytics-loading">Loading seasonality data…</div>
  if (error)   return <div className="analytics-error">⚠ {error}</div>

  return (
    <div className="analytics-chart-card">
      <div className="analytics-chart-header">
        <h3 className="analytics-chart-title">Route Popularity &amp; Seasonality</h3>
        <div className="analytics-filters">
          <select
            className="analytics-select"
            value={selectedRoute}
            onChange={e => handleRouteChange(e.target.value)}
          >
            <option value="">All routes</option>
            {routes.map(r => <option key={r} value={r}>{r}</option>)}
          </select>
          <div className="analytics-toggle">
            <button className={metric === "passengers" ? "active" : ""}
              onClick={() => setMetric("passengers")}>Passengers</button>
            <button className={metric === "flights" ? "active" : ""}
              onClick={() => setMetric("flights")}>Flights</button>
          </div>
        </div>
      </div>

      <ResponsiveContainer width="100%" height={300}>
        <BarChart data={chartData} margin={{ top: 10, right: 20, left: 0, bottom: 10 }}>
          <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.07)" />
          <XAxis dataKey="month" tick={{ fill: "#94a3b8", fontSize: 12 }} />
          <YAxis tick={{ fill: "#94a3b8", fontSize: 11 }} />
          <Tooltip content={<CustomTooltip />} />
          <Legend wrapperStyle={{ color: "#94a3b8", fontSize: 12, paddingTop: 8 }} />
          <Bar
            dataKey={metric}
            name={metric === "passengers" ? "Passengers" : "Flights"}
            fill="hsl(220,80%,60%)"
            radius={[6, 6, 0, 0]}
          />
        </BarChart>
      </ResponsiveContainer>

      <div className="analytics-table-wrap" style={{ marginTop: "1.5rem" }}>
        <table className="analytics-table">
          <thead>
            <tr>
              <th>Route</th><th>Month</th><th>Flights</th><th>Passengers</th>
              <th>Avg Fill %</th><th>Avg Price</th>
            </tr>
          </thead>
          <tbody>
            {(selectedRoute
              ? data.filter(r => `${r.originCode}→${r.destCode}` === selectedRoute)
              : data
            ).slice(0, 20).map((r, i) => (
              <tr key={i}>
                <td><strong>{r.originCode} → {r.destCode}</strong></td>
                <td>{MONTH_NAMES[r.depMonth]} {r.depYear}</td>
                <td>{r.totalFlights}</td>
                <td>{r.totalPassengers?.toLocaleString()}</td>
                <td>{r.avgOccupancyPct != null ? `${Number(r.avgOccupancyPct).toFixed(1)}%` : "—"}</td>
                <td>{r.avgPrice != null ? `${Number(r.avgPrice).toFixed(2)} ${r.currencyCode}` : "—"}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
