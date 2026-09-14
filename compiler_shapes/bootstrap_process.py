import matplotlib
import matplotlib.figure
import matplotlib.patches
import matplotlib.artist
import matplotlib.axes


def get_canvas() -> tuple[matplotlib.figure.Figure, matplotlib.axes.Axes]:
    fig = matplotlib.figure.Figure()
    ax = fig.add_subplot(1, 1, 1)
    # Remove axes
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_xticks([])
    ax.set_yticks([])
    ax.set_frame_on(False)
    return fig, ax

def compiler_tee(
        x: float,
        y: float,
        bar_width: float,
        bar_height: float,
        stem_width: float,
        stem_height: float,
        input_lang: str,
        output_lang: str,
        source_lang: str,
) -> list[matplotlib.artist.Artist]:
    return [
        matplotlib.patches.Rectangle((x, y), width=bar_width, height=bar_height),
        matplotlib.patches.Rectangle(
            (
                x + bar_width / 2 - stem_width / 2,
                y - stem_height,
            ), width=stem_width, height=stem_height),
        matplotlib.text.Text(x, y + bar_height / 2, text=input_lang, verticalalignment='center', horizontalalignment='center'),
        matplotlib.text.Text(x + bar_width, y + bar_height / 2, text=input_lang, verticalalignment='center', horizontalalignment='center'),
        matplotlib.text.Text(x + bar_width, y + bar_height / 2, text=output_lang, verticalalignment='center', horizontalalignment='center'),
        matplotlib.text.Text(x + bar_width / 2, y - bar_height, text=source_lang, verticalalignment='center', horizontalalignment='center'),
    ]


fig, ax = get_canvas()
compiler_tee(0, 0, 1, 1, 1, 1, "Subset of C", "Machine code", "Assembly")
fig.show()
