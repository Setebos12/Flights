export default function FlightCard({ flight }) {
  const formatTime = (datetime) => {
    return new Date(datetime).toLocaleTimeString("pl-PL", {
      hour: "2-digit",
      minute: "2-digit"
    })
  }

  const calcDuration = (departure, arrival) => {
    const diff = new Date(arrival) - new Date(departure)
    const hours = Math.floor(diff / 3600000)
    const minutes = Math.floor((diff % 3600000) / 60000)
    return `${hours}h ${minutes}m`
  }

  const formatDate = (datetime) => {
    return new Date(datetime).toLocaleDateString("pl-PL", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric"
    })
  }

  return (
    <div className="bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl p-4 flex items-center gap-4">

      <div className="w-12 h-12 rounded-lg bg-blue-50 dark:bg-slate-700 flex items-center justify-center text-xs font-medium text-blue-700 dark:text-blue-300 text-center leading-tight shrink-0">
        {flight.airlineName.split(" ").map(w => w[0]).join("").slice(0, 3)}
      </div>

      <div className="flex items-center gap-4 flex-1">
        <div className="text-center">
          <div className="text-xl font-medium text-slate-800 dark:text-white">{flight.originAirportCode}</div>
          <div className="text-sm text-slate-500">{formatTime(flight.departureDatetime)}</div>
          <div className="text-xs text-slate-400">{flight.originCity}</div>
        </div>

        <div className="flex-1 flex flex-col items-center gap-1">
          <div className="text-xs text-slate-400">{calcDuration(flight.departureDatetime, flight.arrivalDatetime)}</div>
          <div className="w-full flex items-center gap-1">
            <div className="flex-1 h-px bg-slate-200 dark:bg-slate-600"></div>
            <span className="text-blue-600 text-sm">✈</span>
            <div className="flex-1 h-px bg-slate-200 dark:bg-slate-600"></div>
          </div>
          <div className="text-xs text-slate-400">Direct</div>
        </div>

        <div className="text-center">
          <div className="text-xl font-medium text-slate-800 dark:text-white">{flight.destinationAirportCode}</div>
          <div className="text-sm text-slate-500">{formatTime(flight.arrivalDatetime)}</div>
          <div className="text-xs text-slate-400">{flight.destinationCity}</div>
        </div>
      </div>

      <div className="flex flex-col gap-1 items-end shrink-0">
        <span className="text-xs text-slate-500 bg-slate-100 dark:bg-slate-700 dark:text-slate-300 px-2 py-1 rounded-full">
          {flight.planeModel}
        </span>
        {flight.seatCount && (
          <span className="text-xs text-green-700 bg-green-50 px-2 py-1 rounded-full">
            {flight.seatCount - (flight.bookedSeatsCount || 0)} seats left
          </span>
        )}
      </div>

      <div className="text-right shrink-0">
        <div className="text-xs text-slate-400">{flight.currencyCode}</div>
        <div className="text-2xl font-medium text-slate-800 dark:text-white">{flight.price}</div>
        <button className="mt-2 px-4 py-2 bg-blue-700 hover:bg-blue-800 text-white text-xs rounded-lg">
          Book now
        </button>
      </div>

      <div className="text-center">
        <div className="text-xl font-medium text-slate-800 dark:text-white">{flight.originAirportCode}</div>
        <div className="text-sm text-slate-500">{formatTime(flight.departureDatetime)}</div>
        <div className="text-xs text-slate-400">{formatDate(flight.departureDatetime)}</div>
        <div className="text-xs text-slate-400">{flight.originCity}</div>
      </div>
    </div>
  )
}