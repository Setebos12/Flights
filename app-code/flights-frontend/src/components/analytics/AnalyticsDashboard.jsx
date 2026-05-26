import { useState } from "react"
import KpiCards from "./KpiCards"
import OccupancyChart from "./OccupancyChart"
import SeasonalityChart from "./SeasonalityChart"
import RevenueChart from "./RevenueChart"
import AirlineRankingChart from "./AirlineRankingChart"
import PriceDistributionChart from "./PriceDistributionChart"

const TABS = [
  { id: "overview",    label: "Overview",      component: <><KpiCards /><AirlineRankingChart /></> },
  { id: "occupancy",   label: "Occupancy",      component: <OccupancyChart /> },
  { id: "seasonality", label: "Destinations",   component: <SeasonalityChart /> },
  { id: "revenue",     label: "Revenue",        component: <RevenueChart /> },
  { id: "prices",      label: "Prices",         component: <PriceDistributionChart /> },
]

export default function AnalyticsDashboard() {
  const [activeTab, setActiveTab] = useState("overview")

  const currentTab = TABS.find(t => t.id === activeTab)

  return (
    <div className="analytics-dashboard">
      {/* Tab navigation */}
      <nav className="analytics-tabs">
        {TABS.map(t => (
          <button
            key={t.id}
            id={`analytics-tab-${t.id}`}
            className={`analytics-tab-btn${activeTab === t.id ? " active" : ""}`}
            onClick={() => setActiveTab(t.id)}
          >
            {t.label}
          </button>
        ))}
      </nav>

      {/* Tab content */}
      <div className="analytics-content">
        {currentTab?.component}
      </div>
    </div>
  )
}
