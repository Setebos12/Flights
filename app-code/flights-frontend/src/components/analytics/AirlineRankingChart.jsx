import { useEffect, useState } from "react"
import {
  RadarChart, Radar, PolarGrid, PolarAngleAxis, PolarRadiusAxis,
  ResponsiveContainer, Tooltip, Legend
} from "recharts"
import { fetchAirlineRanking } from "../../analyticsApi"

const COLORS = [
  "hsl(220,80%,65%)","hsl(160,70%,55%)","hsl(45,85%,58%)",
  "hsl(280,70%,65%)","hsl(0,70%,62%)","hsl(195,75%,55%)",
  "hsl(330,70%,62%)","hsl(90,65%,52%)","hsl(15,75%,60%)","hsl(250,75%,65%)"
]

function RankBadge({ rank }) {
  const styles = {
    1: { bg: "hsl(45,80%,20%)", color: "hsl(45,90%,65%)", label: "🥇" },
    2: { bg: "hsl(220,30%,20%)", color: "hsl(220,60%,75%)", label: "🥈" },
    3: { bg: "hsl(20,60%,20%)", color: "hsl(20,80%,65%)", label: "🥉" },
  }
  const s = styles[rank] ?? { bg: "hsl(220,15%,20%)", color: "#94a3b8", label: `#${rank}` }
  return (
    <span className="analytics-pill" style={{ background: s.bg, color: s.color, fontWeight: 700 }}>
      {s.label}
    </span>
  )
}

export default function AirlineRankingChart() {
  const [airlines, setAirlines] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    fetchAirlineRanking()
      .then(setAirlines)
      .catch(e => setError(e.message))
      .finally(() => setLoading(false))
  }, [])

  if (loading) return <div className="analytics-loading">Loading airline ranking…</div>
  if (error)   return <div className="analytics-error">⚠ {error}</div>
  if (!airlines.length) return <div className="analytics-empty">No airline data available.</div>

  // Normalize for radar (0-100 scale per metric)
  const maxFlights    = Math.max(...airlines.map(a => a.totalFlights ?? 0), 1)
  const maxPassengers = Math.max(...airlines.map(a => a.totalPassengers ?? 0), 1)
  const maxRevenue    = Math.max(...airlines.map(a => a.totalRevenue ?? 0), 1)

  const radarData = [
    { metric: "Flights",    ...Object.fromEntries(airlines.map(a => [a.airlineName.split(" ")[0], Math.round((a.totalFlights ?? 0) / maxFlights * 100)])) },
    { metric: "Passengers", ...Object.fromEntries(airlines.map(a => [a.airlineName.split(" ")[0], Math.round((a.totalPassengers ?? 0) / maxPassengers * 100)])) },
    { metric: "Revenue",    ...Object.fromEntries(airlines.map(a => [a.airlineName.split(" ")[0], Math.round((a.totalRevenue ?? 0) / maxRevenue * 100)])) },
    { metric: "Occupancy",  ...Object.fromEntries(airlines.map(a => [a.airlineName.split(" ")[0], Math.round(a.avgOccupancyPct ?? 0)])) },
  ]

  return (
    <div className="analytics-chart-card">
      <div className="analytics-chart-header">
        <h3 className="analytics-chart-title">🏆 Airline Ranking</h3>
      </div>

      <div className="analytics-ranking-grid">
        {/* Podium / table */}
        <div className="analytics-table-wrap" style={{ flex: 1 }}>
          <table className="analytics-table">
            <thead>
              <tr>
                <th>#</th><th>Airline</th><th>Flights</th>
                <th>Passengers</th><th>Fill %</th><th>Revenue</th>
              </tr>
            </thead>
            <tbody>
              {airlines.map((a, i) => (
                <tr key={a.airlineId}>
                  <td><RankBadge rank={i + 1} /></td>
                  <td><strong>{a.airlineName}</strong></td>
                  <td>{a.totalFlights?.toLocaleString()}</td>
                  <td>{a.totalPassengers?.toLocaleString()}</td>
                  <td>{a.avgOccupancyPct != null ? `${Number(a.avgOccupancyPct).toFixed(1)}%` : "—"}</td>
                  <td>
                    <strong>{Number(a.totalRevenue ?? 0).toLocaleString("pl-PL", { minimumFractionDigits: 2 })}</strong>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Radar chart — top 5 airlines */}
        <div style={{ flex: "0 0 340px" }}>
          <ResponsiveContainer width="100%" height={280}>
            <RadarChart data={radarData}>
              <PolarGrid stroke="rgba(255,255,255,0.1)" />
              <PolarAngleAxis dataKey="metric" tick={{ fill: "#94a3b8", fontSize: 12 }} />
              <PolarRadiusAxis angle={90} domain={[0, 100]} tick={{ fill: "#64748b", fontSize: 9 }} />
              <Tooltip />
              {airlines.slice(0, 5).map((a, i) => (
                <Radar
                  key={a.airlineId}
                  name={a.airlineName.split(" ")[0]}
                  dataKey={a.airlineName.split(" ")[0]}
                  stroke={COLORS[i]}
                  fill={COLORS[i]}
                  fillOpacity={0.15}
                />
              ))}
              <Legend wrapperStyle={{ color: "#94a3b8", fontSize: 11 }} />
            </RadarChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  )
}
