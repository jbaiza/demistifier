// hamburger menu

(function() {
  const hamburger = {
    navToggle: document.querySelector(".navPanelToggle"),
    navClose: document.querySelector(".navPanelClose"),
    nav: document.getElementById("navPanel"),

    doToggle: function(e) {
      e.preventDefault();
      this.nav.classList.toggle("visible");
    }
  };

  hamburger.navToggle.addEventListener("click", doToggle);
  hamburger.navClose.addEventListener("click", doToggle);

  function doToggle(e) {
    hamburger.doToggle(e);
  }
})();
