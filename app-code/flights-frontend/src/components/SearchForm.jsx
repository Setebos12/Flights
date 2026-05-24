import { useState, useEffect } from "react"

export default function SearchForm({ onSearch }) {
  const [airports, setAirports] = useState([])
  const [originCode, setOriginCode] = useState("")
  const [destinationCode, setDestinationCode] = useState("")
  const [date, setDate] = useState("")
  const [minPrice, setMinPrice] = useState("")
  const [maxPrice, setMaxPrice] = useState("")

  useEffect(() => {
    fetch("http://localhost:8080/api/airports")
      .then(res => res.json())
      .then(data => setAirports(data))
  }, [])

  const handleSubmit = (e) => {
      e.preventDefault()
      onSearch({ originCode, destinationCode, date, minPrice, maxPrice })
  }

  return (
    <div className="bg-blue-900 dark:bg-slate-950 px-4 py-10">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-white text-3xl font-medium mb-2">Find your next flight</h1>
        <p className="text-blue-300 text-sm mb-6">Search hundreds of routes and get the best prices</p>

        <form onSubmit={handleSubmit} className="bg-white dark:bg-slate-800 rounded-xl p-4 grid grid-cols-1 md:grid-cols-5 gap-3 items-end">
          <div>
            <label className="block text-xs font-medium text-slate-500 uppercase tracking-wide mb-1">From</label>
            <select value={originCode} onChange={e => setOriginCode(e.target.value)}
              className="w-full h-10 border border-slate-200 rounded-lg px-3 text-sm bg-slate-50 dark:bg-slate-700 dark:text-white dark:border-slate-600">
              <option value="">Any</option>
              {airports.map(a => (
                <option key={a.id} value={a.airportCode}>{a.cityName} ({a.airportCode})</option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-xs font-medium text-slate-500 uppercase tracking-wide mb-1">To</label>
            <select value={destinationCode} onChange={e => setDestinationCode(e.target.value)}
              className="w-full h-10 border border-slate-200 rounded-lg px-3 text-sm bg-slate-50 dark:bg-slate-700 dark:text-white dark:border-slate-600">
              <option value="">Any</option>
              {airports.map(a => (
                <option key={a.id} value={a.airportCode}>{a.cityName} ({a.airportCode})</option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-xs font-medium text-slate-500 uppercase tracking-wide mb-1">Date</label>
            <input type="date" value={date} onChange={e => setDate(e.target.value)}
              className="w-full h-10 border border-slate-200 rounded-lg px-3 text-sm bg-slate-50 dark:bg-slate-700 dark:text-white dark:border-slate-600" />
          </div>

          <div>
            <label className="block text-xs font-medium text-slate-500 uppercase tracking-wide mb-1">Price range</label>
            <div className="flex gap-2">
              <input type="number" placeholder="Min" value={minPrice} onChange={e => setMinPrice(e.target.value)}
                className="w-full h-10 border border-slate-200 rounded-lg px-3 text-sm bg-slate-50 dark:bg-slate-700 dark:text-white dark:border-slate-600" />
              <input type="number" placeholder="Max" value={maxPrice} onChange={e => setMaxPrice(e.target.value)}
                className="w-full h-10 border border-slate-200 rounded-lg px-3 text-sm bg-slate-50 dark:bg-slate-700 dark:text-white dark:border-slate-600" />
            </div>
          </div>

          <button type="submit"
            className="h-10 bg-blue-700 hover:bg-blue-800 text-white rounded-lg text-sm font-medium px-6">
            Search
          </button>
        </form>
      </div>
    </div>
  )
}