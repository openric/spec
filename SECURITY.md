# Reporting a security problem

If you find a security problem in anything OpenRiC publishes, please tell us privately first.

**What is covered:** the specification site (openric.org), the reference service (ric.theahg.co.za), the graph viewer (viewer.openric.org), the capture client (capture.openric.org), and the code in the openric repositories on GitHub.

**How to report:**

- Preferred: open a private report with GitHub's "Report a vulnerability" button on the Security tab of the repository concerned.
- Or email johan@theahg.co.za with "OpenRiC security" in the subject.

Please include what you found, where, how to reproduce it, and what you think the impact is. Do not include anyone's personal data beyond what is needed to show the problem.

**What happens next:** we acknowledge reports within five working days, tell you what we intend to do, and credit you when a fix is published unless you would rather not be named. Please give us a reasonable time to fix the problem before you disclose it publicly.

**Testing:** read-only checks against the public services are fine. Do not create, change or delete data on the reference service, do not run load tests against it, and do not try to reach data that is not public. To try writes, run the [minimal server](https://github.com/openric/spec/tree/main/examples/minimal-server) as the [getting-started guide](https://openric.org/guides/getting-started.html) does; if a security test needs to write to the reference implementation, ask us for a disposable environment.

**Specification issues** that are not security problems, such as ambiguous wording or a profile that cannot be implemented as written, belong in the public issue tracker of [openric/spec](https://github.com/openric/spec/issues).
