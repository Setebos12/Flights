import { useState, useEffect } from "react"

const STATUS_STYLE = {
  "Completed":           "bg-green-100 text-green-700",
  "Pending":             "bg-yellow-100 text-yellow-700",
  "Failed":              "bg-red-100 text-red-700",
  "Refunded":            "bg-blue-100 text-blue-700",
  "Partially Refunded":  "bg-orange-100 text-orange-700",
}

export default function MyBookings() {
  const [bookings, setBookings] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState("")

  useEffect(() => {
    fetch("http://localhost:8080/api/reservations/me", {
      headers: { Authorization: `Bearer ${localStorage.getItem("token")}` }
    })
      .then(r => { if (!r.ok) throw new Error(); return r.json() })
      .then(data => { setBookings(data); setLoading(false) })
      .catch(() => { setError("Failed to load bookings."); setLoading(false) })
  }, [])

  if (loading) return <p className="text-center text-slate-400 mt-16 animate-pulse">Loading bookings...</p>
  if (error)   return <p className="text-center text-red-500 mt-16">{error}</p>
  if (bookings.length === 0)
    return <p className="text-center text-slate-400 mt-16">No bookings yet.</p>

  return (
    <div className="max-w-3xl mx-auto px-4 py-8">
      <h2 className="text-lg font-medium text-slate-800 dark:text-white mb-5">My bookings</h2>
      <div className="flex flex-col gap-4">
        {bookings.map(b => (
          <div key={b.reservationId}
            className="bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl p-5">

            <div className="flex items-start justify-between gap-4">
              <div>
                <div className="text-xl font-medium text-slate-800 dark:text-white">
                  {b.originCode} → {b.destCode}
                </div>
                <div className="text-sm text-slate-500 mt-0.5">{b.airlineName}</div>
                <div className="text-sm text-slate-400 mt-0.5">{b.departureDatetime?.replace("T", " ")}</div>
              </div>
              <div className="text-right shrink-0">
                <div className="text-xl font-medium text-slate-800 dark:text-white">
                  {b.paymentAmount ?? b.flightPrice} {b.currencyCode}
                </div>
                <span className={`inline-block mt-1 text-xs font-medium px-2 py-0.5 rounded-full ${STATUS_STYLE[b.paymentStatus] ?? "bg-slate-100 text-slate-500"}`}>
                  {b.paymentStatus}
                </span>
              </div>
            </div>

            {b.seatRow && (
              <div className="mt-3 pt-3 border-t border-slate-100 dark:border-slate-700 flex gap-4 text-sm text-slate-500">
                <span>Seat: row {b.seatRow}, col {b.seatCol}</span>
                <span>{b.seatType}</span>
                <span>{b.classType}</span>
              </div>
            )}

            <div className="mt-2 text-xs text-slate-400">Reservation #{b.reservationId}</div>
          </div>
        ))}
      </div>
    </div>
  )
}
