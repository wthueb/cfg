# https://github.com/dracula/vim/blob/master/colors/dracula.vim


from ranger.gui.colorscheme import ColorScheme
from ranger.gui.color import reverse, bold, normal


# pylint: disable=too-many-branches,too-many-statements
class Dracula(ColorScheme):
    progress_bar_color = 228

    def use(self, context):
        foreground = 253
        bglighter = 238
        bglight = 237
        background = 0
        bgdark = 235
        bgdarker = 234

        comment = 61
        selection = 239
        subtle = 238

        cyan = 117
        green = 84
        orange = 215
        pink = 212
        purple = 141
        red = 203
        yellow = 228

        fg = foreground
        bg = background
        attr = normal

        if context.reset:
            return fg, bg, attr

        elif context.in_browser:
            if context.selected:
                bg = selection

            if context.empty or context.error:
                bg = red

            if context.border:
                pass

            #if context.image:
            #    fg = yellow
            #if context.video:
            #    fg = yellow
            #if context.audio:
            #    fg = yellow
            #if context.document:
            #    fg = orange

            if context.container:
                attr |= bold

            if context.directory:
                fg = cyan
                attr |= bold
            elif context.executable and not \
                    any((context.media, context.container,
                         context.fifo, context.socket)):
                fg = pink
                attr |= bold

            if context.socket:
                fg = bglighter
                attr |= bold

            if context.fifo or context.device:
                fg = bglighter

                if context.device:
                    attr |= bold

            if context.link:
                if context.good:
                    fg = red
                else:
                    bg = red
                    attr |= bold

            if context.bad:
                bg = red
                attr |= bold

            if context.tag_marker and not context.selected:
                attr |= bold

                # TODO

            if not context.selected and (context.cut or context.copied):
                bg = bglight

            if context.main_column:
                if context.selected:
                    attr |= bold

                if context.marked:
                    # TODO
                    attr |= bold

            if context.badinfo:
                # TODO
                if attr & reverse:
                    bg = 95
                else:
                    fg = 95

        elif context.in_titlebar:
            attr |= bold

            if context.hostname:
                fg = red if context.bad else green
            elif context.directory:
                fg = cyan
            elif context.tab:
                bg = yellow
            elif context.link:
                fg = red

        elif context.in_statusbar:
            if context.permissions:
                if context.good:
                    fg = purple
                elif context.bad:
                    fg = red

            if context.marked:
                # TODO
                fg = 223
                attr |= bold | reverse

            if context.message:
                if context.bad:
                    bg = red
                    attr |= bold

            if context.loaded:
                bg = self.progress_bar_color

            if context.vcsinfo:
                fg = green
                attr &= ~bold

            if context.vcscommit:
                fg = pink
                attr &= ~bold

        if context.text:
            if context.highlight:
                attr |= reverse

        if context.in_taskview:
            if context.title:
                fg = 116

            if context.selected:
                attr |= reverse

            if context.loaded:
                if context.selected:
                    fg = self.progress_bar_color
                else:
                    bg = self.progress_bar_color

        if context.vcsfile:
            attr &= ~bold

            if context.vcsconflict:
                fg = red
            elif context.vcschanged:
                fg = pink
            elif context.vcsunknown:
                fg = comment
            elif context.vcsstaged:
                fg = green
            elif context.vcssync:
                fg = 108
            elif context.vcsignored:
                pass

        elif context.vcsremote:
            attr &= ~bold

            if context.vcssync:
                fg = 108
            elif context.vcsbehind:
                fg = red
            elif context.vcsahead:
                fg = purple
            elif context.vcsdiverged:
                fg = yellow
            elif context.vcsunknown:
                fg = comment

        return fg, bg, attr
