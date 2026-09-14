The goal of my research is to improve how researchers develop reproducible research software (**RS**).

**How I got on this topic**

I first started doing research in computer architecture.
I found that I was spending far too much time on tangential tasks: installing, compiling, and configuring a dizzying array of compilers, simulators, and electronic design tools.
If we made a mistake, because our RS was so difficult to reproduce, it is unlikely the mistake would ever be discovered directly.

I decided the problem I wanted to focus my career on was that intermediate problem, that RS sometimes contains errors or usability obstacles.
This problem occurs in every field in which research involves the creation or modification of software code and slows down progress on existential problems.
56% of sampled university researchers create software as a part of their research (Hettrick 2018).
For those researchers, software errors could lead to wrong results.
Usability obstacles lead to an increased chance of errors, because usability obstacles lead to each research group writing their own implementation, and with more implementations, there is a greater chance one will be affected by errors, and fewer people scrutinizing each implementation (Linus's law).

Correctness is hard to evaluate directly, as they can sneak past domain experts for years, so we study usability.
One component of usability, crash-free reproducibility, is possible to evaluate directly.
Crash-free reproducibility just asks whether the original RS can be re-executed in the original configuration by a different team at all.
RS results reproducibility is the end goal, but crash-free reproducibility is a necessary condition.
Prior work (Zhao 2012, Collberg 2016) indicates that even crash-free reproducibiltiy for RS is difficult to come by in selected repositories.
Therefore, my thesis focuses on crash-free reproducibility.

**My prior work**

The tools have evolved greatly since then, especially the widespread adoption of containers and workflows in certain domains, so it is an open question whether RS crash-free reproducibility is still lacking.
Therefore, I used software repository mining on RS workflows to show that crash-free reproducibility is indeed still a significant problem (Grayson 2023).
In my results, the most frequent root cause of irreproducibility was missing inputs or software dependencies.

Provenance tracing purports to track exactly what was missing: input files and software dependencies.
Therefore, I surveyed provenance tracers through a rapid review (Grayson 2024).
Prior work used a variety of incompatible benchmarks, so I re-executed all of the selected provenance tracers on a consistent benchmark set.
Even the fastest full provenance tracer had an average overhead of 50% (i.e., new runtime is 1.5x the original runtime), which is too slow for pervasive use.
This benchmark established the goalposts for future provenance tracers.

I set about creating a provenance tracer called PROBE, specifically oriented towards reproducibility.
Not only can PROBE record provenance, it can create a bundle with all executed commands, all input files, and all software dependencies.
That bundle can be transparently re-executed on any machine with the compatible hardware.
PROBE does not require the author to use a workflow, and PROBE guarantees there are no missing files in the bundle, so long as basic assumptions are maintained.
PROBE has an average overhead of less than 5%, which is acceptable for pervasive use.
This work is currently under submission.
If the work proves out, PROBE could make computational science papers crash-free reproducible with little effort from the user; they would just have to enable recording mode before starting the project, and then upload the PROBE bundle when they upload their paper.

Being a large project, there were ample opportunities for others to work on the project.
Many tasks do not require deep knowledge of RS engineering or reproducibility.
I had the pleasure of mentoring five summer undergrad students, who stayed on for the following school year.
I let each student describe their interests and find tasks in PROBE that were within their interest.

Simultaneous to developing PROBE, I have been applying PROBE to machine learning projects for a team at Sandia National Laboratories studying on Trustworthy Machine Learning.
Machine learning research often requires producing novel research code, and the code is often not reproducible (Gundersen 2020), so it is a natural fit for the capabilities of PROBE.
Besides making programs reproducible, PROBE is also able to describe what files were utilized, which is also important for engendering trustworthiness in the machine learning process.

In one work I collaborated on (Malviya-Thakur 2022), we conducted unstructured interviews to elicit attitudes around the adoption of workflows for the Exascale Computing Project.
We found that the interview responses could be analyzed through the Perceived Characteristics of Innovation (PCI) theory (Moore 1991).
The result implies that one can use PCI theory as a framework to drive adoption of other tools, such as PROBE.

**My future work**

My goal is to continue improving the way researchers develop RS, in reproducibility and beyond.

Future work on reproducibility could connect PROBE with novel 'executable paper' publishing models and other reproducibility tools.
Once PROBE is integrated into an ecosystem of reproducibility tools, one could analyze usability and efficacy through case studies and controlled experiments;
case studies provide detailed feedback and insights by embedding with practitioners, whereas controlled experiments test the generalizability of those insights.
Such a study would reveal the gaps that are newly closed or created by the state of the art in reproducibility.

Future work more generally could investigate how research software engineers use LLMs, and whether the LLM can be made more useful or accurate by integration with classical tools.
Prior work (Bi 2024) found benefit in giving compiler feedback to the LLM, but we might test giving the PROBE dataflow graph or other RS-specific tools to the LLM.
One may hypothesize that type signatures describing array length (i.e., dependent types) may be distinctly useful for LLMs in an RS context.

On the other hand, dependent types for RS may be studied outside of the context of LLMs.
Many RS codes implemented as Jupyter Notebooks hardcode constants, hindering reusability; for example, changing the batch size in one part of the code may cause an error in another part.
It may be worth examining whether a dependent type system could catch such errors and suggest a repair.
One might study whether the intervention improves user efficacy on simple coding tasks.

I would adhere to the principles of 'translational' research, applying computer science concepts into the practice of research software engineering.
The RS landscape is ripe to test out computer science concepts.
