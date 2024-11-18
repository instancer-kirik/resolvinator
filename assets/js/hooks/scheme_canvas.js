const SchemeCanvas = {
	mounted() {
		this.dragging = null;
		this.setupDragListeners();
	},

	setupDragListeners() {
		this.el.addEventListener('mousedown', e => {
			if (e.target.classList.contains('node')) {
				this.dragging = {
					el: e.target,
					startX: e.clientX,
					startY: e.clientY,
					originalX: parseInt(e.target.style.left),
					originalY: parseInt(e.target.style.top)
				};
			}
		});

		window.addEventListener('mousemove', e => {
			if (this.dragging) {
				const dx = e.clientX - this.dragging.startX;
				const dy = e.clientY - this.dragging.startY;
				
				const newX = this.dragging.originalX + dx;
				const newY = this.dragging.originalY + dy;
				
				this.dragging.el.style.left = `${newX}px`;
				this.dragging.el.style.top = `${newY}px`;
			}
		});

		window.addEventListener('mouseup', e => {
			if (this.dragging) {
				const nodeId = this.dragging.el.dataset.id;
				const finalX = parseInt(this.dragging.el.style.left);
				const finalY = parseInt(this.dragging.el.style.top);
				
				this.pushEvent('move_node', {
					id: nodeId,
					x: finalX,
					y: finalY
				});
				
				this.dragging = null;
			}
		});
	}
};

export default SchemeCanvas;