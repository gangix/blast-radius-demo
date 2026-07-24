# Blast Radius — Demo Data Repo

This is a tiny **dbt project** wired to the
[Blast Radius](https://github.com/OWNER/blast-radius) GitHub Action. It exists so
you can **open a pull request and watch the bot review it** — the same way a data
team would.

Every PR here changes one column of the `order_details` model. On each PR the
Action asks DataHub *what breaks downstream and who actually queries this*, then
posts a blast-radius comment and a **Blast Radius** check — before anyone merges.

## The three scenarios

Open any of these as a PR (`compare` → **Create pull request**) and watch the
comment appear:

| # | Open this PR | Change | Expected verdict | Why |
|---|---|---|---|---|
| 1 | [`demo/1-hard-break`](../../compare/main...demo/1-hard-break?expand=1) | drop `discount_amount` | ❌ **Breaking** | 2 finance queries (~11 reads/day) and 3 dashboards depend on it |
| 2 | [`demo/2-warning`](../../compare/main...demo/2-warning?expand=1) | drop `warehouse_name` | ⚠️ **Review** | 1 query reads it — check before merge |
| 3 | [`demo/3-clean-pass`](../../compare/main...demo/3-clean-pass?expand=1) | drop `gift_wrap` | ✅ **Safe** | no query or usage has touched it in 30 days |

Scenario 3 is the point most tools miss: `order_details` feeds three dashboards,
but **nothing reads `gift_wrap`**, so the bot says *ship it* instead of crying
wolf. Blast Radius weights severity by real query usage, not raw node counts.

## What's in here

```
models/
  order_details.sql          # the model every PR edits (one row per order line)
  staging/raw_order_details.sql
dbt_project.yml
.github/workflows/blast-radius.yml   # runs Blast Radius on every pull_request
```

## Activating it (one-time setup)

The workflow is ready but needs two things before it runs live:

1. **Publish the Action.** Point `uses: OWNER/blast-radius@v1` in
   `.github/workflows/blast-radius.yml` at the published
   [Blast Radius](https://github.com/OWNER/blast-radius) action repo.
2. **Give it a reachable DataHub.** Add repository secrets:
   - `DATAHUB_GMS_URL` — a DataHub GMS reachable **from the GitHub runner** (a
     hosted instance, or your local one exposed via a tunnel / self-hosted
     runner — the cloud runner cannot reach `localhost:8080`).
   - `DATAHUB_TOKEN` — a DataHub access token.
   - `DATAHUB_FRONTEND_URL` — the DataHub UI base URL, so asset links in the
     comment are clickable.

The check is advisory (non-blocking) unless you mark **Blast Radius** as a
required status check in branch protection.

## Reproduce the verdicts locally

Every verdict here was verified end-to-end against the seeded DataHub. With the
[Blast Radius](https://github.com/OWNER/blast-radius) package installed and
DataHub running, the three diffs above resolve to ❌ / ⚠️ / ✅ deterministically —
no LLM decides severity; the graph facts come from DataHub.
