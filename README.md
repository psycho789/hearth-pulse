# hearth-pulse

Outside uptime checks for the sites hosted by [hearth](https://github.com/psycho789/hearth) (private).

Every 5 minutes a GitHub Actions run fetches each URL in [`targets.txt`](targets.txt). A URL is down when 3 tries, 20 seconds apart, all fail to return a 2xx. Then:

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

- GitHub may start scheduled runs late under load (usually minutes), so an alert can take 5 to 15 minutes.
- It sees only what the internet sees. A full disk or a stopped staging VM shows up only once a site stops answering.
- `keepalive` re-enables the schedule monthly so GitHub's 60-day inactivity rule doesn't turn it off.
