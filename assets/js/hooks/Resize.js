const Resize = {
  mounted(){this.create()},
  updated(){this.create()},
  create(){
    this.el.onfocus = () => {
        this.el.rows = 8
    }
    this.el.onblur = () => {
        this.el.rows = 1
    }
  }
};

export default Resize;