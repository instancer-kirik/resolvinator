const SecureText = {
  mounted() {
    const canvas = this.el;
    const ctx = canvas.getContext('2d');
    const text = this.el.dataset.text;
    
    // Set canvas size
    canvas.width = text.length * 12;  // Approximate width
    canvas.height = 24;  // Fixed height
    
    // Draw text
    ctx.font = '16px Arial';
    ctx.fillStyle = 'black';
    ctx.fillText(text, 0, 16);
    
    // Optional: Add noise
    for(let i = 0; i < canvas.width; i++) {
      for(let j = 0; j < canvas.height; j++) {
        if(Math.random() < 0.1) {
          ctx.fillStyle = `rgba(0,0,0,0.02)`;
          ctx.fillRect(i, j, 1, 1);
        }
      }
    }
  }
}

export default SecureText; 