# Problem

Reproducibility of scientific experiments is important for three
reasons:

1.  The scientific community corrects false claims by applying scrutiny
    to each others' experiments. Scrutinizing an experiment often
    includes reproducing it. Therefore, reproducible experiments may be
    thoroughly scrutinized.
2.  Science works by building off of the work of others. Often in
    extending anothers work, one needs to execute a modified version of
    their experiment. If reproducing the same experiment is difficult,
    one would expect executing an extended version to be even more so.
    Therefore, reproducible experiments may be easier to extend.
3.  The end-goal for some science is to be applied in engineering
    applications. Applying a novel technique on new data involves
    reproducing a part of the experiment which established the novel
    technique. Therefore, reproducible experiments may be easier to
    apply in practice.

Reproducibility also has costs, primarily in human labor needed to
explain the experiment beyond that which would be needed to merely
disseminate the results. Working scientists balance the cost of
reproducibility with the benefits to society or to themselves.

In real-world experiments, there are an infinitude of possible factors
that must be controlled to find the desired result; it would be
unfathomable that two instantiations of an experiment could give exactly
identical results. In contrast, for computational science experiments
(from here on, **CS Exp**) on digital computers, while there are still
many factors to be controlled, perfect reproduction is quite fathomable.
Despite this apparent advantage, CS Exps on digital computers still
suffer low rates of reproducibility.

![Figure 1: Effort-vs-reproducibility tradeoff curve in the status quo
and with reproducibility tools](./plot0.pdf){#fig:effort width="50%"}

The status quo will not change simply by arguing for reproducibility;
those arguments are widely known are already taken into account by the
efficient market. Nor do I have the power to change incentives in
science funding policy. However, by reducing the cost of
reproducibility, scientists may produce more reproducible experiments
with the same effort (fig. 1). Reducing the cost is a technical problem
this work attempts to solve.

For the purposes of this work, "computational scientist" (from here on,
**CS**) should be construed broadly, as anyone who uses research
software to carry out some investigation. The term includes people who
use research software for data analytics and for simulations, so long as
scrutinizability, extensibility, and applicability are motivators. The
term applies to professors in academia as well as analysts in a national
lab.

# Background

There have been conflicting sets of definitions for the terms
*reproducibility* [@plesserReproducibilityVsReplicability2018]. In this
work we will use the Association for Computing Machinery (from here on,
**ACM**) definition, if unspecified, although we will discuss the other
definitions in the prior work section. The ACM gave a compatible
definition,

> **Reproducibility**: (different team, same experimental setup) The
> measurement can be obtained with stated precision by a different team
> using the same measurement procedure, the same measuring system, under
> the same operating conditions, in the same or a different location on
> multiple trials.
>
> --- [@acminc.staffArtiftReviewBadging2020]

This is opposed to **repeatability** (same team, same experimental
setup) and **replicability** (different team, different experimental
setup).

The ACM definition references more useful auxiliary terms, such as
measurement procedure, operating conditions, stated precision, etc., so
we will use that one for this work.

Naïvely, every CSE would be "reproducible", since there is some,
possibly unknown, set of conditions under which another team can make
the measurement; i.e., "make your environment bit-wise the same as
ours". To prevent the definition from being vacuous, we will only
consider *explicitly stated* operating conditions.

These definitions derive from *metrology*, the science of measuring, and
we will specialize some of the terms "measurement", "measurement
procedure", and "operating conditions" in software context for
computational science experiments.

-   **Measurement procedure (for CSEs)**: The application code and
    user-interactions required to run the application code (if any).
-   **Operating conditions (for CSEs)**: A set of conditions the
    computer system must implement in order to run a certain program.
    E.g., GCC 12 at `/usr/bin/gcc` compiled with certain features
    enabled.

One may over-specify operating conditions without changing the
reproducibility status. E.g., one might say their software requires GCC
12, but really GCC 12 or 13 would work. It is quite difficult and often
not necessary to know the necessary-and-sufficient set of operating
conditions, so in practice, we usually have set of conditions that is
sufficient but not necessary to operate the experiment.

Operating conditions can be eliminated by moving them to the measurement
procedure. E.g., the program itself contains a copy of GCC 12. For the
purposes of this work, the operating conditions are the "manual" steps
that the user has to take in order to use the measurement procedure to
make the measurement.

-   **Measurement (for CSEs)**: Rather than offer a definition, we give
    some examples:
    -   **Crash-freedom**: program produces result without crashing.
    -   **Bitwise equivalence**: output files and streams are bit-wise
        identical.
    -   **Statistical equivalence**: overlapping confidence intervals,
        etc.
    -   **Inferential equivalence**: whether the inference is supported
        by the output.
    -   **Others**: domain-specific measurements/equivalences (e.g.,
        XML-equivalence ignores order of attribtues)

In general, it is difficult to find a measurement that is both easy to
assess and scientifically meaningful.

  --------------------------------------------------------------------------
  Measurement     Easy to assess          Scientifically meaningful
  --------------- ----------------------- ----------------------------------
  Crash-freedom   Yes; does it crash?     Too lenient; could be no-crash but
                                          completely opposite result

  Bitwise         Yes                     Too strict; could be off by one
  equivalence                             decimal point

  Statistical     Maybe; need to know     Maybe; need to know which
  equivalence     output format           statistics *can* be off

  Inferential     No; need domain experts Yes
  equivalence     to argue about it       
  --------------------------------------------------------------------------

**Composition of measurement procedures**: The outcome of one
measurement may be the input to another measurement procedure. This can
happen in CSEs as well as in physical experiments. In physical
experiments, one may use a device to calibrate (measure) some other
device, and use that other device to measure some scientific phenomenon.
Likewise, In CSE, the output of compilation may be used as the input to
another CSE. One can measure a number of relevant properties of the
result of a software compilation.

  -----------------------------------------------------------------------
  Compilation          Definition
  measurement          
  -------------------- --------------------------------------------------
  Source equivalence   Compilation used exactly the same set of source
                       code as input

  Behavioral           The resulting binary has the same behavior as some
  equivalence          other one

  Bit-wise equivalence As before, the binary is exactly the same as some
                       other one
  -----------------------------------------------------------------------

E.g., suppose one runs `gcc main.c` on two systems and one system uses a
different version of `unistd.h`, which is `#included` by `main.c`. The
process (running `gcc main.c`) does not reproduce source-equivalent
binaries, but it might reproduce behavior-equivalent binaries or
bit-wise equivalent binaries (depending on how different `unistd.h`).

# Related work

There are many related works that address reproducibility. We will
leverage the definitions and framework discussed above to contextualize
each work. Still, there is a significant gap in prior work that this
work will exploit. Prior work can be divided into these categories,
which we will investigate in turn:

1.  Characterizing reproducibility in theory or in practice
2.  Studying approaches associated with proactively ensuring
    reproducibility ``{=html}

## Characterizing reproducibility

Several prior works attempt to characterize reproducibility in theory or
in empirical data.

### Characterizing reproducibility in theory

Theoretical characterization begins by defining reproducibility.

Claerbout and Karrenbach give,

> Running the same software on the same input data and obtaining the
> same results

> --- [@claerboutElectronicDocumentsGive1992]

which many other works use. Replicability was defined later as

> Writing and then running new software based on the description of a
> computational model or method provided in the original publication,
> and obtaining results that are similar enough
>
> --- [@rougierSustainableComputationalScience2017]

However, the ACM opted to use the terms how they were defined in
metrology, which resulted in the same definitions being applied to
opposite words as Claerbout and Karrenbach
[@herouxCompatibleReproducibilityTaxonomy2018,
@plesserReproducibilityVsReplicability2018]. But the ACM revised their
definitions to be compatible with Claerbout and Karrenbach in 2020
[@acminc.staffArtifactReviewBadging2020], so the definitions are mostly
in consensus.

### Empirical characterization of reproducibility

This group of related work seeks to characterize the degree of
reproducibility or a proxy for reproducibility in a sample of CSEs
empirically. A proxy variable could be "whether the source is
available", since this is a necessary but not sufficient condition for
reproducibility.

  -------------------------------------------------------------------------------------------------------------------
  Publication                                     N             Subjects    Population   Repro measurement  Level
                                                                                         assessed or proxy  
                                                                                         variable           
  ----------------------------------------------- ------------- ----------- ------------ ------------------ ---------
  @vandewalleReproducibleResearchSignal2009       134           Article     2004 ed. of  Code availability  9%
                                                                artifacts   img. proc.                      
                                                                            journal                         

  @zhaoWhyWorkflowsBreak2012                      92            Taverna     myExp. 2007  Crash-free         29%
                                                                workflows   -- 2012      execution          

  @collbergRepeatabilityComputerSystems2016       508[^1]       Source code 2012 eds. of Crash-free         48%
                                                                            CS journals  compilation        

  @gundersenStateArtReproducibility2018           400           Article     2013 -- 2016 Sufficient         24%[^2]
                                                                artifacts   AI journals  description        

  @pimentelLargeScaleStudyQuality2019             863,878[^3]   Jupyter     GitHub       Same-stdout        4%
                                                                notebooks                execution          

  @krafczykLearningReproducingComputational2021   5             Articles    Journal of   Figures and tables 70%[^4]
                                                                artifacts   Comp. Phys.  semantic           
                                                                                         equivalence        

  @wangAssessingRestoringReproducibility2021      3,740[^5]     Jupyter     GitHub       Crash-free         19%
                                                                notebooks                execution          

  @trisovicLargescaleStudyResearch2022            2,109[^6]     R scripts   Harvard      Crash-free         12%
                                                                            Dataverse    execution          
  -------------------------------------------------------------------------------------------------------------------

Note that crash-freedom is prevalent because it is the easiest to
automatically assess. Source-availability requires human-intervention to
test, so studies on crash-freedom simply begin from a corpus for which
source code is available. Note that stdout-equivalence is feasible
because Jupyter Notebooks bundle the stdout with the code; otherwise,
the stdout is usually thrown away.

Overall, these studies show that reproducibility is a significant
problem.

Some of the studies, like Zhao et al., investigate the *reason* why some
samples were not reproducible [@zhaoWhyWorkflowsBreak2012], finding

  Reason                                        Proportion of failures
  --------------------------------------------- ------------------------
  Unavailable/inaccessible 3rd party resource   41%
  Updated 3rd party resource                    7%
  Missing example data                          14%
  Insufficient execution environment            12%
  Insufficient metadata                         27%

Zhao et al. remark that provenance could preserve or enable repair for
several classes of failures, including unavailability of 3rd party
resources and insufficient descriptions. We will investigate this
approach in my proposed work.

## Proactively ensuring reproducibility

There are several proposed approach associated with proactively
facilitating reproducibility:

  --------------------------------------------------------------------------
  Approach                          Aspect of reproducibility addressed
  --------------------------------- ----------------------------------------
  Scientific clouds                 Reduces non-portable operating condions

  Source artifact archival          Ensure attainability of operating
                                    condition

  Workflowanagers                   Simplify measurement procedure

  Provenance                        Identifies operating conditions

  Record/replay executions          Reduces operating conditions

  Virtualization/containerization   Reduces non-portable operating
                                    conditions

  Digital notebooks                 Explicates measurements
  --------------------------------------------------------------------------

## Scientific clouds

Scientific clouds facilitate reproducibility by replacing a complex set
of operating conditions ("install this, configure that") with a single
opeting condition: log in to a cloud system. The cloud system hosts a
controlled environment with t rest of the operating conditions already
met.

However, storing the environments and running executis in them is
expensive. Either the users have to pay, in which case the computational
environment is not "freely accessible", orome institution may sponsor
public-access. Institutional grants for public-access may be indefinite
or it may only last for a certain aunt of time due to funding
constraintstbl. 1).

::: {#tbl:sci-clouds}
  --------------------------------------------------------------------------------------------------------------------------------------------------------
  Scientific    URL                    Lifetime on   Main publication                                                                                   
  Cloud                                Archive.org                                                                                                      
  ------------- ---------------------- ------------- ----------------------------------------------------- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  Binder        mybinder.g             2018 --       @jupyterBinder20Reproducible2018                                                                   
                                       present                                                                                                          

  Chameleon     chameleoncloud.org     2015 --resent @keaheyLessonsLearnedChameleon2020                                                                 
  Cloud                                                                                                                                                 
  (federated)                                                                                                                                           

  PhenoMeNal    phenomenal-h2020.eu    2017 -- 2023  @petersPhenoMeNalProcessingAnalysis2019                                                            
  portal                                                                                                                                                

  WholeTal      WholeTale.org          2016 --       @brinckmanComputingEnvironmentsReproducibility2019a                                                
                                       present                                                                                                          

  GridSpace2    gs2.plgrid.pl          2015 -- 2020  @ciepielaGridSpace2VirtualLaboratory2012                                                           

  Collage       collage.elsevier.com   2013 -- 2014  @nowakowskiCollageAuthoringEnvironment2011                                                         
  Authoring                                                                                                                                             
  Environment                                                                                                                                           

  RunMyCode     RunMyCode.org          2012 -- 2024  @stoddenRunMyCodeorgNovelDissemination2012                                                         

  SHARE                                2011 -- 2023  @vangorpSHAREWebPortal2011                                                                         

  Galaxy        usegalaxy.org          2007 --       @thegalaxycommunityGalaxyPlatformAccessible2024                                                    
  (federated)                          present                                                                                                          

  GenePattern   GenePattern.org        2006 --       @reichGenePattern202006                                                                            
                                       present                                                                                                          
  --------------------------------------------------------------------------------------------------------------------------------------------------------

  : Table 1: Various scientific clouds found in prior work, by creation
  date.
:::

An improvement on this model is the *federated model* (as in Galaxy
[@thegalaxycommunityGalaxyPlatformAccessible2024]), where the compute
infrastructure could be provided by multiple parties which themselves
may be free-access, pay-for-access, or locally hosted servers. So long
as the user can reserve compute resources on any *one* of them, they can
import and run the CSE. Federation doesn't alleviate the funding
problem, but it does spread out the funding problem; if the original
grant runs out, some other institution can pick up the torch. If all
else fails, technically savvy individuals can run servers for just
themselves (so-called "self-hosting"). However, federation trades off
with standardization and consistency; a CSE may only work with certain
infrastructure providers.

### Literate programming and digital notebooks

The idea of literate programming according to Knuth is to mix narrative
and explanation into code.

> Instead of imagining that our main task is to instruct a computer what
> to do, let us concentrate rather on explaining to human beings what we
> want a computer to do.
>
> --- [@knuthLiterateProgramming1984]

Digital notebooks or electronic lab notebooks extend this to also
include multimedia, such as graphs, widgets, and other data
visualizations. Popular digital notebooks include: Jupyter, Amazon
Sagemaker, Google Colab, Deepnote, Hex, Databricks Notebooks, DataCamp
Workspace, JupyterLab, HyperQuery, Jetbrains Datalore, kaggle,
NextJournal, Noteable, nteract, Observable, Query.me, VS Code notebooks,
Mode Notebooks, Querybook, Zeppelin, Count, Husprey, Pluto.jl, Polynote,
Zepl[^7].

Digital notebooks facilitate reproducibility by:

-   encoding the measurement itself, which may otherwise be printed to
    `stdout` and not distributed.
-   encoding the explanation for the measurement procedure, making it
    easier to adapt if errors or difference arise.
-   automating data analysis steps that would otherwise by typed into an
    interpreter and n saved.

However, digital notebooks still require a separate way of specifying
the software environment (operating conditions). Repo2docker, famously
used by the scientific cloud Binder, standardizes a way of specifying
the software environment for notebooks contained in a repository by
leveraging off-the-shelf package managers
[@jupyterBinder20Reproducible2018]. We will discuss package managers as
a solution foreproducibility later on; the pointtill stands that
literate programming requires other methods to manage the soware
environment in order to attain reproducibility.

### Source code archival

Source code archives (tbl. 2) facilitate reproducibity by making
operating conditions namable and satisfiable. Giving software and
software versions a unique identifier makes the operating conditions
explicitly namable. Namability approaches include Digital Object
IdentifiersDOI), Archival Resource Key (ARK), Uniform Resource Names
(URNs), and persistt URLs (PURLs).!-- TODOCitations or table

https://arks.org/ \--\>

Archiving old versions of core software helps conditions remain
satisfiable, since old versions may otherwise get deleted or become
unfindable.

::: {#tbl:source-archival}
  -----------------------------------------------------------------------------------------
  Source Code      Description          Lifetime   Main publication
  archive                                          
  ---------------- -------------------- ---------- ----------------------------------------
  Software         Collects codes in    2016 --    [@dicosmoCuratedArchivingResearch2020]
  Heritage Archive other sources        present    

  Zenodo           User-uploaded        2013 --    [@siciliaCommunityCurationOpen2017]
                   research codes       present    

  FigShare         User-uploaded        2012 --    [@singhFigShare2011]
                   research codes       present    
  -----------------------------------------------------------------------------------------

  : Table 2: Source Archives by creation date.
:::

Storing source code in central archives shares some of the disavdantages
of scientific clouds, but to a lesser extent. Merely storing scientific
software is much easier than offering to execute them on-demand. Indeed,
all of the source archival solutions we found in prior literature are
still alive today; the same cannot be said for scientific clouds.

While source code archival does help with unfulfillable conditions, it
still requires someone or something to actually set up, configure,
build, and install the source code to actually satisfy the condition
"install this version of that software". Other methods should work in
concert, falling back on source code archival if the code is no longer
available from the original hoster.

### Workflow managers

A workflow manager is a system that executes a directed acyclic graph of
loosely coupled, coarse nodes. Usually, each node is a process and each
edge is a file.

Workflow managers facilitate reproducibility by:

-   Explicitly stating parts of the measurement procedure that would
    otherwise be unwritten (which script to run, in what order)
-   Letting systems reason about the inputs and outputs of the
    measurement procedure

Moelder ``{=html} et al. [@molderSustainableDataAnalysis2021] give
classify workflow engines by their interface (tbl. 3) which we extend.
The interface can be graphical, a library in a general purpose language
(GPL), a domain specific language (DSL), or a data definition language
(such as YAML). We reclassified the workflow managers in Moelder's
system-independent class, since that does not refer to the interface,
and we added other common workflow managers that have more than 1
workflow example in the registries listed in
<https://workflows.communities/registries>

::: {#tbl:wfs}
  Workflow Manager                           Interface
  ------------------------------------------ --------------------------
  Galaxy                                     Graphical
  KNIME                                      Graphical
  Scipion                                    Grpahical
  COMPS (in Java)                            Library in GPL
  Parsl (in Python)                          Library in GPL
  Dask (in Python)                           Library in GPL
  Pegasus (in Python, Java, R)               Library in GPL
  Luigi (in Python)                          Library in GPL
  Nextflow                                   DSL
  Snakemake                                  DSL
  Workflow Description Language (WDL)        DSL
  Bpipe                                      DSL
  Common Workflow Language (CWL) (in YAML)   Data Definition Language

  : Table 3: Common workflow managers classified by interface. More
  available here: <https://github.com/meirwah/awesome-workflow-engines>
:::

Additionally, there are other ways to classify workflows, including
parallelism (task, data, both, neither), static vs dynamic scheduling
[@liuSurveyDataIntensiveScientific2015]. Workflows can be subjectively
evaluated based on clarity, well-formedness, predictability,
recordability, reportability, reusability, scientific data modelling,
and automatic optimization [@mcphillipsScientificWorkflowDesign2009].

Workflow managers often represent a departure from what the user is
currently doing, and therefore take significant effort to adopt.
Aditionally, workflow managers introduce another dependency which needs
to be managed with another reproducibility strategy.

### Provenance

Computational provenance (henceforth, **provenance**) is the processes
that generated a computational artifact, the inputs to that provenance,
and the provenance of those inputs (recursively)
[@freireProvenanceComputationalTasks2008]. Provenance facilitates
reproducibility by explicitly stating the inputs (operating conditions).

There are four levels at which one can capture computational provenance
[@freireProvenanceComputationalTasks2008] (tbl. 4):

-   **application-level**: modifying an application to report provenance
    data.
-   **workflow-level** or **language-level**: leveraging a workflow
    engine or programming language to report provenance data.
-   **system-level**: leveraging an operating system to report
    provenance data.
-   **service-level**: recording provenance at the boundaries between
    services in a system.

::: {#tbl:provs}
  Provenance system   Level
  ------------------- ---------------------------------
  REDUX               Workflow-level
  Swift               Worfklow-level
  VisTrails           Workflow-level
  Kepler              Workflow-level
  Taverna             Workflow-level
  PASS                System-level
  ES3                 System-level
  Sumatra             System-level
  PASOA               Service-level
  Karma               Workflow-level or service-level
  noWorkflow          Language-level

  : Table 4: Provenance capturing systems for CSE in prior work.
:::

More provenance systems and classifications are discussed in the First
Provenance Challenge [@moreauSpecialIssueFirst2008].

Most of these provenance systems are implemented at a workflow-level or
service-level, so they are only applicable to users of that workflow or
service. System-level could be more generally usable by any program
running in that system. However, neither Sumatra, PASS, nor ES3 leverage
the provenance to create automatic replay. These methods help
reproducibility, but they do not deliver "push button" reproducibility,
which we need to extract the maximum value from the minimum amount of
work.

noWorkflow attempts to capture provenance for arbitrary Python programs
[@murtaNoWorkflowCapturingAnalyzing2015]. Python provenance could be
useful for projects whose data processing is primarily Python, however
it would not be able to track data past that boundary.

### Record/replay tools

Record/replay is a feature where the user executes an unmodified program
in a "record" environment, which creates a reproducibility package. The
reproducibility package can be stored or distributed, and later on, the
user can "replay" the same execution from it.

  Record/replay   Capture method
  --------------- -----------------------
  CDE             Ptrace
  RR              Ptrace
  CARE            Ptrace
  Sciunit         Ptrace
  ReproZip/PTU    Ptrace
  OPUS            Library interposition
  PROV-IO         Library interposition
  bpftrace        eBPF
  PASS            Kern. mod.
  CamFlow         Kern. mod.

While record/replay is a convenient user-interface, none of the
implementations are fast and run without super user. Scientific users
rarely have super user privileges on shared hardware; root "in
container" is not strong enough to install kernel modules or eBPF
programs. The overhead of conventional record/replay tools is often more
than 2x, making them infeasible to use in many cases.

One might argue that record/replay "allows" users to be messy and merely
preserves the mess perfectly
[@douglasthainTechniquesPreservingScientific2015]. Simply copying the
entire filesystem, for example, may work (the operating conditions are
likely contained in the filesystem), but an entire filesystem
inconvenient to transfer, compose, and execute. An ideal record/replay
tool should allow users to introspect and simplify their computational
environment.

-   Preserving the mess or encouraging cleanliness (Thaine)

### Virtualization and containerization

System virtualization facilitates reproducibility by encapsulating an
entire system (and thus its operating conditions) in a distributable
sandbox. System virtualization drivers include QEMU, VirtualBox, VMWare
Fusion, Parallels for Mac, etc.

Containerization is similar, but it only encapsulates Linux userspace,
reusing the hosts Linux kernel. On non-Linux hosts, the container is
nested inside a virtualized Linux instance. Containerization has weaker
isolation than system virtualization but better performance and lower
storage. Container engines include Docker, Podman, and Singularity.

In either case, either the system image has to be distributed (VM image,
Docker image, etc.) or instructions to build the system image (e.g.,
`Vagrantfile`, `Dockerfile`, `Singularityfile`, etc.).

-   Distributing the image is difficult because it is large, expensive
    to store, and expensive to transfer. DockerHub, a popular storage
    space for Docker images, recently changed their policy to remove
    images that had not been pulled or pushed in the past six months
    [@demorlhonScalingDockersBusiness2020], although enforcement was
    delayed until 2021 [@demorlhonDockerHubImage2020].
-   The build instructions, although easy to distribute, require
    *another* reproducibility strategy to be reproducible. It simply
    redirects the problem of CSE irreproducibility to Docker image
    irreproducibility.

# My research strategy

Good research begins by investigating the empirical evidence and
investigating the theoretical underpinnings. By looking at both, one can
begin to identify the problems and solutions. Empirical study of
reproducibility should include not only the rate of ir/reproducibility
but the reasons for irreproducibility. Future work should target only
the most common reasons.

A theoretical framework is necessary because there are so many
approaches that address reproducibility, it is useful to say what this
approach does that the others do not. I.e., in what sense is the
approach "more" reproducible?

System-level provenance can identify the relevant parts of the software
environment "for free". Once the provenance is produced, one can easily
create a replication package that can be replayed on any
hardware-compatible machine, resembling a record/replay tool for
arbitrary programs.

A record/replay tool addresses achieves a high-level of reproducibility,
according to our theoretical framework, with a little amount of effort.
Almost no instruction is necessary to reproduce the software. Not only
does record/replay increase reproducibility, it addresses one of the
most common reasons against sharing source (difficulty of answering
questions about how to reproduce the software).

There are numerous applications for provenance (workflow conversion,
incremental computation), ``{=html} so the provenance tracer should
connect with existing provenance standards and provenance applications
to form a suite of related tools.

Finally, the provenance tracer should be validated through user studies
or case studies. Unexpected problems and invalidated assumptions often
arise when trying to convert research into practice
[@besseyFewBillionLines2010]. Trying to apply to practice will make my
research more impactful and give me novel problems and assumption-sets
to operate in. ``{=html}

# Completed work

In this section, I outline my completed work on this subject.

## Lifetime of workflows in sample

We attempted to run workflows in two large registries: Snakemake
Workflow Catalog (SWC) and nf-core
[@graysonAutomaticReproductionWorkflows2023]. Of these, about half had
at least one non-crashing revision tbl. 5. For those whose most recent
revision did not crash, we looked how far back we could go before we
found a crashing revision. Evaluating old software today approximates
the failure rate of evaluating today's software in the future. We found
that workflows had a median failure rate of a couple of years fig. 2.

::: {#tbl:crashes}
  ---------------------------------------------------------------------------
  Quantity                                              All   SWC   nf-core
  ----------------------------------------------------- ----- ----- ---------
  \# workflows                                          101   53    48

  \# revisions                                          584   333   251

  \% of revisions with no crash                         28%   11%   51%

  \% of workflows with at least one non-crashing        53%   23%   88%
  revision                                                          
  ---------------------------------------------------------------------------

  : Table 5: Statistics on workflows in SWC and nf-core.
:::

![Figure 2: Survival curve analysis of
workflows](SurvivalCurveUpdated.png){#fig:survival width="50%"}

When the workflows failed, we classified the crash reason tbl. 6. The
most common kind of crash is simply a missing input. The workflow
manager could not help in this case, because the missing input is not an
internal node, but a top-level node, where the workflow manager would
read a file from the outside system. Provenance tracing could help
automatically upload inputs that a workflow needs to run.

::: {#tbl:wf-failures}
  Kind of crash                    Proportion
  -------------------------------- --------------
  Missing input                    32%
  Conda environment unsolvable     11%
  Unclassified reason              8%
  Timeout reached                  7%
  Container error                  6%
  Other (workflow script)          6%
  Other (containerized task)       1%
  Network resource changed         1%
  Missing dependency               0.5%
  No crash                         28%
  ------------------------------   ------------
  Total                            100%

  : Table 6: Workflow failure reasons
:::

## Literature review and evaluation of record/replay tools

We executed a rapid literature review to systematically search for
system-level provenance collectors in prior literature
[@graysonBenchmarkSuitePerformance2024]. We arrived at a list of 45, and
then:

-   Selected only thsoe that worked for Linux (39).
-   From those, selected those which did not use VMs (37).
-   From those, selected those which did not require source-code
    recompilation (35).
-   From those, selected those which did not require special hardware
    (31).
-   From those, selected those which had source code available (20).
-   From those, selected those which did not require a custom kernel
    (15).
-   From those, attempted to reproduce 10.
-   From those, selected those which successfully completed all of the
    benchmarks (5): ReproZip, strace, fsatrace, CARE, and RR.

Unfortunately, there is no standard set of benchmarks used to evaluate
system-level provenance tracers. Therefore, we also extracted all of the
benchmarks used in any work returned by this search (tbl. 7).

::: {#tbl:bmarks}
  ------------------------------------------------------------------------
  Prior works This work  Category
  ----------- ---------- -------------------------------------------------
  12          yes        HTTP server/traffic

  10          yes        HTTP server/client

  10          yes        Compile user packages

  9           yes        I/O microbenchmarks (lmbench + Postmark)

  9           no         Browsers

  6           yes        FTP client

  5           yes        FTP server/traffic

  5           yes        Un/archive

  5           yes        BLAST

  5           yes        CPU benchmarks

  5           yes        Coreutils and system utils

  3           yes        cp

  2           yes        VCS checkouts

  2           no         Sendmail

  2           no         Machine learning workflows (CleanML, Spark,
                         ImageML)

  1           no         Data processing workflows (VIC, FIE)
  ------------------------------------------------------------------------

  : Table 7: Benchmarks from prior works and this work.
:::

Between these five, we ran the extracted benchmarks in the provenance
tracers (tbl. 8). We measured the percent overhead from native case, so
a value of 50% means the new runtime would be the native runtime times
1.5. We can see that none of the existing provenance collectors are fast
enough for practical use, except for fsatrace. The salient difference is
that the other provenance tracers use ptrace to capture the underlying
calls, while fsatrace uses `LD_PRELOAD`. ptrace involves four context
switches on every system call: one from the tracee to the kernel, one
from the kernel to the tracer, one from the tracer to the kernel, and
one from the kernel to the tracee. `LD_PRELOAD` involves *no* extraneous
context switches. Therefore, we build on the underlying technology of
fsatrace in our future work.

::: {#tbl:perf}
  -------------------------------------------------------------------------------------
  Benchmark            Native     fsatrace     CARE     strace     RR      ReproZip
  -------------------- ---------- ------------ -------- ---------- ------- ------------
  BLAST                0          0            2        2          93      8

  Tar Unarchive        0          4            44       114        195     149

  Python import        0          5            85       84         150     346

  VCS checkout         0          5            71       160        177     428

  Compile w/Spack      0          -1           119      111        562     359

  Postmark             0          2            231      650        259     1733

  cp                   0          37           641      380        232     5791

  Others not shown     ...        ...          ...      ...        ...     ...

  ------------------   --------   ----------   ------   --------   -----   ----------

  Geometric mean       0          0            45       66         46      193
  -------------------------------------------------------------------------------------

  : Table 8: Performance of different provenance collectors.
:::

# Proposed work

After having gathered empirical evidence on why CSEs fail to be
reproducible and gathered evidence on state-of-the-art provenance
tracers, it is time to set off on future work.

## Provenance & Replay Observation Engine (PROBE)

I am working on a novel, system-level provenance tracer that uses
`LD_PRELOAD` called PROBE. The tracer is capable of tracing simple
applications and extracting a provenance dataflow graph. I need to work
on:

-   tracing more complex applications
-   tracing remote applications (by wrapping remote accesses)
-   replaying the trace on other machines
-   converting the trace to a workflow

I plan to leverage provenance standards such as RO-crates ``{=html} and
W3C PROV.

I would evaluate PROBE based on its performance and the set of
configuration variables that it isolates in the replay environment. Both
of which will be compared relative to other record/replay tools

Eventually, I want to put PROBE to use in practice at Sandia National
Labs, perhaps writing an experience report about translating research
into practice.

## Automatic environment manipulation

It is more convenient to *preserve* reproducibility, there are important
works for which we must do the more difficult task of *restoring*
reproducibility. In these cases, we can try automated methods to restore
reproducibility. The most obvious thing to try is mutating the software
environment and trying again. Perhaps the approach can be augmented with
PROBE, which will reveal which parts of the software environment are
being accessed.

A tool that automatically manipulates the software environment could
also be used to test the sensitivity of CSEs to software versions. Prior
work shows that changing the software environment has approximately the
same effect as changing the rounding mode for their particular CSE
[@vilaImpactHardwareVariability2024]. It would be interesting to
generalize this to other CSEs. Perhaps this could even be used as a
method to empirically validate uncertainty quantification estimates
produced using other methods.

## Timeline

-   Complete PROBE functionality 2024 Nov 31.
-   Deploy PROBE in practice 2024 Jan 31.
-   Automatic environment manipulation 2024 Apr 31.
-   Collberg & Proebsting reproduction 2024 Apr 31.

# Bibliography {#bibliography .unnumbered}

[^1]: I am considering the total sample to be only those papers whose
    results were backed by code, did not require special hardware, and
    were not excluded due to overlapping author lists, since those are
    the only ones Collberg and Proebsting attempted to reproduce. I am
    considering OK\<30 and OK\>30 as "reproducible crash-free building"
    because codes labelled OK\>Author were not actually reproduced on a
    new system; it was merely *repeated* on the authors system
    [@collbergRepeatabilityComputerSystems2016].

[^2]: This figure is the average normalized "reproducibility score",
    based on whether the method, data, and experiment, were available.
    If it were 1, all the papers in the sample would be have method,
    data, and experiment availability, and if it were 0, none would be.

[^3]: I am considering the total sample to be only notebooks that were
    valid, pure Python, and had an unambiguous order, since those are
    the ones Pimentel et al. attempt to reproduce
    [@pimentelLargeScaleStudyQuality2019 .]

[^4]: This figure is the average number of computational elements
    (figures and tables) that wereeproduced to semantic equivalence in
    each paper.

[^5]: I am considering the total sample to eb only notebooks that had
    dependency information and used Python 3.5 or later, since those are
    the only ones Wang et al. attempted to reproduce
    [@wangAssessingRestoringReproducibility2021].

[^6]: I am considering the total samples to be the set of *un-repaired*
    codes, since those are the ones that actually exist publicly. Also,
    we *include* codes for whicthe time limit was exceeded; reproduction
    was attempted and not successf in those conditions.

[^7]: List at <https://datasciencenotebook.org/>
