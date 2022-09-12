const form = document.querySelector("form");

form.addEventListener("submit", (event) => {
  event.preventDefault();
  const rut = document.querySelector("[name='rut']").value.trim();
  const razon = document.querySelector("[name='razon']").value.trim();
  const rubro = document.querySelector("[name='rubro']").value.trim();
  const direccion = document.querySelector("[name='direccion']").value.trim();
  const telefono = document.querySelector("[name='telefono']").value.trim();
  const representante = document
    .querySelector("[name='representante']")
    .value.trim();

  if (rut === "") errors.push("Debes ingresar el rut del cliente");
  if (razon === "") errors.push("Debes ingresar la razon social");
  if (rubro === "") errors.push("Debes ingresar el rubro");
  if (direccion === "") errors.push("Debes ingresar la direccion");
  if (telefono === "") errors.push("Debes ingresar el numero de contacto");
  if (representante === "")
    errors.push("Debes ingresar el representante legal");

  if (errors.length > 0) {
    for (let i = 0; i < errors.length; i++) {
      Toastify({
        text: "This is a toast",
        duration: 3000,
        destination: "https://github.com/apvarun/toastify-js",
        newWindow: true,
        close: true,
        gravity: "top", // `top` or `bottom`
        position: "left", // `left`, `center` or `right`
        stopOnFocus: true, // Prevents dismissing of toast on hover
        style: {
          background: "linear-gradient(to right, #00b09b, #96c93d)",
        },
        onClick: function () {}, // Callback after click
      }).showToast();
    }
  } else {
    Toastify({
      text: "Success! 😊",
      duration: 4000,
      gravity: "top",
      position: "center",
      style: {
        background: "#4bab4e",
      },
    }).showToast();
  }
});
