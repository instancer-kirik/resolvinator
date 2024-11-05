const MathImageAnnotations = {
  mounted() {
    this.canvas = this.el.querySelector('canvas')
    this.ctx = this.canvas.getContext('2d')
    this.annotations = []
    this.isDrawing = false
    this.currentTool = this.el.dataset.tool

    this.setupCanvas()
    this.bindEvents()
  },

  setupCanvas() {
    const img = this.el.querySelector('img')
    this.canvas.width = img.width
    this.canvas.height = img.height
    this.redraw()
  },

  bindEvents() {
    this.canvas.addEventListener('mousedown', this.startDrawing.bind(this))
    this.canvas.addEventListener('mousemove', this.draw.bind(this))
    this.canvas.addEventListener('mouseup', this.stopDrawing.bind(this))
  },

  startDrawing(e) {
    this.isDrawing = true
    const pos = this.getMousePos(e)
    this.startPos = pos
  },

  draw(e) {
    if (!this.isDrawing) return

    const pos = this.getMousePos(e)
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height)
    this.redraw()

    switch (this.currentTool) {
      case 'arrow':
        this.drawArrow(this.startPos, pos)
        break
      case 'circle':
        this.drawCircle(this.startPos, pos)
        break
      // Add more tools as needed
    }
  },

  stopDrawing(e) {
    if (!this.isDrawing) return
    
    const pos = this.getMousePos(e)
    this.annotations.push({
      type: this.currentTool,
      start: this.startPos,
      end: pos
    })

    this.isDrawing = false
    this.pushEventTo(this.el, 'annotation-added', {
      annotations: this.annotations
    })
  },

  // Helper methods for drawing different shapes
  drawArrow(start, end) {
    // Arrow drawing implementation
  },

  drawCircle(center, point) {
    // Circle drawing implementation
  },

  // ... more drawing methods ...

  redraw() {
    this.annotations.forEach(ann => {
      switch (ann.type) {
        case 'arrow':
          this.drawArrow(ann.start, ann.end)
          break
        case 'circle':
          this.drawCircle(ann.start, ann.end)
          break
      }
    })
  },

  getMousePos(e) {
    const rect = this.canvas.getBoundingClientRect()
    return {
      x: e.clientX - rect.left,
      y: e.clientY - rect.top
    }
  }
}

export default MathImageAnnotations 