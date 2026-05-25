import { useState } from "react"
import SearchForm from "./components/SearchForm"
import FlightList from "./components/FlightList"
import AnalyticsDashboard from "./components/analytics/AnalyticsDashboard"

export default function App() {
  const [flights, setFlights] = useState([])
  const [loading, setLoading] = useState(false)
  const [view, setView] = useState("search") // "search" | "analytics"

  const searchFlights = async (params) => {
    setLoading(true)
    const query = new URLSearchParams()
    if (params.originCode) query.append("originCode", params.originCode)
    if (params.destinationCode) query.append("destinationCode", params.destinationCode)
    if (params.date) query.append("date", params.date)
    if (params.minPrice) query.append("minPrice", params.minPrice)
    if (params.maxPrice) query.append("maxPrice", params.maxPrice)

    const res = await fetch(`http://localhost:8080/api/flights/search?${query}`)
    const data = await res.json()
    setFlights(data)
    setLoading(false)
  }

  return (
    <div className="min-h-screen bg-slate-100 dark:bg-slate-900">
      <nav className="bg-blue-950 dark:bg-slate-950 px-6 py-3 flex items-center gap-6">
        <div className="flex items-center gap-2">
          <span className="text-white text-2xl">✈</span>
          <span className="text-white font-medium tracking-wide text-lg">SkySearch</span>
        </div>
        <div className="flex gap-1 ml-2">
          <button
            id="nav-search"
            onClick={() => setView("search")}
            className={`px-4 py-1.5 rounded-md text-sm font-medium transition-colors ${
              view === "search"
                ? "bg-white/15 text-white"
                : "text-blue-200 hover:text-white hover:bg-white/10"
            }`}
          >
            🔍 Search Flights
          </button>
          <button
            id="nav-analytics"
            onClick={() => setView("analytics")}
            className={`px-4 py-1.5 rounded-md text-sm font-medium transition-colors ${
              view === "analytics"
                ? "bg-white/15 text-white"
                : "text-blue-200 hover:text-white hover:bg-white/10"
            }`}
          >
            📊 Analytics
          </button>
        </div>
      </nav>

      {view === "search" ? (
        <>
          <SearchForm onSearch={searchFlights} />
          <div className="max-w-4xl mx-auto px-4 py-6">
            {loading && <p className="text-slate-500 text-center animate-pulse">Searching...</p>}
            <FlightList flights={flights} />
          </div>
        </>
      ) : (
        <AnalyticsDashboard />
      )}
    </div>
  )
}