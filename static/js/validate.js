const formulario = document.getElementById("formulario");
const inputs = document.querySelectorAll("#formulario input");

const expresiones = {
  rut: /^\d{1,2}\.\d{3}\.\d{3}[-][0-9kK]{1}$/,
  telefono: /^(\+56)(0?9)[987654321]\d{7}$/,

}

const validarFormulario = (e) => {
  switch (e.target.name) {
    case "rut":
      if (expresiones.rut.test()) {
        
      }

    break;
    case "razon":
      
    break;
    case "direccion":
      
    break;
    case "telefono":
      
    break;
    case "representante":
      
    break;
  }
}

inputs.forEach((input) => {
  input.addEventListener("keyup", validarFormulario)
  input.addEventListener("blur", validarFormulario)
});

formulario.addEventListener("submit", (e) => {});
