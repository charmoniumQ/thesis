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

TODO: Popper defined reproducibility as a criterion for distinguishing between science and pseudoscience (Hill, 2019 in https://arxiv.org/pdf/2402.07530).

Reproducibility also has costs, primarily in human labor needed to explain the experiment beyond that which would be needed to merely disseminate the results.
Working scientists balance the cost of reproducibility with the benefits to society or to themselves (to some extent, benefit to society yields benefit to themselves due to societal incentives).

In real-world experiments, there are an infinitude of possible factors that must be controlled to find the desired result; it would be unfathomable that two instantiations of an experiment could give exactly identical results.
In contrast, for computational science experiments (from here on, **CS Exp**) on digital computers, while there are still many factors to be controlled, perfect reproduction is quite fathomable.
Despite this apparent advantage, CS Exps on digital computers still suffer low rates of reproducibility.

``` python
import matplotlib, numpy
fig = matplotlib.Figure()
ax = fig.add_subplot()
xmax = 2
xs = numpy.linspace(0, xmax, 100)
ys = 1 / xs
ax.plot(xs, ys)
ax.set_xlim(0, xmax)
ax.set_ylim(0, 1 / xmax)
ax.set_xlabel("Effort")
ax.set_ylabel("Reproducibility")
ax.set_xticks([])
ax.set_yticks([])
fi.set_title("General shape of effort-vs-reproducibility for one CSE")

# Move the left and bottom spines to x = 0 and y = 0, respectively.
ax.spines[["left", "bottom"]].set_position(("data", 0))

# Hide the top and right spines.
ax.spines[["top", "right"]].set_visible(False)

for axis_min, axis_max, transform in [
        (1, 0, ax.get_yaxis_transform()),
        (0, 1, ax.get_xaxis_transform()),
    ]:
    ax.plot(
        axis_min,
        axis_max,
        ls="",
        marker=">",
        ms=10,
        color="k",
        transform=transform,
        clip_on=False,
    )

fig
```

The status quo will not change simply by arguing for reproducibility; those arguments are widely known are already taken into account by the efficient market.
Nor do I have the power to change incentives in science funding policy.
However, by reducing the cost of reproducibility, scientists may produce more reproducible experiments with the same effort.
Reducing the cost is a technical problem this work attempts to solve.

For the purposes of this work, "computational scientist" (from here on, **CS**) should be construed broadly, as anyone who uses research software to carry out some investigation.
The term includes people who use research software for data analytics and for simulations, so long as scrutinizability, extensibility, and applicability are motivators.
The term applies to professors in academia as well as analysts in a national lab.

# Background

For the purposes of this work, we use the ACM definition of reproducibility:

> **Reproducibility**:
> (different team, same experimental setup)
> The measurement can be obtained with stated precision by a different team using the same measurement procedure, the same measuring system, under the same operating conditions, in the same or a different location on multiple trials.
>
> ---[@acminc.staffArtifactReviewBadging2020]

This is substantially similar to the National Academy of Sciences:

> **Reproducibility** means computational reproducibility—obtaining consistent computational results using the same input data, computational steps, methods, code, and conditions of analysis.
>
> ---TODO: cite

Naïvely, every CSE would be "reproducible", since there is some, possibly unknown, set of conditions under which another team can make the measurement; i.e., "make your environment bit-wise the same as ours".
To prevent the definition from being vacuous, we will only consider *explicitly stated* operating conditions.

This is opposed to **repeatability** (same team, same experimental setup) and **replicability** (different team, different experimental setup).

These definitions derive from _metrology_, the science of measuring, and we will specialize some of the terms "measurement", "measurement procedure", and "operating conditions" in software context for computational science experiments.

- **Measurement procedure (for CSEs)**:
  The application code and user-interactions required to run the application code (if any).

- **Operating conditions (for CSEs)**:
  A set of conditions the computer system must implement in order to run a certain program.
  E.g., GCC 12 at `/usr/bin/gcc` compiled with certain features enabled.

One may over-specify operating conditions without changing the reproducibility status.
E.g., one might say their software requires GCC 12, but really GCC 12 or 13 would work.
It is quite difficult and often not necessary to know the necessary-and-sufficient set of operating conditions, so in practice, we usually have set of conditions that is sufficient but not necessary to operate the experiment.

Operating conditions can be eliminated by moving them to the measurement procedure.
E.g., the program itself contains a copy of GCC 12.
For the purposes of this work, the operating conditions are the "manual" steps that the user has to take in order to use the measurement procedure to make the measurement.

- **Measurement (for CSEs)**:
  Rather than offer a definition, we give some examples:

  - **Crash-freedom**: program produces result without crashing.
  - **Bitwise equivalence**: output files and streams are bit-wise identical.
  - **Statistical equivalence**: overlapping confidence intervals, etc.
  - **Inferential equivalence**: whether the inference is supported by the output.
  - **Others**: domain-specific measurements/equivalences (e.g., XML-equivalence ignores order of attribtues)

In general, it is difficult to find a measurement that is both easy to assess and scientifically meaningful.

| Measurement             | Easy to assess                             | Scientifically meaningful                                     |
|-------------------------|--------------------------------------------|---------------------------------------------------------------|
| Crash-freedom           | Yes; does it crash?                        | Too lenient; could be no-crash but completely opposite result |
| Bitwise equivalence     | Yes                                        | Too strict; could be off by one decimal point                 |
| Statistical equivalence | Maybe; need to know output format          | Maybe; need to know which statistics _can_ be off             |
| Inferential equivalence | No; need domain experts to argue about it  | Yes                                                           |

**Composition of measurement procedures**: The outcome of one measurement may be the input to another measurement procedure.
This can happen in CSEs as well as in physical experiments.
In physical experiments, one may use a device to calibrate (measure) some other device, and use that other device to measure some scientific phenomenon.
Likewise, In CSE, the output of compilation may be used as the input to another CSE.
One can measure a number of relevant properties of the result of a software compilation.

| Compilation measurement            | Definition                                                       |
|------------------------------------|------------------------------------------------------------------|
| Source equivalence                 | Compilation used exactly the same set of source code as input    |
| Behavioral equivalence             | The resulting binary has the same behavior as some other one     |
| Bit-wise equivalence               | As before, the binary is exactly the same as some other one      |

E.g., suppose one runs `gcc main.c` on two systems and one system uses a different version of `unistd.h`, which is `#included` by `main.c`.
The process (running `gcc main.c`) does not reproduce source-equivalent binaries, but it might reproduce behavior-equivalent binaries or bit-wise equivalent binaries (depending on how different `unistd.h`).

::::: {.todo}

TODO: Find an appropriate place for the following ideas:

- Explain cost-benefit from researchers' perspective

- Technology adoption model (Davis 1989)

- "Computational experiment" should also be construed broadly, as any computational process for which, the first time it is run, learning the result contributes to knowledge.
  A script that starts up a web server is not a computational experiment, but a script that computes the mean of novel data on human weight is.

- Most scientists use research software, and many write their own (Hettrick); therefore, methods for reproducible software are important.

- Buckheit and Donoho: "An article about computational sci- ence in a scientific publication is not the scholarship itself, it is merely advertising of the scholarship. The actual scholarship is the complete software development environment and the complete set of instructions which generated the figures."

- Anecdotes
  - Reinhart and Rogoff corrected by Herndon et al., 2014 because source availability.
  - A scientist's nightmare (Miller, 2006)
  - Dispute between two fluid dynamics groups referenced by Hinsen
  - retraction of two papers from the Lancet and New England Journal of Medicine (Piller and Servick, s. d.). Both studies influenced international policies regarding the use of certain drugs, and they had to be quickly retracted. -- https://arxiv.org/pdf/2402.07530
  - Neil Ferguson's COVID model (Ferguson et al., 2020), for which (Pouzat, 2022) prepared a humorous article highlighting the scandal caused by the nonpublication of Ferguson's initial code. -- https://arxiv.org/pdf/2402.07530

:::::

# Related work

There are many related works that address reproducibility.
We will leverage the definitions and framework discussed above to contextualize each work.
Still, there is a significant gap in prior work that this work will exploit.

<!-- Overall, we encourage "defense-in-depth" approach that addresses reproducibility from multiple angles. -->
<!-- Synergies exist between multiple approaches. -->

## Metastudies

Reproducibility, Replicability, and Repeatability: A survey of reproducible research with a focus on high performance computing by Antunes and Hill https://arxiv.org/abs/2402.07530

## Empirical characterization of reproducibility

This group of related work seeks to characterize the degree of reproducibility in a sample of CSEs empirically either by static (analyzing the CSE code or just the presence of code) or dynamic methods (running the CSE code).
Dynamic studies can be further divided into case-studies (small N, but deep analysis) and large-scale studies (large N, shallow analysis).
Each work investigates a different kind of reproducibility or a proxy for reproducibility.

### Static

The simplest thing is to check whether the source code of a CSE is available.

- J. Austin, T. Jackson, M. Fletcher, M. Jessop, B. Liang, M. Weeks, L. Smith, C. Ingram, and P. Watson. Carmen: Code analysis, repository and modeling for e-neuroscience. Procedia CS, 4:768–777, 2011.
- Vandewalle
- Collberg and Proebsting
- Trisovic et al.
- Guiteaux et al. '24

### Dynamic case-studies

### Dynamic large-scale

- Trisovic et al.
- Zhao et al.: Why Workflows Fail
- Collberg and Proebsting
- Follow-up of Collberg and Proebsting
- Re-executions of Jupyter Notebooks
- (Mesnard and Barba, 2017) studied fluid mechanics and found that it took three years to reproduce the results obtained from their own tools using two other tools and a parallel version of their tool. -- https://arxiv.org/pdf/2402.07530
- As demonstrated by (Gundersen and Kjensmo, 2018), artificial intelligence is also not an exemption. -- https://arxiv.org/pdf/2402.07530
-  In the networking domain, (Kurkowski et al., 2005) found that less than 15% of papers on MANET (Mobile ad hoc networks) network simulations were reproducible. -- https://arxiv.org/pdf/2402.07530
-  In image processing,(Kovacevic, 2007) studied 15 published papers in her field and found that none of the presented algorithms were supported by any code, and only 33% of the data were available. -- https://arxiv.org/pdf/2402.07530
- (Vandewalle et al., 2009) examined 134 papers in the same field and found that 9% of the papers had codes available, and 33% had data. -- https://arxiv.org/pdf/2402.07530

Prior works on large-scale quantitative reproducibility studies can be split into those whose reproduction is assessed by automatic means versus a manual effort.

Zhao et al.~\cite{zhao_why_2012} evaluate automatic reproducibility of Taverna workflows from the myExperiment registry.
However, Taverna is now defunct, and there have been many changes since 2012 (see \Cref{table:tools}), so we should expect the results to change.
Furthermore, Zhao et al.\ do not examine the correlation of crashes with time or the kinds of outputs when the execution is crash-free.

Trisovic et al.~\cite{trisovic_large-scale_2022} evaluate automatic reproducibility of R code from the Harvard Dataverse repository.
While Trisovic et al.\ propose to study reproducibility based on R version and time (in their RQ8), they treat time as a categorical variable and do not perform a statistical analysis to generalize their data.
Furthermore, Trisovic et al.'s reproduction of R code does not include the order in which the scripts in a single project were originally run, so it incurs failures that may be simply due to a wrong order; our work studies workflows, which avoid the ordering problem because the workflow specifies dependencies between tasks.

Pimentel et al.~\cite{pimentel_large-scale_2019} and Wang et al.~\cite{wang_assessing_2021} automatically run Jupyter Notebooks from GitHub.
Jupyter Notebooks have different strengths and use-cases than workflows.
Jupyter Notebooks are usually used for small, interactive jobs, whereas workflows are used for large, batch-processing jobs \cite{koster_snakemakescalable_2012,di_tommaso_nextflow_2017}.
For example, Snakemake and Nextflow \emph{at the language-level} both provide facilities to run jobs on a cluster.
Snakemake and Nextflow, \emph{by default}, write intermediate results to disk so that workflows can be resumed if the node halts or needs to be restarted.
While both batch-scheduling submission, crash-recovery, and containerization can be implemented in Python, workflow engines are more specialized for analyzing data at a large scale.
Therefore, we expect that the reproducibility characteristics can be quite different.
For example, Wang et al.\ find that using one set of Python packages, namely those in the default Anaconda distribution\footnote{See \url{https://www.anaconda.com/}}, was sufficient for running their evaluation; in contrast, workflows in Snakemake and Nextflow often provide a distinct set of Python packages \emph{for each task}!
Finding the correct set of packages is non-trivial, as we will see in RQ2.

As an example of manual reproduction, Krafczyk et al.\ execute an in-depth case study on a small set of computational experiments~\cite{krafczyk_learning_2021}.
Stodden et al.~\cite{stodden_best_2014} perform case studies with specific attention to journal policies.
The case-study methodology is helpful for in-depth results but has difficulty generalizing the results to an entire population.
Our work attempts an automatic reproduction of a large set of experiments to address population-level questions but does not perform an in-depth analysis of a small subset.

### What are common reasons software is not reproducible?

We should address one of those.

## Proactively ensuring reproducibility

### Metastudies

- Lazaro Costa

### Literate programming

- Jupyter, Amazon Sagemaker, Google Colab, Deepnote, Hex, Databricks Notebooks, DataCamp Workspace, JupyterLab, HyperQuery, Jetbrains Datalore, kaggle, NextJournal, Noteable, nteract, Observable, Query.me, VS Code notebooks, Mode Notebooks, Querybook, Zeppelin, Count, Husprey, Pluto.jl, Polynote, Zepl -- https://datasciencenotebook.org/
- Ten Simple Rules for Reproducible Research in Jupyter Notebooks by Rule et al. https://arxiv.org/abs/1810.08055
- Jupyter
- Binder
- S. Li-Thiao-T. Literate program execution for reproducible research and executable papers. Procedia CS, 9:439–448, 2012
- D. Koop, E. Santos, P. Mates, H. T. Vo, P. Bonnet, B. Bauer, B. Surer, M. Troyer, D. N. Williams, J. E. Tohline, J. Freire, and C. T. Silva. A provenance-based infrastructure to support the life cycle of executable papers. Procedia CS, 4:648–657, 2011

### Source archival

- Software Heritage Archive
- ACM REP '23 and ACM REP '24 have work on this
- DOI

### Workflows

- Taverna
- VizIt
- Galaxy
- WorkflowHub
- Connection between workflow and provenance

### Provenance

- What is provenance? Survey of provenance by (Freire)
- How does provenance connect to reproducibility

### Record/replay tools

- CDE
- RR
- CARE
- Sciunit (Malik)
- ReproZip
- Sumatra
- Preserving the mess or encouraging cleanliness (Thaine)

### Version control

### Virtualization and containerization

- How does virtualization and containerization connect to reproducibility
  - Docker
  - Singularity

### Package managers

- How do package managers connect to reproducibility
  - Nix
  - Guix
  - Spack

### Scientific clouds

- How/why scientific clouds can/can't help with reproducibility
  - WholeTale
  - Google Colab
  - PaperMill (I think that was the name?)
  - GalaxyHub.eu
  - G. R. Brammer, R. W. Crosby, S. Matthews, and T. L. Williams. Paper mch: Creating dynamic reproducible science. Procedia CS, 4:658–667, 2011.
  - V. Stodden, C. Hurlin, and C. Perignon. Runmycode.org: A novel dissemination and collaboration platform for executing published computational results. In eScience, pages 1–8. IEEE Computer Society, 2012.

## Retroactively restoring reproducibility

- Automatic build repair for reproducibility
- Cindy Rubio-Gonzales
- ShipWright
- Jupyter studies

## Other aspects of reproducibility

- Relationship to replicability
- Definitions/terms
- (Marwick, 2015) highlighted the challenge posed by computer programs: they act as black boxes. -- https://arxiv.org/pdf/2402.07530
- Collberg and Proebsting responses to study
- How to address source code sharing
  - Collberg and Proebsting responses to code sharing
  - Stodden
  - ACM REP '23 and ACM REP '24 have work on this
  - Incentives
    - Artifact badging
    - Vandewalle et al.
- FAIR for RSware
- Why does RSE work matter for reproducibility?
  - Bridging the gaps
- Findability
  - M. Gavish and D. Donoho. A universal identifier for computational results. Procedia CS, 4:637-647, 2011.
- Software citation
- Publishing modes/executable papers
  - Research notebooks
  - Semantic description of hypothesis
  - P. V. Gorp and S. Mazanek. Share: a web portal for creating and sharing executable research papers. Procedia CS, 4:589–597, 2011
- J. Kovaˇcevi ́c. How to encourage and publish reproducible research. In IEEE International Conference on Acoustic Speech Signal Processing, volume IV, pages 1273–1276, Apr. 2007.
- Journals
  - N. Limare. Running a reproducible research journal, with source code inside. In ICERM Workshop, 2012.
  - ReScienceC (Rougier et al. 2017)
  - An increasing number of journals and conferences are concerned with the reproducibility of published articles (Drummond, 2018) (Bajpai et al., 2019). 
- Copyright
  - V. Stodden. The legal framework for reproducible scientific research: Licensing and copyright. Computing in Science and Engineering, 11(1):35–40, 2009.
- Domain-specific testbeds
  - Networking guy from ACM REP '24
  - Triscale
- We found one survey providing state-of-the-art reproducibility in scientific computing (Ivie and Thain, 2018), and several books attempting to do so (Desquilbet et al., 2019) (National Academies of Sciences, 2019) (Randall and Welser, 2018). -- https://arxiv.org/pdf/2402.07530 
- In his article (Drummond, 2018), Drummond asserted that sharing the source code of an article is unnecessary. He believes that researchers are forced to do so to avoid getting a bad label but that it does not serve science. For him, the reproducible research movement was not based on facts, but only on intuition. He adds that the obligation to provide the source code will lead to papers being accepted based on technically weak criteria and that, according to his opinion, fraud has always existed and never posed a significant problem. However, Drummond supports the concept of open science. -- https://arxiv.org/pdf/2402.07530

# My research strategy

Irreproducible science (end problem) -> computational irreproducibility (cause) -> source inavailability (cause), crash-free computational irreproducibility (proxy) -> {pro-active activities with limited cost, re-active responses}

source inavailability (cause) -> cost of supporting reproduction

pro-active -> PROBE archive

re-active -> PROBE with automated environment exploration

Translational CS

# My completed work

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
