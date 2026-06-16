import { useEffect, useState } from "react"
import {
  AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip,
  Legend, ResponsiveContainer
} from "recharts"
import { fetchRouteRevenue } from "../../analyticsApi"

const MONTH_NAMES = ["—","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]

function CustomTooltip({ active, payload, label }) {
  if (!active || !payload?.length) return null
  return (
    <div className="analytics-tooltip">
      <div className="analytics-tooltip-label">{label}</div>
      {payload.map(p => (
        <div key={p.name} className="analytics-tooltip-row">
          <span style={{ color: p.color }}>{p.name}:</span>
          <strong>{typeof p.value === "number"
            ? p.value.toLocaleString("pl-PL", { minimumFractionDigits: 2 })
            : p.value}</strong>
        </div>
      ))}
    </div>
  )
}

function downloadCSV(rows) {
  const headers = ["Route","Month","Year","Passengers","Revenue"]
  const lines = rows.map(r => [
    `${r.originCode}→${r.destCode}`,
    MONTH_NAMES[r.payMonth] ?? r.payMonth, r.payYear,
    r.totalPassengers, r.totalRevenue
  ].join(","))
  const csv = [headers.join(","), ...lines].join("\n")
  const blob = new Blob([csv], { type: "text/csv" })
  const url  = URL.createObjectURL(blob)
  const a    = document.createElement("a")
  a.href = url; a.download = "revenue_report.csv"; a.click()
  URL.revokeObjectURL(url)
}

export default function RevenueChart() {
  const [data, setData] = useState([])
  const [chartData, setChartData] = useState([])
  const [routes, setRoutes] = useState([])
  const [selectedRoute, setSelectedRoute] = useState("")
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    fetchRouteRevenue()
      .then(rows => {
        setData(rows)
        const uniqueRoutes = [...new Set(rows.map(r => `${r.originCode}→${r.destCode}`))]
        setRoutes(uniqueRoutes)
        buildChart(rows, "")
      })
      .catch(e => setError(e.message))
      .finally(() => setLoading(false))
  }, [])

  function buildChart(rows, route) {
    const filtered = route ? rows.filter(r => `${r.originCode}→${r.destCode}` === route) : rows
    const byMonth = {}
    for (const r of filtered) {
      const key = `${MONTH_NAMES[r.payMonth]} ${r.payYear}`
      if (!byMonth[key]) byMonth[key] = { period: key, revenue: 0, passengers: 0 }
      byMonth[key].revenue    += Number(r.totalRevenue ?? 0)
      byMonth[key].passengers += Number(r.totalPassengers ?? 0)
    }
    setChartData(Object.values(byMonth))
  }

  const handleRouteChange = (route) => {
    setSelectedRoute(route)
    buildChart(data, route)
  }

  if (loading) return <div className="analytics-loading">Loading revenue data…</div>
  if (error)   return <div className="analytics-error">⚠ {error}</div>

  const totalRevenue = (selectedRoute
    ? data.filter(r => `${r.originCode}→${r.destCode}` === selectedRoute)
    : data
  ).reduce((acc, r) => acc + Number(r.totalRevenue ?? 0), 0)

  return (
    <div className="analytics-chart-card">
      <div className="analytics-chart-header">
        <h3 className="analytics-chart-title">Revenue from Routes</h3>
        <div className="analytics-filters">
          <select
            className="analytics-select"
            value={selectedRoute}
            onChange={e => handleRouteChange(e.target.value)}
          >
            <option value="">All routes</option>
            {routes.map(r => <option key={r} value={r}>{r}</option>)}
          </select>
          <button className="analytics-export-btn" onClick={() => downloadCSV(
            selectedRoute
              ? data.filter(r => `${r.originCode}→${r.destCode}` === selectedRoute)
              : data
          )}>
            ⬇ Export CSV
          </button>
        </div>
      </div>

      <div className="analytics-revenue-total">
        Total: <strong>{totalRevenue.toLocaleString("pl-PL", { minimumFractionDigits: 2 })} EUR</strong>
      </div>

      <ResponsiveContainer width="100%" height={280}>
        <AreaChart data={chartData} margin={{ top: 10, right: 20, left: 10, bottom: 10 }}>
          <defs>
            <linearGradient id="revenueGrad" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%"  stopColor="hsl(45,85%,55%)" stopOpacity={0.4}/>
              <stop offset="95%" stopColor="hsl(45,85%,55%)" stopOpacity={0.02}/>
            </linearGradient>
          </defs>
          <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.07)" />
          <XAxis dataKey="period" tick={{ fill: "#94a3b8", fontSize: 11 }} />
          <YAxis tick={{ fill: "#94a3b8", fontSize: 11 }} />
          <Tooltip content={<CustomTooltip />} />
          <Legend wrapperStyle={{ color: "#94a3b8", fontSize: 12 }} />
          <Area
            type="monotone"
            dataKey="revenue"
            name="Revenue"
            stroke="hsl(45,85%,55%)"
            fill="url(#revenueGrad)"
            strokeWidth={2}
          />
        </AreaChart>
      </ResponsiveContainer>

      <div className="analytics-table-wrap" style={{ marginTop: "1.5rem" }}>
        <table className="analytics-table">
          <thead>
            <tr>
              <th>Route</th><th>Month</th>
              <th>Passengers</th><th>Revenue</th>
            </tr>
          </thead>
          <tbody>
            {(selectedRoute
              ? data.filter(r => `${r.originCode}→${r.destCode}` === selectedRoute)
              : data
            ).slice(0, 20).map((r, i) => (
              <tr key={i}>
                <td><strong>{r.originCode} → {r.destCode}</strong></td>
                <td>{MONTH_NAMES[r.payMonth]} {r.payYear}</td>
                <td>{r.totalPassengers?.toLocaleString()}</td>
                <td><strong>{Number(r.totalRevenue ?? 0).toLocaleString("pl-PL", { minimumFractionDigits: 2 })}</strong></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
