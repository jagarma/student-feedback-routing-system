# Week 16 - Performance, Reliability and Deployment Evaluation

## Project
Student Feedback Routing System

## Source Baseline
- Branch: week16-performance-reliability
- Starting commit: 3e1e3f3
- Backend: Laravel 12.72.0 / PHP 8.2.12
- Frontend: Flutter 3.47.1
- Development OS: Windows 11 Home
- API: http://127.0.0.1:8000

## Performance Results

| Scenario | Requests | Average Response | Throughput | Errors |
|---|---:|---:|---:|---:|
| Sequential baseline | 10 | 183.02 ms | Not measured | 0 |
| Sequential workload | 30 | 178.82 ms | 5.57 req/s | 0 |
| Corrected concurrent test | 10 | 1056.14 ms | 5.35 req/s | 0 |
| Corrected concurrent test | 20 | 1810.17 ms | 5.68 req/s | 0 |

All requests targeted the protected GET /api/me endpoint without
authentication. HTTP 401 was the expected successful test response.

Earlier concurrent scripts did not independently measure individual
completion times. The corrected concurrent test results above are
the primary latency evidence.

## Reliability Results

- Reliability checks: 10
- Expected responses: 10
- Failures: 0
- Observed availability during the short test: 100%
- Average response time: 183.05 ms

## Resource Monitoring

- Five sampling intervals
- Two PHP processes
- Combined working-set memory: approximately 90.08 MB
- Monitoring was performed after load, not during peak workload

## Recovery Results

A controlled interruption stopped the local PHP development server.

- Port 8000 became unavailable
- API request produced no HTTP response (curl status 000)
- Laravel was restarted
- Protected API returned HTTP 401 again
- Measured restart-to-response time: 1.61 seconds

This does not measure total downtime or database restoration.

## Environment Comparison

The test environment used the Laravel PHP development server and
HTTP on localhost.

A production-like environment with HTTPS, protected configuration,
resource monitoring, and verified database recovery remains untested.

## Deployment Assessment

**Recommendation: Conditional - not production-ready.**

Outstanding verification includes:

- Authenticated feedback submission and routing under workload
- Resource utilization during active load
- Production-like server and HTTPS configuration
- Database backup restoration in an isolated environment
- Longer-duration reliability and full workflow recovery

## Evidence

Detailed CSV measurements, PowerShell scripts, recovery records,
and evaluation reports are retained in the separate Week 16
submission package.

The original Week 13-15 features and application source are
unchanged by the Week 16 documentation work.
