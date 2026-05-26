import { useEffect, useState } from "react"
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend,
  ResponsiveContainer, Cell
} from "recharts"
import { fetchOccupancy, fetchOccupancySummary } from "../../analyticsApi"

const MONTH_NAMES = ["—","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]

const GRADIENT_COLORS = ["hsl(220,80%,60%)","hsl(200,80%,55%)","hsl(180,75%,50%)","hsl(160,70%,48%)"]

function CustomTooltip({ active, payload, label }) {
  if (!active || !payload?.length) return null
  return (
    <div className="analytics-tooltip">
      <div className="analytics-tooltip-label">{label}</div>
      {payload.map(p => (
        <div key={p.name} className="analytics-tooltip-row">
          <span style={{ color: p.color }}>{p.name}:</span>
          <strong>{typeof p.value === "number" ? p.value.toFixed(1) : p.value}</strong>
        </div>
      ))}
    </div>
  )
}

export default function OccupancyChart() {
  const [mode, setMode] = useState("flights")   // "flights" | "summary"
  const [flights, setFlights] = useState([])
  const [summary, setSummary] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    setLoading(true)
    Promise.all([fetchOccupancy(), fetchOccupancySummary()])
      .then(([f, s]) => {
        // Trim label for chart: "WAW → BER – Jun 2026"
        setFlights(f.map(fl => ({
          name: `${fl.originCode}→${fl.destCode}`,
          occupancy: fl.occupancyPct ?? 0,
          booked: fl.bookedSeats ?? 0,
          total: fl.totalSeats ?? 0,
          airline: fl.airlineName,
          date: fl.departureDatetime?.substring(0, 10),
        })))
        setSummary(s.map(row => ({
          name: row.AIRLINE_NAME ?? row.airline_name,
          avgOccupancy: parseFloat(row.AVG_OCCUPANCY_PCT ?? row.avg_occupancy_pct ?? 0),
          totalFlights: parseInt(row.TOTAL_FLIGHTS ?? row.total_flights ?? 0),
        })))
      })
      .catch(e => setError(e.message))
      .finally(() => setLoading(false))
  }, [])

  if (loading) return <div className="analytics-loading">Loading occupancy data…</div>
  if (error)   return <div className="analytics-error">⚠ {error}</div>

  const data = mode === "flights" ? flights : summary
  const dataKey = mode === "flights" ? "occupancy" : "avgOccupancy"
  const barLabel = mode === "flights" ? "Occupancy %" : "Avg Occupancy %"

  return (
    <div className="analytics-chart-card">
      <div className="analytics-chart-header">
        <h3 className="analytics-chart-title">Aircraft Occupancy</h3>
        <div className="analytics-toggle">
          <button
            className={mode === "flights" ? "active" : ""}
            onClick={() => setMode("flights")}
          >Per Flight</button>
          <button
            className={mode === "summary" ? "active" : ""}
            onClick={() => setMode("summary")}
          >By Airline</button>
        </div>
      </div>

      <ResponsiveContainer width="100%" height={320}>
        <BarChart data={data} margin={{ top: 10, right: 20, left: 0, bottom: 60 }}>
          <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.07)" />
          <XAxis
            dataKey="name"
            tick={{ fill: "#94a3b8", fontSize: 11 }}
            angle={-35}
            textAnchor="end"
            interval={0}
          />
          <YAxis
            domain={[0, 100]}
            tick={{ fill: "#94a3b8", fontSize: 11 }}
            unit="%"
          />
          <Tooltip content={<CustomTooltip />} />
          <Legend wrapperStyle={{ color: "#94a3b8", fontSize: 12, paddingTop: 12 }} />
          <Bar dataKey={dataKey} name={barLabel} radius={[6, 6, 0, 0]}>
            {data.map((_, i) => (
              <Cell key={i} fill={GRADIENT_COLORS[i % GRADIENT_COLORS.length]} />
            ))}
          </Bar>
        </BarChart>
      </ResponsiveContainer>

      {mode === "flights" && (
        <div className="analytics-table-wrap">
          <table className="analytics-table">
            <thead>
              <tr>
                <th>Flight</th><th>Airline</th><th>Date</th>
                <th>Booked</th><th>Capacity</th><th>Fill %</th>
              </tr>
            </thead>
            <tbody>
              {flights.map((f, i) => (
                <tr key={i}>
                  <td><strong>{f.name}</strong></td>
                  <td>{f.airline}</td>
                  <td>{f.date}</td>
                  <td>{f.booked}</td>
                  <td>{f.total}</td>
                  <td>
                    <span className="analytics-pill" style={{
                      background: f.occupancy >= 80
                        ? "hsl(160,60%,20%)" : f.occupancy >= 50
                        ? "hsl(45,60%,20%)" : "hsl(0,50%,20%)",
                      color: f.occupancy >= 80
                        ? "hsl(160,70%,60%)" : f.occupancy >= 50
                        ? "hsl(45,80%,60%)" : "hsl(0,70%,65%)"
                    }}>
                      {Number(f.occupancy).toFixed(1)}%
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}
