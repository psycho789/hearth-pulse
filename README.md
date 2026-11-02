# hearth-pulse

Outside uptime checks for the sites hosted by [hearth](https://github.com/psycho789/hearth) (private).

A GitHub Actions run, scheduled every 5 minutes but in practice every few hours (see Limits), fetches each URL in [`targets.txt`](targets.txt). A URL is down when 3 tries, 20 seconds apart, all fail to return a 2xx. Then:

- the first failure opens an `outage` issue assigned to the owner, so GitHub emails them and the GitHub mobile app sends a push;
- if the set of down URLs changes, the issue gets a comment;
- when everything answers again, the issue gets a comment and closes itself.

The repository is public because public repositories get Actions minutes for free; it holds only URLs that are already public.

## Changing the targets

`targets.txt` is generated from hearth's config; don't edit it by hand. In the hearth checkout:

```sh
uv run hostctl public-urls > ../hearth-pulse/targets.txt
```

Then commit and push it here.

## Testing the alert path

Run the `pulse` workflow by hand with `drill_url` set to a URL that is down, for example `https://hearth-pulse-drill.invalid/`. That opens an issue; the next scheduled run (all targets up) comments and closes it.

## Limits

- GitHub runs the schedule far less often than asked: from 2026-10-23 to 2026-11-02 its 52 scheduled runs came 2 to 8.3 hours apart (median 4.4 h). An outage shorter than that can go unseen, and an alert or its all-clear can come hours late.
- It sees only what the internet sees. A full disk or a stopped staging VM shows up only once a site stops answering.
- `keepalive` re-enables the schedule monthly so GitHub's 60-day inactivity rule doesn't turn it off.
