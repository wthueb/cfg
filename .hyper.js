"use strict";

module.exports = {
  config: {
    // 'stable' or 'canary'
    updateChannel: "stable",
    disableAutoUpdates: false,

    fontSize: 13,
    fontFamily: 'Monaco, "Lucida Console", monospace',
    fontWeight: "normal",
    fontWeightBold: "bold",

    lineHeight: 1,
    letterSpacing: 0,

    cursorColor: "rgba(248,28,229,0.8)",
    // color of foreground text of cursor
    cursorAccentColor: "#000",
    // 'BEAM' for |, 'UNDERLINE' for _, 'BLOCK' for █
    cursorShape: "BLOCK",
    cursorBlink: false,

    foregroundColor: "#fff",
    backgroundColor: "#000",
    selectionColor: "rgba(248,28,229,0.3)",
    borderColor: "#333",

    // custom CSS to embed in the main window
    css: "",
    // custom CSS to embed in the terminal window
    termCSS: "",

    workingDirectory: "",

    showHamburgerMenu: "",
    showWindowControls: "",

    padding: "0px 5px",

    colors: {
      black: "#000000",
      red: "#C51E14",
      green: "#1DC121",
      yellow: "#C7C329",
      blue: "#0A2FC4",
      magenta: "#C839C5",
      cyan: "#20C5C6",
      white: "#C7C7C7",
      lightBlack: "#686868",
      lightRed: "#FD6F6B",
      lightGreen: "#67F86F",
      lightYellow: "#FFFA72",
      lightBlue: "#6A76FB",
      lightMagenta: "#FD7CFC",
      lightCyan: "#68FDFE",
      lightWhite: "#FFFFFF",
      limeGreen: "#32CD32",
      lightCoral: "#F08080",
    },

    shell: "",
    shellArgs: ["--login"],

    env: {},

    // 'SOUND' or false
    bell: false,
    // bellSoundURL: '/path/to/sound/file',

    copyOnSelect: false,

    defaultSSHApp: true,

    // copy/paste on right click
    quickEdit: false,

    macOptionSelectionMode: "vertical",
    webGLRenderer: true,

    webLinksActivationKey: "",

    disableLigatures: false,
  },

  plugins: ["nord-hyper", "hyper-search"],

  localPlugins: [],

  keymaps: {},
};
