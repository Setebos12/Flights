import { useEffect, useState } from "react"
import { fetchKpi } from "../../analyticsApi"

const MONTH_NAMES = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

function KpiCard({ icon, label, value, sub, color }) {
  return (
    <div className="analytics-kpi-card" style={{ "--accent": color }}>
      <div className="analytics-kpi-icon">{icon}</div>
      <div className="analytics-kpi-content">
        <div className="analytics-kpi-label">{label}</div>
        <div className="analytics-kpi-value">{value}</div>
        {sub && <div className="analytics-kpi-sub">{sub}</div>}
      </div>
    </div>
  )
}

export default function KpiCards() {
  const [kpi, setKpi] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    fetchKpi()
      .then(setKpi)
      .catch(e => setError(e.message))
      .finally(() => setLoading(false))
  }, [])

  if (loading) return <div className="analytics-loading">Loading KPIs…</div>
  if (error) return <div className="analytics-error">⚠ {error}</div>
  if (!kpi) return null

  const revenue = kpi.totalRevenue != null
    ? `${Number(kpi.totalRevenue).toLocaleString("pl-PL", { minimumFractionDigits: 2 })} ${kpi.revenueCurrency ?? "EUR"}`
    : "—"

  const occupancy = kpi.avgOccupancyPct != null
    ? `${Number(kpi.avgOccupancyPct).toFixed(1)} %`
    : "—"

  return (
    <div className="analytics-kpi-grid">
      <KpiCard
        icon="✈️"
        label="Total Flights"
        value={kpi.totalFlights?.toLocaleString("pl-PL") ?? "—"}
        sub="All time"
        color="hsl(220, 80%, 60%)"
      />
      <KpiCard
        icon="👥"
        label="Total Passengers"
        value={kpi.totalPassengers?.toLocaleString("pl-PL") ?? "—"}
        sub="Booked seats"
        color="hsl(160, 70%, 50%)"
      />
      <KpiCard
        icon="💰"
        label="Total Revenue"
        value={revenue}
        sub="Completed payments"
        color="hsl(45, 90%, 55%)"
      />
      <KpiCard
        icon="📊"
        label="Avg Occupancy"
        value={occupancy}
        sub={`Top route: ${kpi.topRouteOrigin ?? "—"} → ${kpi.topRouteDest ?? "—"}`}
        color="hsl(280, 70%, 60%)"
      />
    </div>
  )
}
