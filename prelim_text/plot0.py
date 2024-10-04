import matplotlib.figure
import numpy

fig = matplotlib.figure.Figure()
ax = fig.add_subplot()
xmin = 0.1
xmax = 2
xs = numpy.linspace(xmin, xmax, 100)
ax.plot(xs, 2 / xs, label="status quo")
ax.plot(xs, 1 / xs, label="with reproducibility tools")
ax.set_xlim(0, xmax)
ax.legend()
ax.set_ylim(0, 1 / xmin)
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
