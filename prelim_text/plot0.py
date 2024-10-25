import matplotlib.figure
import numpy

xmin = 0
xmax = 2
xmid = 0.5
old_curve = lambda x: numpy.sqrt(x)
new_curve = lambda x: 3 * numpy.sqrt(x)

fig = matplotlib.figure.Figure()
ax = fig.add_subplot()
xs = numpy.linspace(xmin, xmax, 100)
line = ax.plot(xs, old_curve(xs), label="status quo")
baseline     = ax.plot([xmid, xmid], [0, old_curve(xmid)], color="black", linestyle="--")
baseline_dot = ax.plot([xmid      ], [   old_curve(xmid)], color="black", marker="o")
ax.set_xlim(0, xmax)
ax.set_ylim(0, new_curve(xmax))
ax.set_xlabel("Effort")
ax.set_ylabel("Reproducibility")
ax.set_xticks([])
ax.set_yticks([])
#ax.set_title("Effort-vs-reproducibility for CSE")

# # Move the left and bottom spines to x = 0 and y = 0, respectively.
ax.spines[["left", "bottom"]].set_position(("data", 0))

# # Hide the top and right spines.
ax.spines[["top", "right"]].set_visible(False)

for axis_min, axis_max, symbol, transform in [
        (1, 0, ">", ax.get_yaxis_transform()),
        (0, 1, "^", ax.get_xaxis_transform()),
    ]:
    ax.plot(
        axis_min,
        axis_max,
        ls="",
        marker=symbol,
        ms=10,
        color="k",
        transform=transform,
        clip_on=False,
    )

fig.savefig("plot0.pdf")
fig.savefig("plot0.svg")

line = ax.plot(xs, new_curve(xs), label="with reproducibility tools")
baseline     = ax.plot([xmid, xmid], [0, new_curve(xmid)], color="black", linestyle="--")
baseline_dot = ax.plot([xmid      ], [   new_curve(xmid)], color="black", marker="o")
fig.savefig("plot01.svg")

for seg in [*line, *baseline, *baseline_dot]:
    seg.remove()
fig.savefig("plot1.svg")
