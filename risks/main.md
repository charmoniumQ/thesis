# Light-weight, user-level provenance probing

**Abstract**:
The idea of a system-level provenance collector has been around for a while, but practical implementations are too slow (ptrace-based) or require root (kernel-based and audit-based, including eBPF) [cite our prior work]. We present PROBE, a system-level provenance tracer that uses library interpositioning, which is much faster than ptrace and doesn't require root like kernel-based solutions. We evaluate the performance of PROBE on benchmarks collected from prior provenance works as well as scientific benchmarks collected from XYZ (TODO). We also discuss one possible application of provenance, constructing environment specifications, demonstrating the usefulness of provenance and PROBE in practice. Finally, we discuss interoperable provenance standards, including W3C PROV and Workflow Run RO Crate (WRROC) [TODO cite], and evaluate their feasibility for system-level provenance.

## RQs

- **RQ4:** Does Workflow Run RO Crate (WRROC) represent all of the relevant data?
- **RQ5:** Can we align W3C PROV provenance observed from language-level tool with system-level provenance in WRROC?
  - This is different than Layering in Provenance Systems (aka PASSv2), since PASSv2 requires the language-level provenance tracer to be modified to "fit" the API of the system-level provenance tracer. It would promote better separation-of-concerns if both could be unaware of each other, log in an interoperable format, and align formats _post facto_.

## Risks/mitigations

- PROBE is actually slower than other system-level provenance tracers
  - Instrument startup, eliminate overhead
  - Shift to novel applications of provenance (RQs 3 and 4).
- Heuristics fail to create runnable package specifications
  - Root-cause analysis, classify failures, explain how they could be modified to enable the task

## TODO

- Refactoring tech debt (Oct 31)
- Improve memory utilization (Nov 31)
- Fix DFG issues (Nov 31)
- Increase libcall coverage (Dec 31)
- Collect scientific benchmarks (Dec 31)
- Write paper (Jan 15)
- ISWC April 10, 2024 (expected)
- eScience '25 submission deadline (May 28 (expected))

## Status

- Records provenance on simple examples
- 30 tickets, 4 in progress (including students)
- 41/46 non-crashing small benchmarks
- ?? non-crashing large benchmarks
- 109/135 priority I libcalls
- ?? priority II libcalls

# Provenance for record/replay

## RQs

- **RQ1:** Does Workflow Run RO Crate (WRROC) represent all of the relevant data for record/replay?
- **RQ2[accuracy]:** What is the completeness of record/replay with PROBE compared to prior work? What differences is PROBE robust to?
- **RQ3[performance]:** What is the performance overhead of record and completed-replay with PROBE compared to prior work?

## Risks/mitigations

- WRROC can't actually hold relevant data
  - Design ontological extensions on WRROC to hold relevant data.
  - If RQ1 is answered negatively, we can justify using internal format for future questions
- PROBE is actually slower and less accurate than conventional record/replay
  - Focus on the richness of provenance data.

## TODO

- Debug record/replay (Nov 31)
- USENIX ATC submission (Jan 14)

## Status

- Replays simple examples
- ??/?? replayable benchmarks
- ??/?? captured libcalls
