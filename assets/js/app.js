// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import HandCanvasHook from "./hooks/hand_canvas_hook"
import FileUpload from "./hooks/file_upload"

// Import KaTeX from node_modules
import katex from '../../node_modules/katex/dist/katex.mjs'
import '../../node_modules/katex/dist/katex.css'

// Make KaTeX available globally if needed
window.katex = katex;

let Hooks = {};
Hooks.HandCanvasHook = HandCanvasHook;
Hooks.FileUpload = FileUpload;
Hooks.MathPreview = {
  mounted() {
    this.renderMath()
  },
  updated() {
    this.renderMath()
  },
  renderMath() {
    const mathElements = this.el.querySelectorAll('.math')
    mathElements.forEach(element => {
      try {
        katex.render(element.textContent, element, {
          throwOnError: false,
          displayMode: true
        })
      } catch (e) {
        console.error('Math rendering error:', e)
      }
    })
  }
}

Hooks.Modal = {
  mounted() {
    console.log("Modal mounted", this.el.id, this.el.dataset.show)
    if (this.el.dataset.show === "true") {
      this.showModal()
    }
  },
  showModal() {
    console.log("Showing modal", this.el.id)
    // Your existing show modal logic
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken}
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// Show modal
window.addEventListener("js:show_modal", e => {
  const modalId = e.detail.id
  const modalEl = document.getElementById(modalId)
  if (modalEl) {
    modalEl.classList.remove("hidden")
    const containerEl = document.getElementById(`${modalId}-container`)
    if (containerEl) containerEl.classList.remove("hidden")
  }
})

// Hide modal
window.addEventListener("js:hide_modal", e => {
  const modalId = e.detail.id
  const modalEl = document.getElementById(modalId)
  if (modalEl) {
    modalEl.classList.add("hidden")
    const containerEl = document.getElementById(`${modalId}-container`)
    if (containerEl) containerEl.classList.add("hidden")
  }
})
