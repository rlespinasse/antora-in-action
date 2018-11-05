const buildGoToSlideUI = ({ slideName, keyCode }) => `<script>
document.addEventListener('keydown', (event) => {
  const key = event.key;
  if (key === '${keyCode}') {
    document.location.href = '${slideName}.html';
    // event.preventDefault();
  }
});
</script>`

function blockGoToSlideMacro () {
  this.process((parent, slideName, attrs) => {
    const keyCode = Opal.hash_get(attrs, 'keyCode')
    return this.createBlock(parent, 'pass', buildGoToSlideUI({ slideName, keyCode }))
  })
}

function register (registry, context) {
  registry.blockMacro('gotoslide', blockGoToSlideMacro)
}

module.exports.register = register
