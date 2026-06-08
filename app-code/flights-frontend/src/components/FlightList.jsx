import FlightCard from "./FlightCard"

export default function FlightList({ flights, user, onBook }) {
  if (flights.length === 0) {
    return (
      <p className="text-slate-400 text-center mt-10">
        No flights found. Try different search criteria.
      </p>
    )
  }

  return (
    <div>
      <p className="text-sm text-slate-500 dark:text-slate-400 mb-4">
        {flights.length} flight{flights.length > 1 ? "s" : ""} found · sorted by departure time
      </p>
      <div className="flex flex-col gap-3">
        {flights.map(flight => (
          <FlightCard key={flight.id} flight={flight} user={user} onBook={onBook} />
        ))}
      </div>
    </div>
  )
}