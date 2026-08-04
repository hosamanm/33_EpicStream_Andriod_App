# Firestore Analytics Schema

## Collection: `analytics`
Root collection for aggregated platform-level metrics.

### Document: `global`
Aggregated totals for the dashboard.
```json
{
  "totalUsers": 1250000,
  "newUsersToday": 1200,
  "returningUsers": 45000,
  "dailyActiveUsers": 150000,
  "weeklyActiveUsers": 650000,
  "monthlyActiveUsers": 1100000,
  "totalWatchHours": 4500000.5,
  "todayWatchHours": 12500.2,
  "bandwidthUsageTB": 45.2,
  "storageUsageTB": 124.5,
  "updatedAt": "Timestamp"
}
```

## Collection: `watch_statistics`
Detailed watch time data for movies.

### Document: `{movieId}`
```json
{
  "movieId": "string",
  "totalViews": 125000,
  "uniqueViewers": 98000,
  "avgWatchTime": 45.5,
  "completionRate": 0.82,
  "lastWatched": "Timestamp"
}
```

## Collection: `search_statistics`
Tracking user search behavior.

### Document: `{query_id}`
```json
{
  "query": "Action Movies",
  "count": 5400,
  "lastSearched": "Timestamp",
  "resultsFound": true
}
```

## Collection: `device_statistics`
Aggregated device data.

### Document: `summary`
```json
{
  "platforms": {
    "Android": 850000,
    "iOS": 250000,
    "Web": 150000
  },
  "androidVersions": {
    "14": 400000,
    "13": 300000
  },
  "appVersions": {
    "1.0.0": 1100000,
    "0.9.8": 150000
  }
}
```

## Collection: `reports`
Metadata for generated/exported reports.

### Document: `{reportId}`
```json
{
  "type": "PDF|CSV|Excel",
  "name": "monthly_report_jan_2024.pdf",
  "url": "https://storage.googleapis.com/.../report.pdf",
  "generatedBy": "admin_uid",
  "createdAt": "Timestamp"
}
```
