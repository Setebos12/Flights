import { useEffect, useState } from "react"
import {
  ScatterChart, Scatter, XAxis, YAxis, CartesianGrid, Tooltip,
  ResponsiveContainer, ErrorBar
} from "recharts"
import { fetchPriceDistribution } from "../../analyticsApi"

function CustomTooltip({ active, payload }) {
  if (!active || !payload?.length) return null
  const d = payload[0]?.payload
  if (!d) return null
  return (
    <div className="analytics-tooltip">
      <div className="analytics-tooltip-label">{d.route}</div>
      <div className="analytics-tooltip-row"><span>Min:</span><strong>{d.minPrice} {d.currency}</strong></div>
      <div className="analytics-tooltip-row"><span>Avg:</span><strong>{d.avgPrice} {d.currency}</strong></div>
      <div className="analytics-tooltip-row"><span>Max:</span><strong>{d.maxPrice} {d.currency}</strong></div>
      <div className="analytics-tooltip-row"><span>Median:</span><strong>{d.medianPrice} {d.currency}</strong></div>
      <div className="analytics-tooltip-row"><span>Flights:</span><strong>{d.flightCount}</strong></div>
    </div>
  )
}

export default function PriceDistributionChart() {
  const [data, setData] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    fetchPriceDistribution()
      .then(rows => {
        setData(rows.map((r, i) => ({
          route: `${r.originCode}→${r.destCode}`,
          avgPrice: Number(r.avgPrice ?? 0),
          minPrice: Number(r.minPrice ?? 0),
          maxPrice: Number(r.maxPrice ?? 0),
          medianPrice: Number(r.medianPrice ?? 0),
          flightCount: r.flightCount,
          currency: r.currencyCode,
          errorY: [
            Number(r.avgPrice ?? 0) - Number(r.minPrice ?? 0),
            Number(r.maxPrice ?? 0) - Number(r.avgPrice ?? 0)
          ]
        })))
      })
      .catch(e => setError(e.message))
      .finally(() => setLoading(false))
  }, [])

  if (loading) return <div className="analytics-loading">Loading price data…</div>
  if (error) return <div className="analytics-error">⚠ {error}</div>
  if (!data.length) return <div className="analytics-empty">No price data available.</div>

  return (
    <div className="analytics-chart-card">
      <div className="analytics-chart-header">
        <h3 className="analytics-chart-title">Price Distribution by Route</h3>
      </div>

      {/* Bar chart: min/avg/max per route */}
      <div className="analytics-price-grid">
        {data.map((d, i) => {
          const range = d.maxPrice - d.minPrice || 1
          const avgPos = ((d.avgPrice - d.minPrice) / range) * 100
          const medPos = ((d.medianPrice - d.minPrice) / range) * 100
          return (
            <div key={i} className="analytics-price-card">
              <div className="analytics-price-route">{d.route}</div>
              <div className="analytics-price-currency">{d.currency} · {d.flightCount} flight{d.flightCount !== 1 ? "s" : ""}</div>

              {/* Range bar */}
              <div className="analytics-price-range-wrap">
                <span className="analytics-price-label">{d.minPrice.toFixed(0)}</span>
                <div className="analytics-price-range">
                  <div className="analytics-price-bar" />
                  {/* Avg marker */}
                  <div className="analytics-price-marker analytics-price-avg"
                    style={{ left: `${avgPos}%` }}
                    title={`Avg: ${d.avgPrice}`} />
                  {/* Median marker */}
                  <div className="analytics-price-marker analytics-price-median"
                    style={{ left: `${medPos}%` }}
                    title={`Median: ${d.medianPrice}`} />
                </div>
                <span className="analytics-price-label">{d.maxPrice.toFixed(0)}</span>
              </div>

              <div className="analytics-price-stats">
                <span>Avg <strong>{d.avgPrice.toFixed(2)}</strong></span>
                <span>Median <strong>{d.medianPrice?.toFixed(2) ?? "—"}</strong></span>
              </div>
            </div>
          )
        })}
      </div>

      <div className="analytics-table-wrap" style={{ marginTop: "1.5rem" }}>
        <table className="analytics-table">
          <thead>
            <tr>
              <th>Route</th><th>Currency</th><th>Min</th><th>Avg</th>
              <th>Median</th><th>Max</th><th>Flights</th>
            </tr>
          </thead>
          <tbody>
            {data.map((d, i) => (
              <tr key={i}>
                <td><strong>{d.route}</strong></td>
                <td>{d.currency}</td>
                <td>{d.minPrice.toFixed(2)}</td>
                <td>{d.avgPrice.toFixed(2)}</td>
                <td>{d.medianPrice?.toFixed(2) ?? "—"}</td>
                <td>{d.maxPrice.toFixed(2)}</td>
                <td>{d.flightCount}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
