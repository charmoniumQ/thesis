import typing
import matplotlib.figure
import random

_T = typing.TypeVar("_T")
def functional_shuffle(seed: int, lst: typing.Sequence[_T]) -> list[_T]:
    r = random.Random()
    r.seed(seed)
    ret = list(lst)
    r.shuffle(ret)
    return ret

bars: typing.Sequence[tuple[str, float | typing.Sequence[tuple[str, float]]]] = [
    ("3rd party resources", [
        ("Unavailability", 37),
        ("Inaccessibility", 13),
        ("Updates", 8),
    ]),
    ("Ex. data unavail.", 15),
    ("Insuffic. exe. env.", 12),
    ("Insuffic. metadata", 29),
]

fig = matplotlib.figure.Figure()
ax = fig.add_subplot(1, 1, 1)
colors = functional_shuffle(0, matplotlib.cm.Pastel1.colors)
for idx, (label, bar) in enumerate(bars):
    if isinstance(bar, int | float):
        print(label, idx, bar)
        ax.bar(idx, bar, color=colors[0], label=label)
    elif isinstance(bar, list):
        sum_ = 0
        for sub_idx, (sub_label, sub_bar) in enumerate(bar):
            print(sub_label, idx, sum_, sum_ + sub_bar)
            ax.bar(
                idx,
                sub_bar,
                bottom=sum_,
                color=colors[1 + sub_idx],
                label=label,
            )
            ax.annotate(
                sub_label,
                (idx - 0.3, sum_ + sub_bar / 2),
            )
            sum_ += sub_bar
    else:
        raise TypeError()
ax.set_xticks(range(len(bars)))
ax.set_xticklabels(
    [label for label, _ in bars],
    rotation=20,
)

fig.savefig("zhao_plot.svg", bbox_inches="tight")
