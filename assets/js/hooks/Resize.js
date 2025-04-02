const Resize = {
  mounted(){
    this.rows = 1;
    this.create()
  },
  updated(){},
  create(){
    this.el.addEventListener("keydown", (e) => {
      if (e.ctrlKey && e.key === 'Enter') {
        e.preventDefault();
        this.rows = Math.max(1, this.rows - 1);
        this.el.rows = this.rows
      }

      if (!e.shiftKey && !e.ctrlKey && e.key === 'Enter') {
        this.el.form.dispatchEvent(
          new Event('submit', {bubbles: true, cancelable: true}));

        this.rows = 1;
        this.el.rows = this.rows
      }
      if (e.shiftKey && e.key === 'Enter') {
        this.rows = this.rows + 1;
        this.el.rows = this.rows
      }
    })

    this.el.onfocus = () => {
      this.el.rows = this.rows
    }

    this.el.onblur = () => {
      this.el.rows = this.rows
    }
  }
};

export default Resize;