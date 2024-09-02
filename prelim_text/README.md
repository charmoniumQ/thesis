Title: How to enable inexpensive reproducibility for computational experiments?

# Problem

Reproducibility of scientific experiments is important for three reasons:

1. The scientific community corrects false claims by applying scrutiny to each others' experiments.
   Scrutinizing an experiment often includes reproducing it.
   Therefore, reproducible experiments may be thoroughly scrutinized and defended.

2. Science works by building off of the work of others.
   Often in extending anothers work, one needs to execute a modified version of their experiment.
   If reproducing the same experiment is difficult, one would expect executing an extended version to be even more so.
   Therefore, reproducible experiments may be easier to extend.

3. The end-goal for some science is to be applied in engineering applications.
   Applying a novel technique on new data involves reproducing a part of the experiment which established the novel technique.
   Therefore, reproducible experiments may be easier to apply in practice.

Reproducibility also has costs, primarily in human labor needed to explain the experiment beyond that which would be needed to merely disseminate the results.
Working scientists balance the cost of reproducibility with the benefits to society or to themselves (to some extent, benefit to society yields benefit to themselves due to societal incentives).

In real-world experiments, there are an infinitude of possible factors that must be controlled to find the desired result; it would be unfathomable that two instantiations of an experiment could give exactly identical results.
In contrast, for computational experiments, while there are still many factors to be controlled, perfect reproduction is quite fathomable.
Despite this apparent advantage, computational experiments still suffer low rates of reproducibility.

The status quo will not change simply by arguing for reproducibility; those arguments are widely known are already taken into account by the efficient market.
Nor do I have the power to change incentives in science funding policy.
However, by reducing the cost of reproducibility, scientists may produce more reproducible experiments with the same effort.
Reducing the cost is a technical problem this work attempts to solve.

For the purposes of this work, "computation scientist" should be construed broadly, as anyone who uses research software to carry out some investigation.
The term includes people who use research software for data analytics and for simulations, so long as they are interested in creating knowledge that is scrutinizable, extensible, and applicable in practice.

- Also see technology adoption model (Davis 1989).
- Define context/audience: labs and independent researchers
- Does reproducibility impact correctness?

# Background

- Most scientists use research software, and many write their own (Hettrick); therefore, methods for reproducible software are important.
- How to define research software
- Define reproducibility
- Define crash-freedom as the measurement
- Explain cost-benefit to researchers

# Related work

- What is the measured rate of irreproducibility in samples of software?
  - Trisovic et al.
  - Zhao et al.: Why Workflows Fail
- What are common reasons software is not reproducible? We should address one of those.
  - Collberg and Proebsting
  - Zhao et al.
- How to address source code sharing
  - Collberg and Proebsting
  - Stodden
  - ACM REP '23 and ACM REP '24 have work on this
  - Incentives
    - Artifact badging
    - Vandewalle et al.
- How does archival and library science connect to reproducibility?
  - Software Heritage Archive
  - ACM REP '23 and ACM REP '24 have work on this
  - DOI
- How do workflows connect to reproducibility
  - Taverna
  - VizIt
  - Galaxy
  - WorkflowHub
  - Connection between workflow and provenance
- How does provenance connect to reproducibility
  - What is provenance? Survey of provenance by (Freire)
- Record/replay for reproducibility
  - CDE
  - RR
  - CARE
  - Sciunit (Malik)
  - ReproZip
  - Sumatra
  - Preserving the mess or encouraging cleanliness (Thaine)
- How does virtualization and containerization connect to reproducibility
  - Docker
  - Singularity
- How do package managers connect to reproducibility
  - Nix
  - Guix
  - Spack
- How/why scientific clouds can/can't help with reproducibility
  - WholeTale
- Automatic build repair for reproducibility
  - Cindy Rubio-Gonzales
  - ShipWright
- Why does RSE work matter for reproducibility?
  - Bridging the gaps

Overall, work encourages "defense-in-depth" approaches at multiple levels of the stack.
Synergies exist.

# My research strategy

Irreproducible science (end problem) -> computational irreproducibility (cause) -> source inavailability (cause), crash-free computational irreproducibility (proxy) -> {pro-active activities with limited cost, re-active responses}

source inavailability (cause) -> cost of supporting reproduction

pro-active -> PROBE archive

re-active -> PROBE with automated environment exploration

Translational CS

# My prior work

## Lifetime of workflows in sample

Lifetime analysis

## Literature review and evaluation of record/replay tools

Record/replay benchmarks (done)

## System-level prov tracer

# Proposed work

Prov tracer (aka Povenance & Replay OBservation Engine)

Re-executable provenance RO-crates

Using liftetime analysis for CI testing

Using PROBE in ECMF

Script -> Workflow conversion

User studies

PROBEd environment manipulation

# Intellectual merit

What is the importance of the activity to advancing knowledge or understanding?

- Validate theoretical model
- Theoretical model systematizes knowledge
- Unique treatment of reproducibility as cost/benefit
- Encourage use of provenance (transformative concept)
- Uniting OS background with TAM and user studies

# Expected impact

What impact can be expected in terms of particular research communities and on society in general?

- "Push button" reproducibility
- Reproducibility helps inclusivity in research in grad school and globally

# Feasibility

How likely are the stated goals to be achieved by the candidate?

## Timeline

# Bibliography
