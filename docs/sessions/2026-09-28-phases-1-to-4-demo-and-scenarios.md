# 2026-09-28 - OpenRiC: UX phases 1-4, the five-minute demo, WhatsApp, and cross-cutting wizard scenarios

Second session log for 28 September. The first covers Phase 0 (version integrity
and the drift guard); this covers everything after it.

Repositories touched: `openric/spec`, `openric/service`, `openric/viewer`,
`openric/capture`.

## The recurring finding, stated first

**Four of the ten UX issues described work that was already done.** Actioning any
of them as written would have meant rebuilding something that worked:

- `version.json` existed and was correct. Nothing consumed it.
- The `openricx:` extension register was published with 48 terms and a per-term
  disposition audit.
- The modelling wizard had **18** scenarios and a prominent picker, not the one
  scenario the review described.
- Site search existed and was lunr-powered - but indexed only the 17 help
  articles, so the specification, the profiles and the guides were unfindable.

Meanwhile the defects that actually bit were in neither planning document, and
each was the silent kind:

- **OpenRiC had no `schedule:run` cron at all.** Every other Laravel app on this
  host has one. Anything in `routes/console.php` was scheduled and never ran.
- **`packages/` is not what runs.** The path repository uses `"symlink": false`,
  so composer *copies* into `vendor/`, and `AhgRic\` autoloads from there.
- **Browse's entity palette carried a comment claiming it matched the viewer.**
  It did not: Record `#3b82f6` against `#45b7d1`, Activity `#ef4444` against
  `#6f42c1`.
- **The viewer used `calc(100vh - 58px)`**, a hardcoded assumption of exactly one
  header. Adding the shared shell would have shipped a visible overflow.

## What shipped

**Phase 1.** Task-first navigation (Explore / Learn & Model / Build / About) with
three new hub pages so nothing leads nowhere. Homepage rebuilt to a hero, a
60-second flow, three live cards, then role routing, then technical state last.

**Shared shell.** `openric.org/assets/shell/v1.{css,js}` now serves the header,
footer, design tokens and canonical RiC entity colours to all four surfaces.
Cross-origin rather than vendored, because copies drift - which is exactly the
failure found in Browse. Later extended with a site-wide WhatsApp contact button
and a `data-chrome="false"` flag so openric.org's own pages take only the button.

**Phase 2.** Browse moved server URL and API key into a closed Advanced drawer,
and **Delete is no longer rendered at all** in discovery mode - it previously
appeared disabled on every row, advertising a destructive action to someone who
only wanted to look. The viewer became the Graph Explorer, gaining a path trail
and a persistent legend.

**Phase 3.** Task-first entry into the RiC-CM navigator, and a Back button for
the wizard - the trail was push-only, so revising an answer meant Start over.

**Phase 4.** Task-first Capture, and one search index across the whole site
(17 documents to 60, in four categories).

## The five-minute demonstration

`https://openric.org/five-minutes/` - one object followed end to end on live
data. A model funeral boat, British Museum `BM-125320`, chosen because almost
nothing interesting about it fits in a catalogue record: four activities
including a modern photogrammetry digitisation, two `Rule` entities including
Egyptian Antiquities Protection Law 117/1983, and a glTF instantiation.

A shot-by-shot recording script and narration for eight beats are committed
alongside it. `archive-03` will record it with an established Playwright plus
Piper pipeline that has produced 42 videos.

**Blocked on one thing:** the viewer draws to a canvas, so cytoscape nodes are
not DOM elements and the harness's `glide(p, locator)` has nothing to target.

## WhatsApp

Proven end to end: a public form submission on `ric.theahg.co.za` spooled a
payload, the watcher sent it, and it reached the maintainer's handset.

**Settles something the estate notes were silent on:** php-fpm *can* write to
`/var/spool/ahg-whatsapp` with no systemd drop-in. `ProtectSystem=full` covers
`/usr`, `/boot` and `/etc` but not `/var`, and `www-data` is already in the
group. Every Laravel app on this host is in that position.

Two of the three asks needed no backend at all - `wa.me` click-to-chat and
share links work because the visitor initiates, which opens their own 24-hour
window. Only the Ask notification needed a template.

**A correction worth propagating:** the estate's global rules still say delivery
is limited to five verified recipients while the sender is a test number. That
has been false since 23 September - `callhub/app/Services/WhatsAppNotifier.php`
lines 85-87 state the sender is a verified business number with no sandbox and
"the five-recipient safety net that used to refuse a mistake is gone". Nothing
upstream will refuse a mistyped recipient, so `27999999999` is the only safe
test value.

## Conformance transparency

The service advertised `spec_version: 0.38.2` while the spec is at 0.43.10, with
no way for a client to see the gap. Added `latest_spec_version` and `spec_delta`
alongside it rather than bumping the number - it is a machine-readable assertion
about a testable contract, and raising it without re-verifying would be a claim
nobody had checked.

The profile list is more scrupulous than it looks. `provenance-event` is omitted
because 170 of 228 Production activities lack `rico:hasOrHadParticipant`, mostly
pre-1950 material where the creator is genuinely unknown.

## Dataset

Deleted two incoherent `ric_activity` rows whose name, type and description
disagreed with each other. **Did not delete a third**, "The Benson Family",
despite it being in the approved set: it has 23 outgoing relations to a named
family and their artworks, and its description says it was published from
Heratio. Wrong type, real content.

Also corrected a claim of my own: the "duplicated Egypt" is not a duplicate. One
is an AtoM subject heading, the other a native `RicPlace`. Two things in two
systems sharing a name - a reconciliation problem the model should surface.

## Wizard scenarios

The library had grown along **one axis**. Fifteen of 18 answered "I have
[format], how do I model it", and six taught the *same* lesson - Record vs
Record Set - through correspondence, photographs, maps, drawings, newspapers and
registers.

Added three organised by problem instead: `unknown-creator`, `chain-of-custody`,
`restricted-records`. Then grouped all 21 into five categories with native
`<optgroup>`, with *Modelling problems* leading.

`unknown-creator` is the one that matters most. It is the commonest situation in
real archives, had no worked example, and is precisely why the Provenance &
Event profile goes unclaimed. It teaches asserting *no* creator over inventing
an "Unknown" Agent that pollutes the authority file.

## Standing lessons

**Check a planning document against the repository before actioning it.** Four
issues out of ten described finished work.

**`composer reinstall` on a path repository is destructive.** It removes, then
re-mirrors, and a mid-copy failure leaves nothing. It took `ric.theahg.co.za`
down for several minutes when the mirror hit six files at mode 0600 that
`www-data` could not read. `composer install` recovers it. Note also that an
unreadable file shows in `git status` as *modified*, which is how those six
looked like someone's uncommitted work for most of the session when they were
untouched.

**Look at what a deletion actually touches.** Two of three approved deletions
were correct; the third would have severed 23 relations to real content.
