const formularioAccident = document.getElementById("form-accident");
const inputs = document.querySelectorAll("#form-accident input");

function sumarDias(fecha, dias) {
  fecha.setDate(fecha.getDate() + dias);
  return fecha;
}

const validarFormulario = (e) => {
  switch (e.target.name) {
    case "fecha":
      var fecha = new Date(e.target.value);
      var f1 = new Date(sumarDias(fecha, 1)).toDateString();
      var f2 = Date.now();
      var f3 = new Date(f2).toDateString();

      var f4 = new Date(f1);
      var f5 = new Date(f3);

      if (f4 > f5) {
        document
          .querySelector("#input-field .alert-input")
          .classList.add("alert-input-active");

        const btn = document.getElementById("btn");
        btn.disabled = true;
      } else {
        document
          .querySelector("#input-field .alert-input")
          .classList.remove("alert-input-active");

        const btn = document.getElementById("btn");
        btn.disabled = false;
      }
      break;
  }
};

inputs.forEach((input) => {
  input.addEventListener("keyup", validarFormulario);
  input.addEventListener("blur", validarFormulario);
});