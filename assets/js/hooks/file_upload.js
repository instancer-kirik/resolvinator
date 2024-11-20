const FileUpload = {
  mounted() {
    this.el.addEventListener('change', (e) => {
      const file = e.target.files[0];
      if (!file) return;

      const reader = new FileReader();
      reader.onload = (e) => {
        const content = e.target.result;
        this.pushEvent('process-ics', { ics: { content } });
      };
      reader.readAsText(file);
    });
  }
};

export default FileUpload;
