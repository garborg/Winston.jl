import Gtk
import Base.repl_show

function GTKdrawingwindow(name, w, h, closecb=nothing)
    win = Gtk.Window(name, w, h)
    c = Gtk.Canvas(win)
    if closecb !== nothing
        Gtk.on_signal_destroy(win, closecb, win)
    end
    c, win
end

_saved_gtk_renderer = nothing
function _saved_gtk_destroyed(::Ptr, widget::Gtk.GTKWidget)
    global _saved_gtk_renderer = nothing
    nothing
end
function gtk(self::PlotContainer, args...)
    global _saved_gtk_renderer, _saved_gtk_win
    opts = Winston.args2dict(args...)
    width = get(opts,"width",Winston.config_value("window","width"))
    height = get(opts,"height",Winston.config_value("window","height"))
    reuse_window = isinteractive() #&& Winston.config_value("window","reuse")
    device = _saved_gtk_renderer
    if device === nothing || !reuse_window
        device, win = GTKdrawingwindow("Julia", width, height, _saved_gtk_destroyed)
        _saved_gtk_renderer = device
    end
    draw(device) do
        cc = getgc(device)
        Cairo.set_source_rgb(cc, 1, 1, 1)
        Cairo.paint(cc)
        Winston.page_compose(self, cs)
        Gtk.reveal(device)
        nothing
    end
    self
end

function repl_show(io::IO, p::PlotContainer)
    print("<plot>")
end

function display(args...)
    gtk(args...)
end
